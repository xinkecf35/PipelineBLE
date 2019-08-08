//
//  PastDataViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/8/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class PastDataViewController: UIViewController {

    private let pageTitle = "Past Data"
    
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
        print("Past Data")
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        // Do any additional setup after loading the view.
        view.addSubview(deviceName)
        deviceName.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        deviceName.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        deviceName.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        deviceName.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
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
