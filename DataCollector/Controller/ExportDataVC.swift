//
//  ExportDataVC.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 19/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit
import CoreData

class ExportDataVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var controller: NSFetchedResultsController<Session>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        attemptFetch()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func configureCell(cell: ItemCell, indexPath: NSIndexPath) {
        
        let session = controller.object(at: indexPath as IndexPath)
        cell.configureCell(session: session)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    func attemptFetch(){
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        let idSort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [idSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do {
            
            try self.controller.performFetch()
            
        } catch {
            
            let error = error as NSError
            print("\(error)")
            
        }
        
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
            
        case.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
        case.update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! ItemCell
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
            
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
            
        }
        
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        
        let entities = ["Session", "Characteristic", "SensorData"]
        
        for entity in entities{
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                
                _ = try context.execute(request)
                
            } catch {
                
                let error = error as NSError
                print("\(error)")
            }
            
        }
        
        attemptFetch()
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            context.delete(controller.fetchedObjects![indexPath.row])
            do {
                try context.save()
                tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    @IBAction func exportPressed(_ sender: Any) {
        
        let fileName = "Sessions.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "SessionID,SessionDate,SessionDuration,SessionPeriod,AmountOfSensors,IsWalking,Timestamp1,GyroX1,GyroY1,GyroZ1,AccX1,AccY1,AccZ1,MagX1,MagY1,MagZ1,Timestamp2,GyroX2,GyroY2,GyroZ2,AccX2,AccY2,AccZ2,MagX2,MagY2,MagZ2,Timestamp3,GyroX3,GyroY3,GyroZ3,AccX3,AccY3,AccZ3,MagX3,MagY3,MagZ3\n"
        
        let fetchRequestSession = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        let fetchRequestSensor = NSFetchRequest<NSFetchRequestResult>(entityName: "Sensor")
        let fetchRequestCharacteristicName = NSFetchRequest<NSFetchRequestResult>(entityName: "CharacteristicName")
        
        // Add Sort Descriptors
        let sortDescriptorSession = NSSortDescriptor(key: "id", ascending: true)
        fetchRequestSession.sortDescriptors = [sortDescriptorSession]
        
        let sortDescriptorSensor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequestSensor.sortDescriptors = [sortDescriptorSensor]
        
        let sortDescriptorCharacteristicName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequestCharacteristicName.sortDescriptors = [sortDescriptorCharacteristicName]
        
        
        do {
            let sessions = try context.fetch(fetchRequestSession) as! [Session]
            let sensors = try context.fetch(fetchRequestSensor) as! [Sensor]
            var characteristicNames = try context.fetch(fetchRequestCharacteristicName) as! [CharacteristicName]
            characteristicNames.swapAt(0, 1)
            
            for session in sessions {
                
                let sessionID = "\(session.id)"
                let sessionDate = "\(String(describing: session.date!))"
                let sessionDuration = "\(session.duration!)"
                let sessionPeriod = "\(session.period)"
                let amountOfSensors = "\(session.sensorsAmount)"
                let isWalking = "\(session.isWalking)"
                var newLine = ""
                var sensorsInfo = ""
                
                for sensor in sensors {
                    
                    for sensorData in session.toSensorData!.allObjects as! [SensorData] {
                        
                        if sensorData.toSensor == sensor {
                            let timeStamp = ",\(String(describing: sensorData.timeStamp!))"
                            sensorsInfo += timeStamp
                            
                            for characteristicName in characteristicNames {
                                
                                
                                for characteristic in sensorData.toCharacteristic?.allObjects as! [Characteristic] {
                                    
                                    if characteristic.toCharacteristicName == characteristicName {
                                        
                                        let x = characteristic.x
                                        let y = characteristic.y
                                        let z = characteristic.z
                                        
                                        sensorsInfo += ",\(x),\(y),\(z)"
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                            } // Characteristic Name
                            
                            
                        } // Sensors
                        
                        
                        
                    } // Sensor Data
                    
                    sensorsInfo += "\n"
                    newLine = "\(sessionID),\(sessionDate),\(sessionDuration),\(sessionPeriod),\(amountOfSensors),\(isWalking)"
                    csvText.append(newLine+sensorsInfo)
                    newLine = ""
                    
                    
                } // for session
                
                
            }
            
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            print(path ?? "not found")
            
        } catch {
            print(error)
        }
        
        
        if let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sessions.csv") as URL? {
            let objectsToShare = [fileURL]
            let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            let excludedActivities = [UIActivityType.postToFlickr, UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.mail, UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo]
            
            activityController.excludedActivityTypes = excludedActivities
            present(activityController, animated: true, completion: nil)
        }
        
    } // export Pressed
    
    
}
