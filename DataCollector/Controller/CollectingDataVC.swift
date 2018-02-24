//
//  CollectingDataVC.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 19/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit
import CoreBluetooth

class CollectingDataVC: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    // Controlls outlets
    @IBOutlet weak var currentNumberOfSensorsLabel: UILabel!
    @IBOutlet weak var numberOfSensorsSlider: UISlider!
    @IBOutlet weak var sensorsStatusLabel: UILabel!
    @IBOutlet weak var sensorsStatusImage: UIImageView!
    @IBOutlet weak var currentPeriodLabel: UILabel!
    @IBOutlet weak var periodSlider: UISlider!
    @IBOutlet weak var currentRecordNumberLabel: UILabel!
    @IBOutlet weak var recordNumberLabel: UILabel!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordStatusImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // Statuses
    enum Status {
        case connecting
        case prepared
        case recording
    }
    
    var status: Status = Status.connecting {
        willSet(newStatus) {
            
            switch(newStatus) {
            case .connecting:
                сonnecting()
                break
                
            case .prepared:
                prepared()
                break
                
            case .recording:
                recording()
                break
            }
        }
        didSet {
            
        }
    }
    
    
    // Record stopwatch
    var startTime = TimeInterval()
    var timer = Timer()
    
    // For LEDs
    var currentSensorLED: UInt8 = 1
    var sensorTagsWithLEDS = [String:Int]()
    
    // Changing variable
    var currentNumberOfSensors: Int = 0
    var currentPeriod: UInt8 = 0
    
    // Define our scanning interval times
    var keepScanning = false
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    
    // Core Bluetooth properties
    var centralManager:CBCentralManager!
    var sensorTags = [String:CBPeripheral]()
    var movementCharacteristics = [String:CBCharacteristic?]()
    var movementCharacteristicPeriod = [String:CBCharacteristic?]()
    var buttonPressedCharacteristic = [String:CBCharacteristic?]()

    
    // This could be simplified to "SensorTag" and check if it's a substring.
    // (Probably a good idea to do that if you're using a different model of
    // the SensorTag, or if you don't know what model it is...)
    let sensorTagName = "CC2650 SensorTag"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update start current value
        sensorsChangedNumber(numberOfSensorsSlider)
        periodChangedNumber(periodSlider)
        
        
        // Create our CBCentral Manager
        // delegate: The delegate that will receive central role events. Typically self.
        // queue:    The dispatch queue to use to dispatch the central role events.
        //           If the value is nil, the central manager dispatches central role events using the main queue.
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    
    
    
    
    
    
    

    
    // MARK: - CBCentralManagerDelegate methods
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var showAlert = true
        var message = ""
        
        switch central.state {
        case .poweredOff:
            message = "Bluetooth on this device is currently powered off."
        case .unsupported:
            message = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            message = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            message = "The state of the BLE Manager is unknown."
        case .poweredOn:
            showAlert = false
            message = "Bluetooth LE is turned on and ready for communication."
            
            print(message)
            keepScanning = true
//            needs to be implemented means to save energy
//            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            // Initiate Scan for Peripherals
            //Option 1: Scan for all devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
            // Option 2: Scan for devices that have the service you're interested in...
            //let sensorTagAdvertisingUUID = CBUUID(string: Device.SensorTagAdvertisingUUID)
            //print("Scanning for SensorTag adverstising with UUID: \(sensorTagAdvertisingUUID)")
            //centralManager.scanForPeripheralsWithServices([sensorTagAdvertisingUUID], options: nil)
            
        }
        
        if showAlert {
            let alertController = UIAlertController(title: "Central Manager State", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
     Invoked when the central manager discovers a peripheral while scanning.
     
     The advertisement data can be accessed through the keys listed in Advertisement Data Retrieval Keys.
     You must retain a local copy of the peripheral if any command is to be performed on it.
     In use cases where it makes sense for your app to automatically connect to a peripheral that is
     located within a certain range, you can use RSSI data to determine the proximity of a discovered
     peripheral device.
     
     central - The central manager providing the update.
     peripheral - The discovered peripheral.
     advertisementData - A dictionary containing any advertisement data.
     RSSI - The current received signal strength indicator (RSSI) of the peripheral, in decibels.
     
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")
        
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("NEXT PERIPHERAL NAME: \(peripheralName)")
            print("NEXT PERIPHERAL UUID: \(peripheral.identifier.uuidString)")
            
            if peripheralName == sensorTagName {
                print("SENSOR TAG FOUND! ADDING NOW!!!")
                // to save power, stop scanning for other devices
//                keepScanning = false
//                centralManager.stopScan() // MAKE WISER!!!!!!!!!!!
//                disconnectButton.isEnabled = true
                
                // save a reference to the sensor tag
                
                sensorTags[peripheral.identifier.uuidString]  = peripheral
                sensorTags[peripheral.identifier.uuidString]?.delegate = self
                sensorTagsWithLEDS[peripheral.identifier.uuidString] = sensorTagsWithLEDS.count + 1
                
                // Request a connection to the peripheral
                centralManager.connect(sensorTags[peripheral.identifier.uuidString]!, options: nil)
                
                if sensorTags.count == currentNumberOfSensors {
                    status = .prepared
                }
            }
        }
    }
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     
     This method is invoked when a call to connectPeripheral:options: is successful.
     You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("**** SUCCESSFULLY CONNECTED TO SENSOR TAG!!!")
        
        
        
        // Now that we've successfully connected to the SensorTag, let's discover the services.
        // - NOTE:  we pass nil here to request ALL services be discovered.
        //          If there was a subset of services we were interested in, we could pass the UUIDs here.
        //          Doing so saves battery life and saves time.
        peripheral.discoverServices(nil)
    }
    
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     
     This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
     Because connection attempts do not time out, a failed connection usually indicates a transient issue,
     in which case you may attempt to connect to the peripheral again.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("**** CONNECTION TO SENSOR TAG FAILED!!!")
    }
    
    
    /*
     Invoked when an existing connection with a peripheral is torn down.
     
     This method is invoked when a peripheral connected via the connectPeripheral:options: method is disconnected.
     If the disconnection was not initiated by cancelPeripheralConnection:, the cause is detailed in error.
     After this method is called, no more methods are invoked on the peripheral device’s CBPeripheralDelegate object.
     
     Note that when a peripheral is disconnected, all of its services, characteristics, and characteristic descriptors are invalidated.
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("**** DISCONNECTED FROM SENSOR TAG!!!")
        status = .connecting
//        lastTemperature = 0
//        updateBackgroundImageForTemperature(lastTemperature)
//        circleView.isHidden = true
//        temperatureLabel.font = UIFont(name: temperatureLabelFontName, size: temperatureLabelFontSizeMessage)
//        temperatureLabel.text = "Tap to search"
//        humidityLabel.text = ""
//        humidityLabel.isHidden = true
        if error != nil {
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        sensorTags[peripheral.identifier.uuidString] = nil
        sensorTagsWithLEDS[peripheral.identifier.uuidString] = nil
       
    }
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - CBPeripheralDelegate methods
    
    /*
     Invoked when you discover the peripheral’s available services.
     
     This method is invoked when your app calls the discoverServices: method.
     If the services of the peripheral are successfully discovered, you can access them
     through the peripheral’s services property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    // When the specified services are discovered, the peripheral calls the peripheral:didDiscoverServices: method of its delegate object.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING SERVICES: \(String(describing: error?.localizedDescription))")
            status = .connecting
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                // If we found movement service, discover the characteristics for those services.
                if (service.uuid == CBUUID(string: Device.MovementServiceUUID)) ||
                    (service.uuid == CBUUID(string: Device.IOServiceUUID)) || (service.uuid == CBUUID(string: Device.SimpleKeyUUID)) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    
    /*
     Invoked when you discover the characteristics of a specified service.
     
     If the characteristics of the specified service are successfully discovered, you can access
     them through the service's characteristics property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                // Movement Data Characteristic
                if characteristic.uuid == CBUUID(string: Device.MovementDataUUID) {
                    // Enable the Movement Sensor notifications
                    movementCharacteristics[peripheral.identifier.uuidString] = characteristic
                    sensorTags[peripheral.identifier.uuidString]?.setNotifyValue(true, for: characteristic)
                }
                
                // Movement Configuration Characteristic
                if characteristic.uuid == CBUUID(string: Device.MovementConfig) {
                    // Enable gyroscope, accelerometer and magmetometer
                    
                    // FF - with WOM
                    // 7F - all sensors on, 03 - 16 G
                    let bytes : [UInt8] = [ 0x7F, 0x03 ]
                    let data = Data(bytes:bytes)
                    
                    sensorTags[peripheral.identifier.uuidString]?.writeValue(data, for: characteristic, type: .withResponse)
                }
                
                // Movement Configuration Period
                if characteristic.uuid == CBUUID(string: Device.MovementPeriod) {
                    // Set period of Movement sensor
                    //  0x0A - minimum
                    print ("Changing period")
                    let bytes : [UInt8] = [ currentPeriod ]
                    let data = Data(bytes:bytes)

                    movementCharacteristicPeriod[peripheral.identifier.uuidString] = characteristic
                    sensorTags[peripheral.identifier.uuidString]?.writeValue(data, for: characteristic, type: .withResponse)
                }
                
                // IO Service Configuration Characteristic
                if characteristic.uuid == CBUUID(string: Device.IOServiceConfig) {
                    
                    // Change mode to remote
                    let bytes : [UInt8] = [ 0x01 ]
                    let data = Data(bytes:bytes)
                    
                    sensorTags[peripheral.identifier.uuidString]?.writeValue(data, for: characteristic, type: .withResponse)
                }
                
                // IO Service Data (enable LEDS)
                if characteristic.uuid == CBUUID(string: Device.IOServiceDataUUID) {
                    
                    // Enable LED 1 - red, 2 - green, 3 - red+green
                    let bytes : [UInt8] = [ currentSensorLED ]
                    let data = Data(bytes:bytes)
                    sensorTags[peripheral.identifier.uuidString]?.writeValue(data, for: characteristic, type: .withResponse)
                    
                    currentSensorLED += 1
                    if currentSensorLED == 4 {
                        currentSensorLED = 1
                    }
                    

                }
                
                // SimpleKey Data Characteristic
                if characteristic.uuid == CBUUID(string: Device.SimpleKeyDataUUID) {
                    // Enable the Movement Sensor notifications
                    buttonPressedCharacteristic[peripheral.identifier.uuidString] = characteristic
                    sensorTags[peripheral.identifier.uuidString]?.setNotifyValue(true, for: characteristic)
                }
                
                
            }
        }
    }
    
    
    /*
     Invoked when you retrieve a specified characteristic’s value,
     or when the peripheral device notifies your app that the characteristic’s value has changed.
     
     This method is invoked when your app calls the readValueForCharacteristic: method,
     or when the peripheral notifies your app that the value of the characteristic for
     which notifications and indications are enabled has changed.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: Device.MovementDataUUID) {
                displayMovement(dataBytes, uiid: peripheral.identifier.uuidString)
            }
            
            else if  characteristic.uuid == CBUUID(string: Device.SimpleKeyDataUUID) {
                extractData(dataBytes)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Converting data
    func displayMovement(_ data:Data, uiid: String) {
        // We'll get four bytes of data back, so we divide the byte count by two
        // because we're creating an array that holds two 16-bit (two-byte) values
        let dataLength = data.count / MemoryLayout<Int16>.size
        var dataArray = [Int16](repeating: 0, count: dataLength)
        (data as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)
        
        //        // output values for debugging/diagnostic purposes
        //        for i in 0 ..< dataLength {
        //            let nextInt:UInt16 = dataArray[i]
        //            print("next int: \(nextInt)")
        //        }
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let nanoseconds = calendar.component(.nanosecond, from: date)
        
        let currentTime = "\(hour):\(minutes):\(seconds):\(nanoseconds)"
        
        let rawGyroX:Int16 = dataArray[Device.SensorDataIndexGyroX]
        let GyroX = Float(rawGyroX) / (65536 / 500)
        let rawGyroY:Int16 = dataArray[Device.SensorDataIndexGyroY]
        let GyroY = Float(rawGyroY) / (65536 / 500)
        let rawGyroZ:Int16 = dataArray[Device.SensorDataIndexGyroZ]
        let GyroZ = Float(rawGyroZ) / (65536 / 500);
        
        
        let rawAccX:Int16 = dataArray[Device.SensorDataIndexAccX]
        let AccX = Float(rawAccX) / (32768/16)
        let rawAccY:Int16 = dataArray[Device.SensorDataIndexAccY]
        let AccY = Float(rawAccY) / (32768/16)
        let rawAccZ:Int16 = dataArray[Device.SensorDataIndexAccZ]
        let AccZ = Float(rawAccZ) / (32768/16)
        
        
        let rawMagX:Int16 = dataArray[Device.SensorDataIndexMagX]
        let MagX = Float(rawMagX)
        let rawMagY:Int16 = dataArray[Device.SensorDataIndexMagY]
        let MagY = Float(rawMagY)
        let rawMagZ:Int16 = dataArray[Device.SensorDataIndexMagZ]
        let MagZ = Float(rawMagZ)
        
        print("***\(uiid) - LED \(sensorTagsWithLEDS[uiid] ?? 255)");
        print("***\(currentTime) Gyro XYZ: \(GyroX) \(GyroY) \(GyroZ) ");
        print("***\(currentTime) Acc XYZ: \(AccX) \(AccY) \(AccZ) ");
        print("***\(currentTime) Mag XYZ: \(MagX) \(MagY) \(MagZ) ");
        print("*****************************************************");
        
    }
    
    func extractData(_ data:Data){
        
        let value = data.withUnsafeBytes { (ptr: UnsafePointer<Int>) -> Int in
            return ptr.pointee
        }
        // 0 - nothing, 1 - user button, 2 - power button, 3 - user button + power button
        print(value)
    }
    
    
    

    
    
    
    
    
    
//    // MARK: - Bluetooth scanning
//    
//    @objc func pauseScan() {
//        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
//        print("*** PAUSING SCAN...")
//        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
//        centralManager.stopScan()
////        disconnectButton.isEnabled = true
//    }
//    
//    @objc func resumeScan() {
//        if keepScanning {
//            // Start scanning again...
//            print("*** RESUMING SCAN!")
////            disconnectButton.isEnabled = false
//            sensorsStatusLabel.text = "Searching"
//            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
//        } else {
////            disconnectButton.isEnabled = true
//        }
//    }
    
    
    
    
    
    
    
    
    
    // MARK - Action controlls
    
    @IBAction func sensorsChangedNumber(_ sender: UISlider) {
        // Change moving mode
        sender.setValue(sender.value.rounded(.down), animated: true)
        
        let sensorsNumber = Int (sender.value)
        currentNumberOfSensorsLabel.text = "\(sensorsNumber)"
        currentNumberOfSensors = sensorsNumber
        
        status = .connecting
    }
    
    @IBAction func periodChangedNumber(_ sender: UISlider) {
        let period = String(format: "%.1f", sender.value )
        currentPeriodLabel.text = period
        
        currentPeriod = UInt8 ( (Float (period)!) * 100)
        
        // Update period of all sensors
        let bytes : [UInt8] = [ currentPeriod ]
        let data = Data(bytes:bytes)
        if sensorTags.count != 0 {
            for (key,_) in sensorTags {
                sensorTags[key]?.writeValue(data, for: (movementCharacteristicPeriod[key] as? CBCharacteristic)!, type: .withResponse)
            }
        }
        
    }
    
    @IBAction func StartButtonpressed(_ sender: Any) {
        status = .recording
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        status = .prepared
         timer.invalidate()
    }
    
    
    
    
    
    
    
    
    
    
    // MARK - Record stopwatch
    
    //Update Time Function
    @objc func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt16(elapsedTime * 1000)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%03d", fraction)
        
        //concatenate minuts, seconds and milliseconds as assign it to the UILabel
        recordTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    
    
    
    
    
    
    // MARK - Update changing state
    
    func сonnecting() {
        recordNumberLabel.isHidden = true
        currentRecordNumberLabel.isHidden = true
        recordStatusImage.isHidden = true
        recordTimeLabel.isHidden = true
        startButton.isHidden = true
        stopButton.isHidden = true
        
        sensorsStatusLabel.text = "Searching..."
        sensorsStatusImage.image = #imageLiteral(resourceName: "error")
        
        // If already connected sensor/sensors - reconect them
        if centralManager != nil {
            if sensorTags.count != 0 {
                sensorTags.forEach({ (key, value) in
                    centralManager.cancelPeripheralConnection(sensorTags[key]!)
                })
            }
            sensorTags.removeAll()
            sensorTagsWithLEDS.removeAll()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    
        currentSensorLED = 1
    }
    
    func prepared() {
        numberOfSensorsSlider.isEnabled = true
        periodSlider.isEnabled = true
        recordNumberLabel.isHidden = false
        currentRecordNumberLabel.isHidden = true
        recordStatusImage.isHidden = true
        recordTimeLabel.isHidden = false
        recordTimeLabel.text = "00:00:000"
        startButton.isHidden = false
        stopButton.isHidden = false
        startButton.isEnabled = true
        
        sensorsStatusLabel.text = "Ready to record"
        sensorsStatusImage.image = #imageLiteral(resourceName: "ok")
        
        centralManager.stopScan()
    }
    
    func recording() {
        numberOfSensorsSlider.isEnabled = false
        periodSlider.isEnabled = false
        recordStatusImage.isHidden = false
        currentRecordNumberLabel.isHidden = false
        currentRecordNumberLabel.text = "0" // update from DB
        startButton.isEnabled = false
        
        sensorsStatusLabel.text = "Recording..."
        sensorsStatusImage.image = #imageLiteral(resourceName: "record")
    }
    
    
}

