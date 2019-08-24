//
//  ConnectedDevicesTabViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/22/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class ConnectedDevicesTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //  Add all navigation controllers to the tab bar controller. Specify details about each
        viewControllers = [createNavController(title: "UART", imageName: "UART_Icon", rootView: UARTViewController()),
                           createNavController(title: "Data Stream", imageName: "Data_Stream_Icon", rootView: DataStreamViewController()),
                           createNavController(title: "Saved Data", imageName: "Past_Data_Icon", rootView: SavedDataViewController()),
                           createNavController(title: "Buttons", imageName: "Buttons_Icon", rootView: ButtonsViewController())]
    }
    
    private func createNavController(title: String, imageName: String, rootView: UIViewController) -> UINavigationController {
        //  Create navigation controller with given root view, title, and image
        let navController = UINavigationController(rootViewController: rootView)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
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
