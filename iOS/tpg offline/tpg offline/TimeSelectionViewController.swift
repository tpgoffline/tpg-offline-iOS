//
//  TimeSelectionViewController.swift
//  tpg offline
//
//  Created by Alice on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import EFCircularSlider

class TimeSelectionViewController: UIViewController {
    var hourSlider: EFCircularSlider!
    var minuteSlider: EFCircularSlider!
    @IBOutlet weak var labelHeure: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourSlider = EFCircularSlider.init(frame: CGRect(x: (view.bounds.width / 2) - 130, y: (view.bounds.height / 2) - 87, width: 260, height: 260))
        hourSlider.unfilledColor = UIColor.flatLimeColorDark()
        hourSlider.filledColor = UIColor.flatLimeColor()
        hourSlider.setInnerMarkingLabels(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"])
        hourSlider.labelFont = UIFont.systemFontOfSize(14)
        hourSlider.lineWidth = 8
        hourSlider.minimumValue = 0
        hourSlider.maximumValue = 24
        hourSlider.labelColor = UIColor.whiteColor()
        hourSlider.handleType = .BigCircle;
        hourSlider.handleColor = hourSlider.filledColor;
        view.addSubview(hourSlider)
        hourSlider.addTarget(self, action: "hourChanged:", forControlEvents: .ValueChanged)
        
        minuteSlider = EFCircularSlider.init(frame: CGRect(x: (view.bounds.width / 2) - 80, y: (view.bounds.height / 2) - 37, width: 160, height: 160))
        minuteSlider.unfilledColor = UIColor.flatMintColorDark()
        minuteSlider.filledColor = UIColor.flatMintColor()
        minuteSlider.setInnerMarkingLabels(["5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60"])
        minuteSlider.labelFont = UIFont.systemFontOfSize(12)
        minuteSlider.lineWidth = 8
        minuteSlider.minimumValue = 0
        minuteSlider.maximumValue = 60
        minuteSlider.snapToLabels = false
        minuteSlider.labelColor = UIColor.whiteColor()
        minuteSlider.handleType = .BigCircle;
        minuteSlider.handleColor = minuteSlider.filledColor;
        view.addSubview(minuteSlider)
        minuteSlider.addTarget(self, action: "minuteChanged:", forControlEvents: .ValueChanged)
        
        if ItineraireEnCours.itineraire.date != nil {
            hourSlider.currentValue = Float(ItineraireEnCours.itineraire.date!.hour)
            minuteSlider.currentValue = Float(ItineraireEnCours.itineraire.date!.minute)
            if minuteSlider.currentValue < 10 {
                labelHeure.text = String(Int(hourSlider.currentValue)) + ":0" + String(Int(minuteSlider.currentValue))
            }
            else {
                labelHeure.text = String(Int(hourSlider.currentValue)) + ":" + String(Int(minuteSlider.currentValue))
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func minuteChanged(sender: AnyObject!) {
        if minuteSlider.currentValue < 10 {
            labelHeure.text = String(Int(hourSlider.currentValue)) + ":0" + String(Int(minuteSlider.currentValue))
        }
        else {
            labelHeure.text = String(Int(hourSlider.currentValue)) + ":" + String(Int(minuteSlider.currentValue))
        }
        if ItineraireEnCours.itineraire.date == nil {
            ItineraireEnCours.itineraire.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
            ItineraireEnCours.itineraire.date!.hour = 0
        }
        ItineraireEnCours.itineraire.date!.minute = Int(minuteSlider.currentValue)
        print(ItineraireEnCours.itineraire.date)
    }
    func hourChanged(sender: AnyObject!) {
        if minuteSlider.currentValue < 10 {
            labelHeure.text = String(Int(hourSlider.currentValue)) + ":0" + String(Int(minuteSlider.currentValue))
        }
        else {
            labelHeure.text = String(Int(hourSlider.currentValue)) + ":" + String(Int(minuteSlider.currentValue))
        }
        if ItineraireEnCours.itineraire.date == nil {
            ItineraireEnCours.itineraire.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
            ItineraireEnCours.itineraire.date!.minute = 0
        }
        ItineraireEnCours.itineraire.date!.hour = Int(hourSlider.currentValue)
        print(ItineraireEnCours.itineraire.date)
    }
}