//
//  AvailableDevicesViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/8/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import CoreData

class AvailableDevicesViewController: UITableViewController {
    
    //  Data for searching for peripheral
    fileprivate var peripheralList: PeripheralList!
    fileprivate var isBaseTableScrolling = false
    fileprivate var isScannerTableWaitingForReload = false
    fileprivate var isBaseTableAnimating = false
    fileprivate var isRowDetailOpenForPeripheral = [UUID: Bool]()
    
    //  System controllers
    fileprivate let refreshController = UIRefreshControl()
    fileprivate var infoAlertController: UIAlertController?
    fileprivate var isMultiConnectEnabled = false
    fileprivate let firmwareUpdater = FirmwareUpdater()
    
    //  Store object protocols
    private weak var didUpdateBleStateObserver: NSObjectProtocol?
    private weak var didDiscoverPeripheralObserver: NSObjectProtocol?
    private weak var willConnectToPeripheralObserver: NSObjectProtocol?
    private weak var didConnectToPeripheralObserver: NSObjectProtocol?
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?
    private weak var peripheralDidUpdateNameObserver: NSObjectProtocol?
    
    //  Data for when a peripheral has been selected
    weak var selectedPeripheral: BlePeripheral?
    var savedDevices: [UUID: SavedPeripheral] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  View just appeared, configure the layout
        navigationItem.title = "Available Devices"
        
        //  Initialize the peripheral list here
        peripheralList = PeripheralList()
        
        //  Control when the table will update
        refreshController.addTarget(self, action: #selector(onTableRefresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshController)
        tableView.sendSubviewToBack(refreshController)
        
        //  The cells will be taken from the available devices table view cell
        tableView.register(AvailableDevicesTableViewCell.self, forCellReuseIdentifier: "AvailableDevice")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  Get saved peripherals
        getSavedPeripherals()
        
        // Flush any pending state notifications
        didUpdateBleState()
        
        //  Ble Notifications
        registerNotifications(enabled: true)
        DLog("Scanner: Register notifications")
        
        let isFullScreen = UIScreen.main.traitCollection.horizontalSizeClass == .compact
        
        if isFullScreen {
            print("isFullScreen")
            // If only connected to 1 peripheral and coming back to this
            let connectedPeripherals = BleManager.shared.connectedPeripherals()
            if connectedPeripherals.count == 1, let peripheral = connectedPeripherals.first {
                DLog("Disconnect from previously connected peripheral")
                // Disconnect from peripheral
                BleManager.shared.disconnect(from: peripheral)
            }
        }
        
        //  Scan for peripherals
        BleManager.shared.startScan()
        updateScannedPeripherals()
        
        //  Make sure the tab bar is visible
        self.hidesBottomBarWhenPushed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Stop scanning
        BleManager.shared.stopScan()
        
        // Ble Notifications
        registerNotifications(enabled: false)
        
        // Clear peripherals
        peripheralList.clear()
        isRowDetailOpenForPeripheral.removeAll()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  Calculate the number of cells
        if selectedPeripheral == nil {      // Dont update while a peripheral has been selected
            WatchSessionManager.shared.updateApplicationContext(mode: .scan)
        }
        
        //print("Count: \(peripheralList.filteredPeripherals(forceUpdate: false).count)")
        return peripheralList.filteredPeripherals(forceUpdate: false).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  Create a cell of type AvailableDevicesTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableDevice", for: indexPath) as! AvailableDevicesTableViewCell
        
        //  Get the actual peripheral object
        let peripheral = peripheralList.filteredPeripherals(forceUpdate: false)[indexPath.row]
        let localizationManager = LocalizationManager.shared
        
        //  Now need to check if the peripheral has been saved
        let saved = savedDevices[peripheral.identifier] != nil
        
        //  If it is saved, change the text and set subtitle accordingly
        if saved {
            //  Set the device name to what was saved
            cell.deviceName.text = savedDevices[peripheral.identifier]?.name!
        }
        else{
            //  Set the device name
            cell.deviceName.text = peripheral.name ?? localizationManager.localizedString("scanner_unnamed")
        }
        
        //  Send the cell what the subtitle should be and the image
        cell.signalImage.image = RssiUI.signalImage(for: peripheral.rssi)
        cell.setSubtitle(text: peripheral.name ?? localizationManager.localizedString("scanner_unnamed"), saved: saved)
        
        
        //  ***DEBUG
        //print(peripheral.name ?? localizationManager.localizedString("scanner_unnamed"))
        //print(subtitle ?? "subtitle undefined")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  Grab the peripheral that was selected
        let peripheral = peripheralList.filteredPeripherals(forceUpdate: false)[indexPath.row]
        
        //  Display what peripheral was selected
        print("Selected \(peripheral.name ?? "No name available")")
        
        //  Save the peripheral if necessary
        if savedDevices[peripheral.identifier] == nil {
            //  Not currently saved
            print("true")
            savePeripheralPrompt(peripheral: peripheral)
        }
        
        //  Connect to the peripheral
        connect(peripheral: peripheral)
        
        //        let connectToDevice = UARTViewController()
        //        connectToDevice.deviceName.text = peripheral.name ?? "No name available"
        //        navigationController?.pushViewController(connectToDevice, animated: true)
    }
    
