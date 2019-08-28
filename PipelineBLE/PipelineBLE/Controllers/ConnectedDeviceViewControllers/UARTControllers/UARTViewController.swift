//
//  UARTViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/7/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class UARTViewController: UARTBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //  Set some initial parameters
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
        //  TODO: Need to fix this, causing some issues
        //let disconnectFromDevice = SavedDevicesViewController()
        //navigationController?.pushViewController(disconnectFromDevice, animated: true)
    }
    /*
    // MARK: - BLE Notifications
    private weak var willConnectToPeripheralObserver: NSObjectProtocol?
    private weak var willDisconnectFromPeripheralObserver: NSObjectProtocol?
    private weak var peripheralDidUpdateRssiObserver: NSObjectProtocol?
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?
    
    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            willConnectToPeripheralObserver = notificationCenter.addObserver(forName: .willConnectToPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.willConnectToPeripheral(notification: notification)})
            willDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .willDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.willDisconnectFromPeripheral(notification: notification)})
            peripheralDidUpdateRssiObserver = notificationCenter.addObserver(forName: .peripheralDidUpdateRssi, object: nil, queue: .main, using: {[weak self] notification in self?.peripheralDidUpdateRssi(notification: notification)})
            didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
            
        } else {
            if let willConnectToPeripheralObserver = willConnectToPeripheralObserver {notificationCenter.removeObserver(willConnectToPeripheralObserver)}
            if let willDisconnectFromPeripheralObserver = willDisconnectFromPeripheralObserver {notificationCenter.removeObserver(willDisconnectFromPeripheralObserver)}
            if let peripheralDidUpdateRssiObserver = peripheralDidUpdateRssiObserver {notificationCenter.removeObserver(peripheralDidUpdateRssiObserver)}
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }
    
    fileprivate func willConnectToPeripheral(notification: Notification) {
        guard let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, identifier == blePeripheral?.identifier else { return }
        
        if isInMultiUartMode() {
        } else {
            showEmpty(true)
            setConnecting(true)
        }
    }
    
    fileprivate func willDisconnectFromPeripheral(notification: Notification) {
        guard let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, identifier == blePeripheral?.identifier else { return }
        
        DLog("detail: peripheral willDisconnect")
        let isFullScreen = UIScreen.main.traitCollection.horizontalSizeClass == .compact
        if isFullScreen {       // executed when bluetooth is stopped
            
            // Back to peripheral list
            goBackToPeripheralList()
        } else {
            if connectionMode != .multiplePeripherals {
                blePeripheral = nil
            }
            showEmpty(true)
            setConnecting(false)
        }
    }
    
    fileprivate func peripheralDidUpdateRssi(notification: Notification) {
        guard let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, identifier == blePeripheral?.identifier else { return }
        
        // Update section
        baseTableView.reloadSections([TableSection.device.rawValue], with: .none)
    }
    
    private func didDisconnectFromPeripheral(notification: Notification) {
        guard let identifier = notification.userInfo?[BleManager.NotificationUserInfoKey.uuid.rawValue] as? UUID, identifier == blePeripheral?.identifier else { return }
        
        // Disable Rssi timer
        rssiRefreshTimer?.invalidate()
        rssiRefreshTimer = nil
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
