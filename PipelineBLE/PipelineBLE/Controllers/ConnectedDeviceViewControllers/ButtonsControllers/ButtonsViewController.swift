//
//  ButtonsViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/22/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class ButtonsViewController: UIViewController {

    private let pageTitle = "Buttons"
    
    let deviceName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Buttons - This page is currently under development"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var blePeripheral: BlePeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set some initial parameters
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        // Do any additional setup after loading the view.
        view.addSubview(deviceName)
        deviceName.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        deviceName.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        deviceName.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        deviceName.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }

}
