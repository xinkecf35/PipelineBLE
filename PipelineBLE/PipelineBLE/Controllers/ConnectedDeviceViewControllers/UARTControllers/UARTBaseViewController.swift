//
//  UARTBaseViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/28/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import UIKit
import UIColor_Hex

class UARTBaseViewController: UIViewController {
    
    //  UI Components
    private let pageTitle = "UART"
    let comTextView: UITextView = {
        let textView = UITextView()
        textView.returnKeyType = .done
        //textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.borderStyle = .line
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var originalHeight: CGFloat?
    
    fileprivate static var dataRxFont = UIFont(name: "CourierNewPSMT", size: 14)!
    fileprivate static var dataTxFont = UIFont(name: "CourierNewPS-BoldMT", size: 14)!
    
    weak var blePeripheral: BlePeripheral?
    internal var uartData: UartPacketManagerBase!
    fileprivate let timestampDateFormatter = DateFormatter()
    fileprivate var tableCachedDataBuffer: [UartPacket]?
    fileprivate var textCachedBuffer = NSMutableAttributedString()
    
    private let keyboardPositionNotifier = KeyboardPositionNotifier()

    override func viewDidLoad() {
        super.viewDidLoad()

        //  Set up the standard UI
        configureUI()
        
        //  Make self delegate to keyboard and textview
        keyboardPositionNotifier.delegate = self
        inputTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotifications(enabled: true)
        
        // UI
        reloadDataUI()
        
        // Enable Uart
        setupUart()
    }
    
    // MARK: - BLE Notifications
    private weak var didUpdatePreferencesObserver: NSObjectProtocol?
    
    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
            didUpdatePreferencesObserver = notificationCenter.addObserver(forName: .didUpdatePreferences, object: nil, queue: .main) { [weak self] _ in
                self?.reloadDataUI()
            }
        } else {
            if let didUpdatePreferencesObserver = didUpdatePreferencesObserver {notificationCenter.removeObserver(didUpdatePreferencesObserver)}
        }
    }
    
    internal func isInMultiUartMode() -> Bool {
        assert(false, "Should be implemented by subclasses")
        return false
    }
    
    internal func setupUart() {
        assert(false, "Should be implemented by subclasses")
    }
    
    // MARK: - UI Updates
    private func reloadDataUI() {
        
        textCachedBuffer.setAttributedString(NSAttributedString())
        let dataPackets = uartData.packetsCache()
        for dataPacket in dataPackets {
            onUartPacketText(dataPacket)
        }
        comTextView.attributedText = textCachedBuffer
        reloadData()
        
        
        //updateBytesUI()
    }
    
    /*  Will eventually use for keeping track of bytes sent
    fileprivate func updateBytesUI() {
        let localizationManager = LocalizationManager.shared
        let sentBytesMessage = String(format: localizationManager.localizedString("uart_sentbytes_format"), arguments: [uartData.sentBytes])
        let receivedBytesMessage = String(format: localizationManager.localizedString("uart_receivedbytes_format"), arguments: [uartData.receivedBytes])
        
        //statsLabel.text = String(format: "%@     %@", arguments: [sentBytesMessage, receivedBytesMessage])
    }*/
    
    // MARK: - Style
    internal func colorForPacket(packet: UartPacket) -> UIColor {
        assert(false, "Should be implemented by subclasses")
        return .black
    }
    
    fileprivate func fontForPacket(packet: UartPacket) -> UIFont {
        let font = packet.mode == .tx ? UARTViewController.dataTxFont : UARTViewController.dataRxFont
        return font
    }

}

//  MARK: - UI Configuration
extension UARTBaseViewController {
    
    func configureUI(){
        //  Set up the standard UI
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        originalHeight = view.frame.height
        
        //  Add subviews to the main view
        view.addSubview(comTextView)
        view.addSubview(inputTextField)
        view.addSubview(sendButton)
        view.addSubview(clearButton)
        
        //  Set up constraints for com box
        var textViewConstraint = navigationController?.navigationBar.frame.height ?? 20
        textViewConstraint += 30
        comTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: textViewConstraint).isActive = true
        comTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        comTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        comTextView.bottomAnchor.constraint(equalTo: inputTextField.topAnchor, constant: -5).isActive = true
        comTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        comTextView.backgroundColor = .blue
        
        //  Set up constraints for the input text field
        inputTextField.topAnchor.constraint(equalTo: comTextView.bottomAnchor, constant: 5).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        inputTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5).isActive = true
        //inputTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        
        //  Set up constraints for the send button
        sendButton.topAnchor.constraint(equalTo: comTextView.bottomAnchor, constant: 5).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        sendButton.leadingAnchor.constraint(equalTo: inputTextField.trailingAnchor, constant: 5).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -5).isActive = true
        
        
        //  Set up constraints for the clear button
        clearButton.topAnchor.constraint(equalTo: comTextView.bottomAnchor, constant: 5).isActive = true
        clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: 5).isActive = true
        
        //  Changing the size of the input text field
        let inputSize = view.frame.width-30-sendButton.frame.width-clearButton.frame.width
        inputTextField.widthAnchor.constraint(equalToConstant: inputSize)
        
        //  Add actions to buttons
        
        
    }
}

extension UARTBaseViewController: KeyboardPositionNotifierDelegate {
    
    func onKeyboardPositionChanged(keyboardFrame: CGRect, keyboardShown: Bool) {
        if keyboardShown{
            let spacerHeight = keyboardFrame.height
            view.frame.size = CGSize(width: view.frame.width, height: view.frame.height-spacerHeight)
        }
        else {
            view.frame.size = CGSize(width: view.frame.width, height: originalHeight!)
        }
    }
}

extension UARTBaseViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UARTBaseViewController: UartPacketManagerDelegate{
    func onUartPacket(_ packet: UartPacket) {
        // Check that the view has been initialized before updating UI
        guard isViewLoaded && view.window != nil else { return }
        
        onUartPacketText(packet)
        self.enh_throttledReloadData()      // it will call self.reloadData without overloading the main thread with calls
    }
    
    @objc func reloadData() {
        comTextView.attributedText = textCachedBuffer
            
        let textLength = textCachedBuffer.length
        if textLength > 0 {
            let range = NSMakeRange(textLength - 1, 1)
            comTextView.scrollRangeToVisible(range)
        }
    }
    
    fileprivate func onUartPacketText(_ packet: UartPacket) {
        guard Preferences.uartIsEchoEnabled || packet.mode == .rx else { return }
        
        let color = colorForPacket(packet: packet)
        let font = fontForPacket(packet: packet)
        
        if let attributedString = attributedStringFromData(packet.data, useHexMode: Preferences.uartIsInHexMode, color: color, font: font) {
            textCachedBuffer.append(attributedString)
        }
    }
}
