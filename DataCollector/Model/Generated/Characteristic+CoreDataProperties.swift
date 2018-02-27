//
//  Characteristic+CoreDataProperties.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 27/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//
//

import Foundation
import CoreData


extension Characteristic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Characteristic> {
        return NSFetchRequest<Characteristic>(entityName: "Characteristic")
    }

    @NSManaged public var x: Float
    @NSManaged public var y: Float
    @NSManaged public var z: Float
    @NSManaged public var toCharacteristicName: CharacteristicName?
    @NSManaged public var toSensorData: SensorData?

}
