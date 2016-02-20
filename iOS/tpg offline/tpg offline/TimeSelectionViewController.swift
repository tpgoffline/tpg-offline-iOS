//
//  TimeSelectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/01/2016.
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
	var boutonValider: UIButton!
    @IBOutlet weak var labelHeure: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourSlider = EFCircularSlider.init(frame: CGRect(x: (view.bounds.width / 2) - 130, y: (view.bounds.height / 2) - 117, width: 260, height: 260))
        hourSlider.innerMarkingLabels = (["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"])
        hourSlider.labelFont = UIFont.systemFontOfSize(14)
        hourSlider.lineWidth = 8
        hourSlider.minimumValue = 0
        hourSlider.maximumValue = 24
        hourSlider.handleType = CircularSliderHandleTypeBigCircle
        view.addSubview(hourSlider)
        hourSlider.addTarget(self, action: "hourChanged:", forControlEvents: .ValueChanged)
        
        minuteSlider = EFCircularSlider.init(frame: CGRect(x: (view.bounds.width / 2) - 80, y: (view.bounds.height / 2) - 67, width: 160, height: 160))
        minuteSlider.innerMarkingLabels = (["5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60"])
        minuteSlider.labelFont = UIFont.systemFontOfSize(12)
        minuteSlider.lineWidth = 8
        minuteSlider.minimumValue = 0
        minuteSlider.maximumValue = 60
        minuteSlider.snapToLabels = false
        minuteSlider.handleType = CircularSliderHandleTypeBigCircle
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
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        minuteSlider.unfilledColor = AppValues.primaryColor.darkenByPercentage(0.1)
        minuteSlider.filledColor = AppValues.primaryColor.lightenByPercentage(0.2)
        hourSlider.unfilledColor = AppValues.primaryColor.lightenByPercentage(0.1)
        hourSlider.filledColor = AppValues.primaryColor.darkenByPercentage(0.2)
        hourSlider.labelColor = AppValues.textColor
        minuteSlider.labelColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor
        labelHeure.textColor = AppValues.textColor
        minuteSlider.handleColor = minuteSlider.filledColor
        hourSlider.handleColor = hourSlider.filledColor
		
		boutonValider = UIButton(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - (tabBarController?.tabBar.bounds.height)! - 50, width: UIScreen.mainScreen().bounds.width, height: 50))
		boutonValider.backgroundColor = AppValues.secondaryColor
		boutonValider.setTitle("Valider", forState: .Normal)
		boutonValider.setTitleColor(AppValues.textColor, forState: .Normal)
		boutonValider.addTarget(self, action: "boutonValiderPressed:", forControlEvents: .TouchUpInside)
		view.addSubview(boutonValider)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        minuteSlider.unfilledColor = AppValues.primaryColor.darkenByPercentage(0.1)
        minuteSlider.filledColor = AppValues.primaryColor.lightenByPercentage(0.2)
        hourSlider.unfilledColor = AppValues.primaryColor.lightenByPercentage(0.1)
        hourSlider.filledColor = AppValues.primaryColor.darkenByPercentage(0.2)
        hourSlider.labelColor = AppValues.textColor
        minuteSlider.labelColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor
        labelHeure.textColor = AppValues.textColor
        minuteSlider.handleColor = minuteSlider.filledColor
        hourSlider.handleColor = hourSlider.filledColor
    }
   
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
    }
	
	func boutonValiderPressed(sender: AnyObject!) {
		navigationController?.popViewControllerAnimated(true)
	}
}