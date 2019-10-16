//
//  PastDataViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/8/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import CoreData

class PastDataViewController: UIViewController {

    var uuids = [UUID]()
        
    private let pageTitle = "Past Data"
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //  Set some initial parameters
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
            
        //  Gather data from file
        gatherData()
            
        //  Set up the UI
        setupUI()
    }
        
    //  Gather data
    func gatherData(){
        let fetchUart = NSFetchRequest<UARTData>(entityName: "UARTData")
        let fetchPlot = NSFetchRequest<PlotData>(entityName: "PlotData")
            
        do {
            print("Trying to load data")
            //  Get the saved data
            let savedUartData = try PersistenceService.context.fetch(fetchUart)
            let savedPlotData = try PersistenceService.context.fetch(fetchPlot)
                
            //  Add the uuid to the list
            for data in savedUartData {
                if !uuids.contains(data.deviceID) {
                    print("added")
                    //  Don't have the uuid, so add it
                    uuids.append(data.deviceID)
                }
            }
            //  Add the data to the savedData data structure
            for data in savedPlotData {
                if !uuids.contains(data.deviceID) {
                    print("added")
                    //  Don't have the uuid, so add it
                    uuids.append(data.deviceID)
                }
            }
        } catch {}
    }
        
    //  MARK: - UI Setup
    func setupUI(){
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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

extension PastDataViewController: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuids.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = String(describing: uuids[indexPath.row])
        
        //  TODO: Will need to check the UUID against the names we have stored for them
        //  rn just use the UUID
        
        //  Create a cell to display the data that has been saved for that device
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SavedData")
        cell.textLabel?.text = text
        return cell
    }
        
        
        
}

extension PastDataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        //  Create a new saved data controller
        let savedDataController = SavedDataViewController()
        self.storyboard?.instantiateViewController(withIdentifier: "SavedDataViewController")
        
        //  Give the view the data it needs
        savedDataController.deviceUUID = uuids[indexPath.row]
        
        //  Finally push the view
        navigationController?.pushViewController(savedDataController, animated: true)
    }
}
