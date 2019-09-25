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
        plot.translatesAutoresizingMaskIntoConstraints = false
        return plot
    }()
    var sliderLabel: UILabel = {
        let label = UILabel()
        label.text = "Auto Scroll:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var scrollLabel: UILabel = {
        let label = UILabel()
        label.text = "Width:"
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
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    weak var blePeripheral: BlePeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Set up UI
        configureUI()
        
    }
    
    //  MARK: - Set up the UI
    func configureUI(){
        //  Set some initial parameters
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        //  Add items to the view
        view.addSubview(plot)
        view.addSubview(scrollLabel)
        view.addSubview(sliderLabel)
        view.addSubview(autoScroll)
        view.addSubview(maxEntries)
        
        //  Add plotter view
        var textViewConstraint = navigationController?.navigationBar.frame.height ?? 20
        textViewConstraint += 30
        plot.topAnchor.constraint(equalTo: view.topAnchor, constant: textViewConstraint).isActive = true
        plot.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        plot.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        plot.bottomAnchor.constraint(equalTo: scrollLabel.topAnchor, constant: -5).isActive = true
        
        //  Add scroll label
        genericConstraints(top: plot, middle: scrollLabel, bottom: view, width: true)
        scrollLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        scrollLabel.trailingAnchor.constraint(equalTo: autoScroll.leadingAnchor, constant: -5).isActive = true
        
        //  Add auto scroll slider
        genericConstraints(top: plot, middle: autoScroll, bottom: view, width: false)
        autoScroll.leadingAnchor.constraint(equalTo: scrollLabel.trailingAnchor, constant: 5).isActive = true
        autoScroll.trailingAnchor.constraint(equalTo: sliderLabel.leadingAnchor, constant: -5).isActive = true
        
        //  Add max entries slider label
        genericConstraints(top: plot, middle: autoScroll, bottom: view, width: true)
        autoScroll.leadingAnchor.constraint(equalTo: autoScroll.trailingAnchor, constant: 5).isActive = true
        autoScroll.trailingAnchor.constraint(equalTo: maxEntries.leadingAnchor, constant: -5).isActive = true
        
        //  Add the slider for max entries
        genericConstraints(top: plot, middle: maxEntries, bottom: view, width: false)
        maxEntries.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        maxEntries.leadingAnchor.constraint(equalTo: autoScroll.trailingAnchor, constant: 5).isActive = true
    }
    
    func genericConstraints(top: UIView, middle: UIView, bottom: UIView, width: Bool){
        //  Automatically apply generic constraints
        middle.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 5).isActive = true
        middle.bottomAnchor.constraint(equalTo: bottom.bottomAnchor, constant: -10).isActive = true
        if width {
            middle.widthAnchor.constraint(equalToConstant: middle.intrinsicContentSize.width + 5).isActive = true
        }
        
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
