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
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //  The cells will be taken from the saved devices table view cell
        tableView.register(ConnectedDeviceTableViewCell.self, forCellReuseIdentifier: "ConnectedDevice")
        tableView.register(AvailableModulesTableViewCell.self, forCellReuseIdentifier: "AvailableModule")
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


extension ConnectedDeviceViewController: UITableViewDelegate{
    
}

extension ConnectedDeviceViewController: UITableViewDataSource {
    
    //  Use for knowing what section and what information to show
    enum TableSection: Int {
        case device = 0
        case modules = 1
    }
    
    //  Have two sections: Device and Modules
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //  Grab the necessary section header
        var localizationKey: String!
        
        switch TableSection(rawValue: section)! {
        case .device:
            localizationKey = "peripheralmodules_sectiontitle_device_single"
        case .modules:
            localizationKey = "peripheralmodules_sectiontitle_modules"
        }
        
        return LocalizationManager.shared.localizedString(localizationKey)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  Find out how many modes depending on the section
        switch TableSection(rawValue: section)! {
        case .device:
            //  Only supporting one device
            return 1
        case .modules:
            //  Only have enough rows for the number of modules available
            return DefineModes().count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  Need to choose the right cell to display depending on section
        var identifier: String
        switch TableSection(rawValue: indexPath.section)! {
        case .device:
            //  Need to display the device that is selected
            identifier = "ConnectedDevice"
        case .modules:
            identifier = "AvailableModule"
        }
        
        //  Create the cell based on the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        return cell
    }
    
    
}
