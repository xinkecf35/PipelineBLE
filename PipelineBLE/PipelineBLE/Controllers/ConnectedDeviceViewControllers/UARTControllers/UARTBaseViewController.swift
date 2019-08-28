//
//  UARTBaseViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/28/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class UARTBaseViewController: UIViewController {
    
    //  UI Components
    private let pageTitle = "UART"
    let deviceName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Hello World"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let comTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var blePeripheral: BlePeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        //  Set up the standard UI
        configureUI()
        
        
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

//  MARK: - UI Configuration
extension UARTBaseViewController {
    func configureUI(){
        //  Set up the standard UI
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        // Do any additional setup after loading the view.
        
        
        /*
        view.addSubview(deviceName)
        deviceName.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        deviceName.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        deviceName.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        deviceName.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        */
    }
}