    //  Get saved peripherals
    func getSavedPeripherals(){
        print("Trying to get peripherals")
        
        //  Get ready to get the saved peripherals
        let fetchSavedPeripheral = NSFetchRequest<SavedPeripheral>(entityName: "SavedPeripheral")
        
        do{
            //  Get the saved devices
            let devices = try PersistenceService.context.fetch(fetchSavedPeripheral)
            
            //  Add the uuids to the array
            for device in devices {
                print(device.name ?? "No name")
                savedDevices[device.uuid!] = device
            }
        }catch {}
    }
    
    @objc func onTableRefresh(_ sender: AnyObject) {
        refreshPeripherals()
        refreshController.endRefreshing()
    }
    
    fileprivate func refreshPeripherals() {
        isRowDetailOpenForPeripheral.removeAll()
        BleManager.shared.refreshPeripherals()
        reloadBaseTable()
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
        
        //        print("Filtered: \(peripheralList.filteredPeripherals(forceUpdate: false).count)")
    }
    
    
    
    // MARK: - Navigation
    //    func loadDetailRootController() {
    //        detailRootController = self.storyboard?.instantiateViewController(withIdentifier: "PeripheralModulesNavigationController")
    //    }
    //
    fileprivate func showPeripheralDetails() {
        
        //  Create the view to push now that a device has been connected
        let connectToDevice = ConnectedDeviceViewController()
        
        //  Send some initial data
        connectToDevice.selectedPeripheral = selectedPeripheral
        
        //  Hide the tab bar when pushed and then push the view
        connectToDevice.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(connectToDevice, animated: true)
        
        //        // Watch
        //        if !isMultiConnectEnabled {
        //            WatchSessionManager.shared.updateApplicationContext(mode: .connected)
        //        }
        //
        //        detailRootController = self.storyboard?.instantiateViewController(withIdentifier: "PeripheralModulesNavigationController")
        //        if let peripheralModulesNavigationController = detailRootController as? UINavigationController, let peripheralModulesViewController = peripheralModulesNavigationController.topViewController as? PeripheralModulesViewController {
        //            peripheralModulesViewController.blePeripheral = selectedPeripheral
        //            showDetailViewController(peripheralModulesNavigationController, sender: self)
        //        }
    }
    
    fileprivate func dismissInfoDialog(completion: (() -> Void)? = nil) {
        guard infoAlertController != nil else {
            completion?()
            return
        }
        
        infoAlertController?.dismiss(animated: true, completion: completion)
        infoAlertController = nil
    }
    
    // MARK: - Check Updates
    private func startUpdatesCheck(peripheral: BlePeripheral) {
        DLog("Check firmware updates")
        // Refresh available updates
        firmwareUpdater.checkUpdatesForPeripheral(peripheral, delegate: self as FirmwareUpdaterDelegate, shouldDiscoverServices: false, shouldRecommendBetaReleases: false, versionToIgnore: Preferences.softwareUpdateIgnoredVersion)
    }
    
