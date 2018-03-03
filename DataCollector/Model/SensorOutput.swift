//
//  SensorOutput.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 03/03/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import Foundation


class SensorOutput {
    
    var timeStamp: NSDate?
    
    var gyroX: Float?
    var gyroY: Float?
    var gyroZ: Float?
    
    var accX: Float?
    var accY: Float?
    var accZ: Float?
    
    var magX: Float?
    var magY: Float?
    var magZ: Float?
    
    init(){
        
    }
    
    init(timeStamp: NSDate?, GyroX: Float?, GyroY: Float?, GyroZ: Float?, AccX: Float?, AccY: Float?, AccZ: Float?, MagX: Float?, MagY: Float?, MagZ: Float?) {
        self.timeStamp = timeStamp
        
        self.gyroX = GyroX
        self.gyroY = GyroY
        self.gyroZ = GyroZ
        
        self.accX = AccX
        self.accY = AccY
        self.accZ = AccZ
        
        self.magX = MagX
        self.magY = MagY
        self.magZ = MagZ
    }
    
    
    
}
