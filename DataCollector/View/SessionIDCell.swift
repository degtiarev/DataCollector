//
//  SessionIDCell.swift
//  MotionCollector
//
//  Created by Aleksei Degtiarev on 01/04/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit

class SessionIDCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    
    func configureCell (id: Int){
        idLabel.text = "\(id)"
    }
    
}

