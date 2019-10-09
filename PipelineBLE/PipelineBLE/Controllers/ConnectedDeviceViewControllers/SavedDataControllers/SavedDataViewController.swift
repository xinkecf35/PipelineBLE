//
//  SavedDataViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/22/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import CoreData

class SavedDataViewController: UIViewController {

    weak var blePeripheral: BlePeripheral?
    var uartData = [SavedData]()
    var plotData = [SavedData]()
    
    private let pageTitle = "Saved Data"
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
            
            //  Add the data to the savedData data structure for UART and plot data
            for data in savedUartData {
                print("Data uart: \(data.deviceID), \(String(describing: blePeripheral?.identifier))")
                
                if data.deviceID == blePeripheral?.identifier {
                    print("added")
                    //  Data UUID matches ble peripheral that is connected
                    uartData.append(data)
                }
            }
            //  Add the data to the savedData data structure
            for data in savedPlotData {
                print("Data plot")
                if data.deviceID == blePeripheral?.identifier {
                    //  Data UUID matches ble peripheral that is connected
                    plotData.append(data)
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

extension SavedDataViewController: UITableViewDataSource {
    //  Know what section we're in
    enum TableSection: Int {
        case plot = 0
        case uart = 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection(rawValue: section)! {
        case .plot:
            return plotData.count
        case .uart:
            return uartData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var text = ""
        var subtext = ""
        switch TableSection(rawValue: indexPath.section)! {
        case .plot:
            //  Need to grab data from plot data array
            text = plotData[indexPath.row].id
            subtext = plotData[indexPath.row].date
        case .uart:
            //  Need to grab data from uart array
            text = uartData[indexPath.row].id
            subtext = uartData[indexPath.row].date
        }
        //  Create a cell to display the data that has been saved for that device
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SavedData")
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = subtext
        return cell
    }
    
    
    
}

extension SavedDataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch TableSection(rawValue: indexPath.section)! {
        case .plot:
            //  Need to launch a view to display the plot data
            print("Display plot data")
        case .uart:
            //  Need to launch a view to display uart data
            print("Display uart data")
        }
    }
}
