//
//  CollectingDataVC.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 19/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit

class CollectingDataVC: UIViewController {
    
    @IBOutlet weak var currentNumberOfSensorsLabel: UILabel!
    @IBOutlet weak var numberOfSensorsSlider: UISlider!
    @IBOutlet weak var sensorsStatusLabel: UILabel!
    @IBOutlet weak var sensorsStatusImage: UIImageView!
    @IBOutlet weak var currentPeriodLabel: UILabel!
    @IBOutlet weak var periodSlider: UISlider!
    @IBOutlet weak var currentRecordNumberLabel: UILabel!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordStatusImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sensorsChangedNumber(_ sender: UISlider) {
        sender.setValue(sender.value.rounded(.down), animated: true)
        currentNumberOfSensorsLabel.text = "\( Int (sender.value))"
    }
    
    @IBAction func periodChangedNumber(_ sender: UISlider) {
        let value = String(format: "%.1f", sender.value)
        currentPeriodLabel.text = value
    }
    
    
    
}

