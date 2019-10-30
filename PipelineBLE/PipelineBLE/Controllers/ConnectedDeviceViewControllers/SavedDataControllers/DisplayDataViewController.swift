//
//  DisplayDataViewController.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 10/16/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class DisplayDataViewController: UIViewController {
    
    //  UI Components
    var pageTitle = "Saved Data ID"
    var comTextView: UITextView = {
        let textView = UITextView()
        textView.returnKeyType = .done
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    var data: String = ""
    var exportButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the UI
        setUpUI()
    }
    
    // MARK: - Set Up UI
    func setUpUI(){
        //  Set background and title
        view.backgroundColor = .darkGray
        navigationItem.title = pageTitle
        
        //  Create export button
        exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onClickExport(_:)))
        navigationItem.rightBarButtonItem = exportButton
        
        //  Add items to screen
        view.addSubview(comTextView)
        
        //  Set the layout of the screen
        var textViewConstraint = navigationController?.navigationBar.frame.height ?? 20
        textViewConstraint += 35
        comTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: textViewConstraint).isActive = true
        comTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        comTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        comTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        
        comTextView.text = data
        comTextView.font = comTextView.font?.withSize(20)
    }
    
    //  MARK: - Actions
    @objc func onClickExport(_ export: UIBarButtonItem){
        //  Export button was pressed, call the export button class
        ExportData.exportData(view: self, button: exportButton, data: self.comTextView.text as NSObject)
    }

}
