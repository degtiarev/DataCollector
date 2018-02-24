//
//  Sensor+CoreDataProperties.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 24/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//
//

import Foundation
import CoreData


extension Sensor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sensor> {
        return NSFetchRequest<Sensor>(entityName: "Sensor")
    }

    @NSManaged public var id: Int32
    @NSManaged public var toSensorData: SensorData?

}
