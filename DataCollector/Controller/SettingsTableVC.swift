//
//  SettingsTableVC.swift
//  DataCollector
//
//  Created by Aleksei Degtiarev on 28/02/2018.
//  Copyright © 2018 Aleksei Degtiarev. All rights reserved.
//

import UIKit


protocol SettingsTableVCDelegate: class {
    func sensorsChangedNumberSettingsDelegate(_ number: Int)
    func periodChangedNumberSettingsDelegate(_ number: UInt8)
    func changeIDPressed()
}


class SettingsTableVC: UITableViewController {
    
    
    // Controlls outlets
    @IBOutlet weak var currentNumberOfSensorsLabel: UILabel!
    @IBOutlet weak var numberOfSensorsSlider: UISlider!
    @IBOutlet weak var currentPeriodLabel: UILabel!
    @IBOutlet weak var periodSlider: UISlider!
    @IBOutlet weak var sensorsStatusLabel: UILabel!
    @IBOutlet weak var sensorsStatusImage: UIImageView!
    @IBOutlet weak var recordNumberLabel: UILabel!
    @IBOutlet weak var currentRecordNumberLabel: UILabel!
    @IBOutlet weak var recordIDLabel: UILabel!
    
    
    weak var delegate: SettingsTableVCDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update start current value
        sensorsChangedNumber(numberOfSensorsSlider)
        periodChangedNumber(periodSlider)
    }
    
    
    @IBAction func sensorsChangedNumber(_ sender: UISlider) {
        // Change moving mode
        sender.setValue(sender.value.rounded(.down), animated: true)
        
        // Update label and send value
        let newValue = Int (sender.value)
        currentNumberOfSensorsLabel.text = "\(newValue)"
        delegate?.sensorsChangedNumberSettingsDelegate(newValue)
    }
    
    @IBAction func periodChangedNumber(_ sender: UISlider) {
        // update period
        let period = String(format: "%.1f", sender.value )
        currentPeriodLabel.text = period
        
        // Send new value
        let newValue = UInt8 ( (Float (period)!) * 100)
        delegate?.periodChangedNumberSettingsDelegate(newValue)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 2 {
            delegate?.changeIDPressed()
        }
    }
    
}
