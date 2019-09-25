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
    var comTextView: UITextView = {
        let textView = UITextView()
        textView.returnKeyType = .done
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    var inputTextField: UARTTextField = {
        let textField = UARTTextField()
        return textField
    }()
    var sendButton: UARTButtons = {
        let button = UARTButtons()
        button.configureVisual(text: "Send")
        return button
    }()
    var clearButton: UARTButtons = {
        let button = UARTButtons()
        button.configureVisual(text: "Clear")
        return button
    }()
    var saveBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onClickSave(_:)))
        return button
    }()
    
    
    var originalHeight: CGFloat?
    
    fileprivate static var dataRxFont = UIFont(name: "CourierNewPSMT", size: 18)!
    fileprivate static var dataTxFont = UIFont(name: "CourierNewPS-BoldMT", size: 18)!
    
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
        
        //  Configure the Navigation control bar buttons
        navigationItem.rightBarButtonItem = saveBarButton
        
        // Enable Uart
        setupUart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //  Cancel notifications
        registerNotifications(enabled: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //  No need to reload the view
        comTextView.enh_cancelPendingReload()
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
    
    internal func send(message: String){
        assert(false, "Should be implemented by subclasses")
    }
    
    fileprivate func fontForPacket(packet: UartPacket) -> UIFont {
        let font = packet.mode == .tx ? UARTViewController.dataTxFont : UARTViewController.dataRxFont
        return font
    }
    
    internal func updateUartReadyUI(isReady: Bool) {
        inputTextField.isEnabled = isReady
        //inputTextField.backgroundColor = isReady ? UIColor.white : UIColor.black.withAlphaComponent(0.1)
        sendButton.isEnabled = isReady
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
        //comTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)

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
        sendButton.widthAnchor.constraint(equalToConstant: sendButton.intrinsicContentSize.width + 10).isActive = true
        clearButton.widthAnchor.constraint(equalToConstant: clearButton.intrinsicContentSize.width + 10).isActive = true
    }
}

extension UARTBaseViewController {
    //  Keep track of all actions
    @objc func onClickSend(_ sender: AnyObject) {
        //guard let blePeripheral = blePeripheral else { return }
        
        var newText = inputTextField.text ?? ""
        
        // Eol
        if Preferences.uartIsAutomaticEolEnabled {
            newText += Preferences.uartEolCharacters
        }
        
        send(message: newText)
        
        inputTextField.text = ""
        inputTextField.resignFirstResponder()
    }
    
    @objc func onClickClear(_ sender: AnyObject) {
        uartData.clearPacketsCache()
        reloadDataUI()
    }
    
    func onInputTextFieldEdidtingDidEndOnExit(_ sender: UITextField) {
        onClickSend(sender)
    }
    
    @objc func onClickSave(_ sender: AnyObject){
        //  Save the text that is in the textfield currently
        
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
