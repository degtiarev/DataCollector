//
//  ItemSessionCell.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 24/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit

class ItemSessionCell: UITableViewCell {
    
    @IBOutlet weak var idSessionLabel: UILabel!
    @IBOutlet weak var dateSessionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var sensorsLabel: UILabel!
    @IBOutlet weak var isWalkingLabel: UILabel!
    
    
    func configureCell (session: Session){
        
        // Format dateTime
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy  HH:mm:ss"
        let myString = formatter.string(from: session.date! as Date)
        
        
        idSessionLabel.text = "\(session.id)"
        dateSessionLabel.text = myString
        durationLabel.text = session.duration
        periodLabel.text = "\(session.period)"
        sensorsLabel.text = "\(session.sensorsAmount)"
        isWalkingLabel.text = "\(session.isWalking)"
    }
    
    
}