    fileprivate func showUpdateAvailableForRelease(_ latestRelease: FirmwareInfo) {
        let localizationManager = LocalizationManager.shared
        let alert = UIAlertController(title: localizationManager.localizedString("autoupdate_title"),
                                      message: String(format: localizationManager.localizedString("autoupdate_description_format"), latestRelease.version),
                                      preferredStyle: UIAlertController.Style.alert)
        /*
         alert.addAction(UIAlertAction(title: localizationManager.localizedString("autoupdate_update"), style: UIAlertAction.Style.default, handler: { [unowned self] _ in
         self.showPeripheralUpdate()
         }))
         alert.addAction(UIAlertAction(title: localizationManager.localizedString("autoupdate_later"), style: UIAlertAction.Style.default, handler: { [unowned self] _ in
         self.showPeripheralDetails()
         }))*/
        alert.addAction(UIAlertAction(title: localizationManager.localizedString("autoupdate_ignore"), style: UIAlertAction.Style.cancel, handler: { [unowned self] _ in
            Preferences.softwareUpdateIgnoredVersion = latestRelease.version
            self.showPeripheralDetails()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //    fileprivate func showPeripheralUpdate() {
    //        // Watch
    //        if !isMultiConnectEnabled {
    //            WatchSessionManager.shared.updateApplicationContext(mode: .connected)
    //        }
    //
    //        detailRootController = self.storyboard?.instantiateViewController(withIdentifier: "PeripheralModulesNavigationController")
    //        if let peripheralModulesNavigationController = detailRootController as? UINavigationController, let peripheralModulesViewController = peripheralModulesNavigationController.topViewController as? PeripheralModulesViewController {
    //            peripheralModulesViewController.blePeripheral = selectedPeripheral
    //
    //            if let dfuViewController = self.storyboard!.instantiateViewController(withIdentifier: "DfuModeViewController") as? DfuModeViewController {
    //                dfuViewController.blePeripheral = selectedPeripheral
    //                peripheralModulesNavigationController.viewControllers = [peripheralModulesViewController, dfuViewController]
    //            }
    //            showDetailViewController(peripheralModulesNavigationController, sender: self)
    //        }
    //    }
    
    fileprivate func presentInfoDialog(title: String, peripheral: BlePeripheral) {
        if infoAlertController != nil {
            infoAlertController?.dismiss(animated: true, completion: nil)
        }
        
        infoAlertController = UIAlertController(title: nil, message: title, preferredStyle: .alert)
        infoAlertController!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            BleManager.shared.disconnect(from: peripheral)
            //BleManager.sharedInstance.refreshPeripherals()      // Force refresh because they wont reappear. Check why is this happening
        }))
        present(infoAlertController!, animated: true, completion:nil)
    }
    
    
    
}

//  MARK: UIScrollViewDelegate
extension AvailableDevicesViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isBaseTableScrolling = true
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isBaseTableScrolling = false
        
        if isScannerTableWaitingForReload {
            reloadBaseTable()
        }
    }
}

//  Mark: Adafruit Bluetooth Connection
extension AvailableDevicesViewController{
    //  Setting up the device
    private func discoverServices(peripheral: BlePeripheral) {
        DLog("Discovering services")
        
        peripheral.discover(serviceUuids: nil) { [weak self] error in
            guard let context = self else { return }
            let localizationManager = LocalizationManager.shared
            
            DispatchQueue.main.async {
                guard error == nil else {
                    DLog("Error initializing peripheral")
                    context.dismiss(animated: true, completion: { [weak self] () -> Void in
                        if let context = self {
                            showErrorAlert(from: context, title: localizationManager.localizedString("dialog_error"), message: localizationManager.localizedString("peripheraldetails_errordiscoveringservices"))
                            BleManager.shared.disconnect(from: peripheral)
                        }
                    })
                    return
                }
                
                if context.isMultiConnectEnabled {
                    context.dismissInfoDialog {
                    }
                } else {
                    // Check updates if needed
                    context.infoAlertController?.message = localizationManager.localizedString("peripheraldetails_checkingupdates")
                    context.startUpdatesCheck(peripheral: peripheral)
                }
            }
        }
    }
    
