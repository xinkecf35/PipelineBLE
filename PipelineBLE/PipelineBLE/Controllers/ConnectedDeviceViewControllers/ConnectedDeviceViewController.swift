//
//  ConnectedDeviceViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/22/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class ConnectedDeviceViewController: UIViewController {
    
    //  Data about the device
    weak var selectedPeripheral: BlePeripheral?
    var hasUart = false
    var hasDfu = false
    
    //  Enum to easily access info about the peripheral
    enum Modes: Int {
        case uart
        case buttons
        case datastream
        case savedData
        case info
    }
    
    //  UI Components
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Do some initialization
        if let peripheral = selectedPeripheral {
            hasUart = peripheral.hasUart()
        }

        //  Configure the view
        UISettings()
        
        //  Register cells for their identifier
        tableView.register(AvailableModulesTableViewCell.self, forCellReuseIdentifier: "AvailableModule")
        tableView.register(ConnectedDeviceTableViewCell.self, forCellReuseIdentifier: "ConnectedDevice")
    }
    
    func UISettings(){
        //  Change the page title in the navigation bar
        self.title = "Device Menu"
        
        //  Add table view
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    fileprivate func DefineModes() -> [Modes]{
        if hasUart {
            return [.uart, .buttons, .datastream, .savedData, .info]
        }
        else{
            //  Does not conform to the requirements... Decide to maybe display some
            //  generic information here
            return [.info]
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}


extension ConnectedDeviceViewController: UITableViewDataSource {
    
    //  Use for knowing what section and what information to show
    enum TableSection: Int {
        case device = 0
        case modules = 1
    }
    
    //  Have two sections: Device and Modules
    func numberOfSections(in tableView: UITableView) -> Int {
        print("Sections: \(2)")
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("reached title for header in section")
        //  Grab the necessary section header
        var localizationKey: String!
        
        switch TableSection(rawValue: section)! {
        case .device:
            print("TitleForHeader: Device")
            localizationKey = "peripheralmodules_sectiontitle_device_single"
        case .modules:
            print("TitleForHeader: Module")
            localizationKey = "peripheralmodules_sectiontitle_modules"
        }
        
        return LocalizationManager.shared.localizedString(localizationKey)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("reached num rows in section")
        //  Find out how many modes depending on the section
        switch TableSection(rawValue: section)! {
        case .device:
            //  Only supporting one device
            print("NumRowsSection: Device")
            return 1
        case .modules:
            //  Only have enough rows for the number of modules available
            print("NumRowsSection: modules -- \(DefineModes().count)")
            return DefineModes().count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("reached cellfor row at")
        //  Need to choose the right cell to display depending on section
        var identifier: String
        switch TableSection(rawValue: indexPath.section)! {
        case .device:
            //  Need to display the device that is selected
            print("CellForRowAt: Device")
            identifier = "ConnectedDevice"
        case .modules:
            print("CellForRowAt: Module")
            identifier = "AvailableModule"
        }
        
        //  Create the cell based on the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }
    
    
}

extension ConnectedDeviceViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //  Will need to display localized strings
        let localizationManager = LocalizationManager.shared
        
        //  Need to take action depending on what type of cell it is
        switch TableSection(rawValue: indexPath.section)! {
        case .device:
            //  Make sure that the cell passed is of the right type
            guard let deviceCell = cell as? ConnectedDeviceTableViewCell else { return }
            
            //  Will now need to send info about the device so it can be displayed
            deviceCell.deviceName.text = selectedPeripheral!.name ?? localizationManager.localizedString("scanner_unnamed")
            deviceCell.subtitle.text = selectedPeripheral!.isUartAdvertised() ? localizationManager.localizedString("scanner_uartavailable") : "UART Unavailable"
            deviceCell.signalImage.image = RssiUI.signalImage(for: selectedPeripheral?.rssi)
            
        case .modules:
            //  Need to make sure that the cell is of the right type
            guard let moduleCell = cell as? AvailableModulesTableViewCell else { return }
            
            //  Create variables to store data that will be passed
            var moduleName: String?
            var moduleIcon: String?
            let availableModules = DefineModes()
            
            //  Now need to see what module and info needs to be passed
            switch availableModules[indexPath.row] {
            case .uart:
                moduleIcon = "UART_Icon"
                moduleName = localizationManager.localizedString("uart_tab_title")
            case .buttons:
                moduleIcon = "Buttons_Icon"
                moduleName = "Buttons"
            case .datastream:
                moduleIcon = "Data_Stream_Icon"
                moduleName = "Data Stream"
            case .savedData:
                moduleIcon = "Saved_Data_ Icon"
                moduleName = "Saved Data"
            case .info:
                moduleIcon = "Info_Icon"
                moduleName = localizationManager.localizedString("info_tab_title")
            }
            
            //  Now pass the data to the cell
            print("**Name: \(moduleName ?? "Unknown")")
            moduleCell.moduleName.text = moduleName
            moduleCell.moduleImage.image = moduleIcon != nil ? UIImage(named: moduleIcon!) : nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  One of the modules has now been selected
        switch TableSection(rawValue: indexPath.section)! {
        case .device:
            //  Don't want anything to happen here, so just return
            return
        case .modules:
            //  Want to go to the selected module
            let modes = DefineModes()
            
            switch modes[indexPath.row]{
            case .uart:
                //  Selected UART, need to open the view controller
                print("Selecting Row")
                /*
                if let uartViewController = self.storyboard?.instantiateViewController(withIdentifier: "UARTViewController") as? UARTViewController {
                    print("success")
                    uartViewController.blePeripheral = selectedPeripheral
                    uartViewController.hidesBottomBarWhenPushed = true
                    show(uartViewController, sender: self)
                }
                */
                
                
                let uartViewController = UARTViewController()
                self.storyboard?.instantiateViewController(withIdentifier: "UARTViewController")
                uartViewController.hidesBottomBarWhenPushed = true
                uartViewController.blePeripheral = selectedPeripheral
                navigationController?.pushViewController(uartViewController, animated: true)
                
            case .buttons:
                //  Need to open the buttons view controller
                let buttonsViewController = ButtonsViewController()
                buttonsViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(buttonsViewController, animated: true)
            case .datastream:
                //  Open data stream view controller
                let dataStreamViewController = DataStreamViewController()
                dataStreamViewController.hidesBottomBarWhenPushed = true
                dataStreamViewController.blePeripheral = selectedPeripheral
                navigationController?.pushViewController(dataStreamViewController, animated: true)
            case .savedData:
                //  Open saved data view controller
                let savedDataViewController = SavedDataViewController()
                savedDataViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(savedDataViewController, animated: true)
            case .info:
                //  Open info view controller
                let infoViewController = DeviceInfoViewController()
                infoViewController.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(infoViewController, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: indexPath.section == 0)
    }
    
}
