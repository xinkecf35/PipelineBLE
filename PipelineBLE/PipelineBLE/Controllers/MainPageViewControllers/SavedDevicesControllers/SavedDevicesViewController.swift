//
//  ViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/7/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class SavedDevicesViewController: UITableViewController {
    
    let dummyData = ["One","Two","Three","Four","Five","Six"]
    
    //  Data for searching for peripherals
    fileprivate var peripheralList: PeripheralList!
    fileprivate var isBaseTableScrolling = false
    fileprivate var isScannerTableWaitingForReload = false
    fileprivate var isBaseTableAnimating = false
    
    
    //  Data for when a peripheral has been selected
    weak var selectedPeripheral: BlePeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  View just appeared, configure the layout
        navigationItem.title = "Saved Devices"
        
        //  Initialize the peripheral list here
        peripheralList = PeripheralList()
        
        //  The cells will be taken from the saved devices table view cell
        tableView.register(SavedDevicesTableViewCell.self, forCellReuseIdentifier: "SavedDevice")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  Scan for peripherals
        BleManager.shared.startScan()
        updateScannedPeripherals()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  Calculate the number of cells
        if selectedPeripheral == nil {      // Dont update while a peripheral has been selected
            WatchSessionManager.shared.updateApplicationContext(mode: .scan)
        }
        
        print("Count: \(peripheralList.filteredPeripherals(forceUpdate: false).count)")
        return peripheralList.filteredPeripherals(forceUpdate: false).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  Create a cell of type SavedDevicesTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedDevice", for: indexPath) as! SavedDevicesTableViewCell
        
        //  Get information to pass to the cell
        let peripheral = peripheralList.filteredPeripherals(forceUpdate: false)[indexPath.row]
        let localizationManager = LocalizationManager.shared
        cell.deviceName.text = peripheral.name ?? localizationManager.localizedString("scanner_unnamed")
        print(peripheral.name ?? localizationManager.localizedString("scanner_unnamed"))
        
        //  Send the cell the necessary data to configure itself
        //cell.deviceName.text = dummyData[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(indexPath.row)")
        let connectToDevice = UARTViewController()
        navigationController?.pushViewController(connectToDevice, animated: true)
    }
    
    private func updateScannedPeripherals() {
        // Reload table
        if isBaseTableScrolling || isBaseTableAnimating {
            isScannerTableWaitingForReload = true
        } else {
            reloadBaseTable()
        }
    }
    
    fileprivate func reloadBaseTable() {
        //  Reload the table of peripherals
        isBaseTableScrolling = false
        isBaseTableAnimating = false
        isScannerTableWaitingForReload = false
        
        //  Get the filtered peripherals (no actual filtering)
        _ = peripheralList.filteredPeripherals(forceUpdate: true)
        tableView.reloadData()
        
        print("Filtered: \(peripheralList.filteredPeripherals(forceUpdate: false).count)")
    }
    
    
    func ConnectToDevice(){
        //  Use this function to segue from current view controller to UART
        let connectToDevice = UARTViewController()
        navigationController?.pushViewController(connectToDevice, animated: true)
    }


}

