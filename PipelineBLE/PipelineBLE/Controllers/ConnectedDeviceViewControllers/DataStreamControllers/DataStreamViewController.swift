//
//  DataStreamViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 8/22/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit
import Charts

class DataStreamViewController: UIViewController {

    private let pageTitle = "Data Stream"
    var plot: LineChartView = {
        let plot = LineChartView()
        plot.borderLineWidth = 1
        plot.borderColor = .blue
        plot.translatesAutoresizingMaskIntoConstraints = false
        return plot
    }()
    var sliderLabel: UILabel = {
        let label = UILabel()
        label.text = "Width:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var scrollLabel: UILabel = {
        let label = UILabel()
        label.text = "Auto Scroll:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var autoScroll: UISwitch = {
        let scroll = UISwitch()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    var maxEntries: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 100
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    weak var blePeripheral: BlePeripheral?
    fileprivate var dataManager: UartDataManager!
    fileprivate var lineDashForPeripheral = [UUID: [CGFloat]?]()
    fileprivate var startTime: CFAbsoluteTime!
    fileprivate var dataSetForPeripherals = [UUID: [LineChartDataSet]]()
    fileprivate var lastUpdatedData: LineChartDataSet?
    fileprivate var visibleInterval: TimeInterval = 30
    var isAutoScrollEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set up UI
        configureUI()
        
        //  Initialize Uart data manager
        dataManager = UartDataManager(delegate: self, isRxCacheEnabled: true)
        
        //  Configure the chart
        setUpChart()
        
        //  Get initial start time
        startTime = CFAbsoluteTimeGetCurrent()
        
        //  Add actions
        maxEntries.addTarget(self, action: #selector(onXScaleValueChanged(_:)), for: .valueChanged)
        autoScroll.addTarget(self, action: #selector(onAutoScrollChanged(_:)), for: .valueChanged)
        
        // UI
        autoScroll.isOn = isAutoScrollEnabled
        plot.dragEnabled = !isAutoScrollEnabled
        maxEntries.value = Float(visibleInterval)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //  Get UART ready
        setUpUART()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testCharts(){
        let data:[[Double]] = [[1,1],[2,3],[4,5]]
        var entries: [ChartDataEntry] = []
        var i = 0
        for d in data{
            
            
            print("Data: x(\(d[0])), y(\(d[1]))")
            entries.append(ChartDataEntry(x: d[0], y: d[1]))
            print("Data: x(\(entries[i].x)), y(\(entries[i].y))")
            i += 1
        }
        let dataSet = LineChartDataSet(entries: entries, label: "Test")
        dataSet.setColor(.red)
        let endData = LineChartData(dataSet: dataSet)
        plot.data = endData
        plot.data?.notifyDataChanged()
        plot.notifyDataSetChanged()
    }
    
    //  MARK: - Set up the UI
    func configureUI(){
        //  Set some initial parameters
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        //  Add items to the view
        view.addSubview(plot)
        view.addSubview(scrollLabel)
        view.addSubview(autoScroll)
        view.addSubview(sliderLabel)
        view.addSubview(maxEntries)
        
        //  Add plotter view
        var textViewConstraint = navigationController?.navigationBar.frame.height ?? 20
        textViewConstraint += 30
        plot.topAnchor.constraint(equalTo: view.topAnchor, constant: textViewConstraint).isActive = true
        plot.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        plot.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        plot.bottomAnchor.constraint(equalTo: scrollLabel.topAnchor, constant: -5).isActive = true
        
        //  Add scroll label
        genericConstraints(top: plot, middle: scrollLabel, bottom: view, width: false)
        scrollLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        scrollLabel.trailingAnchor.constraint(equalTo: autoScroll.leadingAnchor, constant: -5).isActive = true
        
        //  Add auto scroll slider
        genericConstraints(top: plot, middle: autoScroll, bottom: view, width: false)
        autoScroll.leadingAnchor.constraint(equalTo: scrollLabel.trailingAnchor, constant: 5).isActive = true
        autoScroll.trailingAnchor.constraint(equalTo: sliderLabel.leadingAnchor, constant: -5).isActive = true
        
        //  Add max entries slider label
        genericConstraints(top: plot, middle: sliderLabel, bottom: view, width: true)
        sliderLabel.leadingAnchor.constraint(equalTo: autoScroll.trailingAnchor, constant: 5).isActive = true
        sliderLabel.trailingAnchor.constraint(equalTo: maxEntries.leadingAnchor, constant: -5).isActive = true
        
        //  Add the slider for max entries
        genericConstraints(top: plot, middle: maxEntries, bottom: view, width: false)
        maxEntries.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        maxEntries.leadingAnchor.constraint(equalTo: sliderLabel.trailingAnchor, constant: 5).isActive = true
    }
    
    func genericConstraints(top: UIView, middle: UIView, bottom: UIView, width: Bool){
        //  Automatically apply generic constraints for top and bottom
        middle.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 5).isActive = true
        middle.bottomAnchor.constraint(equalTo: bottom.bottomAnchor, constant: -10).isActive = true
        if width {
            middle.widthAnchor.constraint(equalToConstant: middle.intrinsicContentSize.width).isActive = true
        }
    }
    
    func setUpChart(){
        //  Initialize the chart
        plot.delegate = self
        //plot.backgroundColor = .white
        plot.chartDescription?.enabled = false
        plot.xAxis.granularityEnabled = true
        plot.xAxis.granularity = 5
        plot.leftAxis.drawZeroLineEnabled = true
        //plot.setExtraOffsets(left: 10, top: 10, right: 10, bottom: 0)
        plot.legend.enabled = false
        plot.noDataText = "No data received"
    }
    
    func setUpUART(){
        //  Assign lines for the peripheral
        let lineDashes = UartStyle.defaultLineDashes()
        lineDashForPeripheral.removeAll()
        
        if let blePeripheral = blePeripheral {
            //  Assign a line for the peripheral
            lineDashForPeripheral[blePeripheral.identifier] = lineDashes.first!
            
            //  Enable UART for the peripheral
            blePeripheral.uartEnable(uartRxHandler: dataManager.rxDataReceived) { [weak self] error in
                guard let context = self else { return }

                DispatchQueue.main.async {
                    guard error == nil else {
                        DLog("Error initializing uart")
                        context.dismiss(animated: true, completion: { [weak self] in
                            guard let context = self else { return }
                            let localizationManager = LocalizationManager.shared
                            showErrorAlert(from: context, title: localizationManager.localizedString("dialog_error"), message: localizationManager.localizedString("uart_error_peripheralinit"))
                            
                            if let blePeripheral = context.blePeripheral {
                                BleManager.shared.disconnect(from: blePeripheral)
                            }
                        })
                        return
                    }

                    // Done
                    DLog("Uart enabled")
                }
            }
        }
    }
    
    func addEntry(peripheral: UUID, index: Int, value: Double, timestamp: CFAbsoluteTime){
        //  Create initial entry
        let entry = ChartDataEntry(x: timestamp, y: value)
        
        // See if the data set exists. If it does add, otherwise create new dataset
        var dataSetExists = false
        if let dataSets = dataSetForPeripherals[peripheral]{
            if index < dataSets.count{
                //  We know that the current dataset exists, add the data
                let dataSet = dataSets[index]
                let _ = dataSet.append(entry)
                
                dataSetExists = true
            }
        }
        
        if !dataSetExists{
            //  Add a dataset
            addDataSet(peripheral: peripheral, index: index, entry: entry)
            
            //  Update the data for the graph
            let allData = dataSetForPeripherals.flatMap {$0.1}
            DispatchQueue.main.async {
                self.plot.data = LineChartData(dataSets: allData)
            }
        }
        
        guard let dataSets = dataSetForPeripherals[peripheral], index < dataSets.count else { return }
        
        lastUpdatedData = dataSets[index]
    }
    
    func addDataSet(peripheral: UUID, index: Int, entry: ChartDataEntry){
        //  Create a new data set and add it to existing data
        let newDataSet = LineChartDataSet(entries: [entry], label: "Values[ \(peripheral.uuidString) : \(index)]")
        let _ = newDataSet.append(entry)
        
        newDataSet.drawCirclesEnabled = false
        newDataSet.drawValuesEnabled = false
        newDataSet.lineWidth = 2
        let colors = UartStyle.defaultColors()
        let color = colors[index % colors.count]
        newDataSet.setColor(color)
        newDataSet.lineDashLengths = lineDashForPeripheral[peripheral]!
        DLog("color: \(color.hexString()!)")
        
        //  Add the new data set to current data set
        if dataSetForPeripherals[peripheral] != nil{
            dataSetForPeripherals[peripheral]?.append(newDataSet)
        }
        else{
            //  No current data set, so just create new for peripheral
            dataSetForPeripherals[peripheral] = [newDataSet]
        }
    }
    
    func notifyDataSetChanged(){
        //  Signal that the data and the data set changed
        plot.data?.notifyDataChanged()
        
        self.plot.notifyDataSetChanged()
        
        
        //  Make sure the visible range is accurate
        plot.setVisibleXRangeMaximum(visibleInterval)
        plot.setVisibleXRangeMinimum(visibleInterval)
        
        guard let dataSet = lastUpdatedData else { return }

        //  Need to adjust view depending on autoscroll
        if isAutoScrollEnabled {
            //let xOffset = Double(dataSet.entryCount) - (context.numEntriesVisible-1)
            let xOffset = (dataSet.entries.last?.x ?? 0) - (visibleInterval-1)
            plot.moveViewToX(xOffset)
        }
    }
    
    //  MARK: - UI Actions
    @objc func onXScaleValueChanged(_ sender: UISlider) {
        visibleInterval = TimeInterval(sender.value)
        notifyDataSetChanged()
    }
    
    @objc func onAutoScrollChanged(_ sender: Any) {
        isAutoScrollEnabled = !isAutoScrollEnabled
        plot.dragEnabled = !isAutoScrollEnabled
        notifyDataSetChanged()
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

//  MARK: - UARTDataManager Delegate
extension DataStreamViewController: UartDataManagerDelegate{
    //  Byte buffer
    private static let kLineSeparator = Data([10])
    
    //  What to do when data is received
    func onUartRx(data: Data, peripheralIdentifier: UUID) {
        //  Store the data in the byte buffer
        guard let lastSeparatorRange = data.range(of: DataStreamViewController.kLineSeparator, options: .backwards, in: nil) else { return }
        

        let subData = data.subdata(in: 0..<lastSeparatorRange.upperBound)
        if let dataString = String(data: subData, encoding: .utf8) {
            //  Now need to clean the data of the extra characters
            let strings = dataString.replacingOccurrences(of: "\r", with: "").components(separatedBy: "\n") // ["100,100,100"],["10,10,10"]...
            
            let currentTime = CFAbsoluteTimeGetCurrent() - startTime
            
            //  Need to look through each line of strings
            for line in strings {
                //  Will need to grab all data from each line
                let dataPoints = line.components(separatedBy: CharacterSet(charactersIn: ",; "))
                var i = 0
                
                for pt in dataPoints{
                    //  Need to create the new data point and add to set
                    if let val = Double(pt){
                        addEntry(peripheral: peripheralIdentifier, index: i, value: val, timestamp: currentTime)
                        i = i + 1
                    }
                }
                //  Need to update the graph
                DispatchQueue.main.async {
                    self.notifyDataSetChanged()
                }
            }
        }
        
        dataManager.removeRxCacheFirst(n: lastSeparatorRange.upperBound+1, peripheralIdentifier: peripheralIdentifier)
    }
    
    
}

extension DataStreamViewController: ChartViewDelegate{
    
}
