//
//  ViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/7/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import CoreBluetooth

class SavedDevicesViewController: UITableViewController {
    
    private let pageTitle = "Saved Devices"
    
    let deviceName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "This page is under development"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set some initial parameters
        print("Saved Devices")
        //view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        // Do any additional setup after loading the view.
        view.addSubview(deviceName)
        deviceName.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        deviceName.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        deviceName.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        deviceName.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
}
