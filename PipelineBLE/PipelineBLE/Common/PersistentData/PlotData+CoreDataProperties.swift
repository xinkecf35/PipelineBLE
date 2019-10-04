//
//  PlotData+CoreDataProperties.swift
//  
//
//  Created by Samuel Peterson on 10/4/19.
//
//

import Foundation
import CoreData


extension PlotData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlotData> {
        return NSFetchRequest<PlotData>(entityName: "PlotData")
    }

    @NSManaged public var data: NSObject

}
