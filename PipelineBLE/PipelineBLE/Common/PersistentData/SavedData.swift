//
//  SavedData.swift
//  PipelineBLE
//
//  Created by Samuel Peterson on 9/23/19.
//  Copyright © 2019 Samuel Peterson. All rights reserved.
//

import UIKit

class SavedData: NSObject {

    //  Data to save
    var id: String?
    var advertisedName: String?
    var data: String?
    var date: String?
    var peripheral: String?
    var deviceID: UUID?
    
    override init(){
        super.init()
    }
    
    func initialize(id: String, data: String, peripheral: BlePeripheral) {
        self.id = id
        self.advertisedName = peripheral.name
        self.data = data
        
        //  Keep track of the day the data was saved
        let day = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        date = format.string(from: day)
        
        //  Localize the peripheral name
        let localizationManager = LocalizationManager.shared
        self.peripheral = peripheral.name ?? localizationManager.localizedString("scanner_unnamed")
        
        //  Save the device unique ID
        self.deviceID = peripheral.identifier
        
    }
}
