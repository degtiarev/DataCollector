//
//  ItemCell.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 24/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var idSessionLabel: UILabel!
    @IBOutlet weak var dateSessionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var sensorsLabel: UILabel!
    
    
    @IBAction func deletePressedButton(_ sender: Any) {
    }
}