    // MARK: - BLE Notifications
    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
            didUpdateBleStateObserver = notificationCenter.addObserver(forName: .didUpdateBleState, object: nil, queue: .main, using: {[weak self] _ in self?.didUpdateBleState()})
            didDiscoverPeripheralObserver = notificationCenter.addObserver(forName: .didDiscoverPeripheral, object: nil, queue: .main, using: {[weak self] _ in self?.didDiscoverPeripheral()})
            willConnectToPeripheralObserver = notificationCenter.addObserver(forName: .willConnectToPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.willConnectToPeripheral(notification: notification)})
            didConnectToPeripheralObserver = notificationCenter.addObserver(forName: .didConnectToPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didConnectToPeripheral(notification: notification)})
            didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
            peripheralDidUpdateNameObserver = notificationCenter.addObserver(forName: .peripheralDidUpdateName, object: nil, queue: .main, using: {[weak self] notification in self?.peripheralDidUpdateName(notification: notification)})
        } else {
            if let didUpdateBleStateObserver = didUpdateBleStateObserver {notificationCenter.removeObserver(didUpdateBleStateObserver)}
            if let didDiscoverPeripheralObserver = didDiscoverPeripheralObserver {notificationCenter.removeObserver(didDiscoverPeripheralObserver)}
            if let willConnectToPeripheralObserver = willConnectToPeripheralObserver {notificationCenter.removeObserver(willConnectToPeripheralObserver)}
            if let didConnectToPeripheralObserver = didConnectToPeripheralObserver {notificationCenter.removeObserver(didConnectToPeripheralObserver)}
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
            if let peripheralDidUpdateNameObserver = peripheralDidUpdateNameObserver {notificationCenter.removeObserver(peripheralDidUpdateNameObserver)}
        }
    }
    
    private func didUpdateBleState() {
        guard let state = BleManager.shared.centralManager?.state else { return }
        
        // Check if there is any error
        var errorMessageId: String?
        switch state {
        case .unsupported:
            errorMessageId = "bluetooth_unsupported"
        case .unauthorized:
            errorMessageId = "bluetooth_notauthorized"
        case .poweredOff:
            errorMessageId = "bluetooth_poweredoff"
        default:
            errorMessageId = nil
        }
        
        // Show alert if error found
        if let errorMessageId = errorMessageId {
            let localizationManager = LocalizationManager.shared
            let errorMessage = localizationManager.localizedString(errorMessageId)
            DLog("Error: \(errorMessage)")
            
            // Reload peripherals
            refreshPeripherals()
            
            // Show error
            let alertController = UIAlertController(title: localizationManager.localizedString("dialog_error"), message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: localizationManager.localizedString("dialog_ok"), style: .default, handler: { (_) -> Void in
                if let navController = self.splitViewController?.viewControllers[0] as? UINavigationController {
                    navController.popViewController(animated: true)
                }
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func didDiscoverPeripheral(){
        updateScannedPeripherals()
    }
    
    private func willConnectToPeripheral(notification: Notification) {
        guard let peripheral = BleManager.shared.peripheral(from: notification) else { return }
        presentInfoDialog(title: LocalizationManager.shared.localizedString("peripheraldetails_connecting"), peripheral: peripheral)
    }
    
    func ConnectToDevice(){
        //  Use this function to segue from current view controller to UART
        let connectToDevice = UARTViewController()
        navigationController?.pushViewController(connectToDevice, animated: true)
    }
    
    fileprivate func connect(peripheral: BlePeripheral) {
        // Connect to selected peripheral
        selectedPeripheral = peripheral
        BleManager.shared.connect(to: peripheral)
        reloadBaseTable()
    }
    
    fileprivate func disconnect(peripheral: BlePeripheral) {
        selectedPeripheral = nil
        BleManager.shared.disconnect(from: peripheral)
        reloadBaseTable()
    }
    
    private func didConnectToPeripheral(notification: Notification) {
        guard let selectedPeripheral = selectedPeripheral, let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, selectedPeripheral.identifier == identifier else {
            DLog("Connected to an unexpected peripheral")
            return
        }
        
        // Discover services
        infoAlertController?.message = LocalizationManager.shared.localizedString("peripheraldetails_discoveringservices")
        discoverServices(peripheral: selectedPeripheral)
    }
    
    private func didDisconnectFromPeripheral(notification: Notification) {
        let peripheral = BleManager.shared.peripheral(from: notification)
        let currentlyConnectedPeripheralsCount = BleManager.shared.connectedPeripherals().count
        
        guard let selectedPeripheral = selectedPeripheral, selectedPeripheral.identifier == peripheral?.identifier || currentlyConnectedPeripheralsCount == 0 else {        // If selected peripheral is disconnected or if there are no peripherals connected (after a failed dfu update)
            return
        }
        
        // Clear selected peripheral
        self.selectedPeripheral = nil
        
        // Watch
        WatchSessionManager.shared.updateApplicationContext(mode: .scan)
        
        // Dismiss any info open dialogs
        infoAlertController?.dismiss(animated: true, completion: nil)
        infoAlertController = nil
        
        // Reload table
        reloadBaseTable()
    }
    
    private func peripheralDidUpdateName(notification: Notification) {
        let name = notification.userInfo?[BlePeripheral.NotificationUserInfoKey.name.rawValue] as? String
        DLog("centralManager peripheralDidUpdateName: \(name ?? "<unknown>")")
        
        DispatchQueue.main.async {
            // Reload table
            self.reloadBaseTable()
        }
    }
}

// MARK: - FirmwareUpdaterDelegate
extension AvailableDevicesViewController: FirmwareUpdaterDelegate {
    
    func onFirmwareUpdateAvailable(isUpdateAvailable: Bool, latestRelease: FirmwareInfo?, deviceDfuInfo: DeviceDfuInfo?) {
        
        DLog("FirmwareUpdaterDelegate isUpdateAvailable: \(isUpdateAvailable)")
        
        DispatchQueue.main.async {
            self.dismissInfoDialog {
                if isUpdateAvailable, let latestRelease = latestRelease {
                    self.showUpdateAvailableForRelease(latestRelease)
                } else {
                    self.showPeripheralDetails()
                }
            }
        }
    }
}

//  MARK: - Saving Peripherals
extension AvailableDevicesViewController {
    func savePeripheralPrompt(peripheral: BlePeripheral){
        //  Create localization manager
        let localizationManager = LocalizationManager.shared
        
        //  Create an alert for the user
        let alert = UIAlertController(title: "Save Device", message: "Would you like to save the device under a different name? If yes, please enter the name below.", preferredStyle: .alert)
        alert.addTextField{ (textfield) in
            textfield.placeholder = peripheral.name ?? localizationManager.localizedString("scanner_unnamed")
        }
        
        //  For right now, the new name will be the current name unless changed
        let newNameAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            //  Got the name, now set up to save
            let newPeripheral = SavedPeripheral(context: PersistenceService.context)
            newPeripheral.name = alert.textFields!.first!.text ?? " "
            newPeripheral.uuid = peripheral.identifier
        }
        let sameNameAction = UIAlertAction(title: "No", style: .default){ (_) in
            let newPeripheral = SavedPeripheral(context: PersistenceService.context)
            newPeripheral.name = peripheral.name ?? localizationManager.localizedString("scanner_unnamed")
            newPeripheral.uuid = peripheral.identifier
        }
        
        //  Add the actions to the alert
        alert.addAction(newNameAction)
        alert.addAction(sameNameAction)
        
        //  Present to the user
        self.present(alert, animated: true, completion: nil)
        
        //  All data is set, save the context
        PersistenceService.saveContext()
    }
    
    
    
    
}
