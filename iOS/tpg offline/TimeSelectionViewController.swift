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
	@IBOutlet weak var boutonValider: UIButton!
    @IBOutlet weak var labelHeure: UILabel!
    @IBOutlet weak var timeSlider: DVSCircularTimeSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeSlider.primaryCircleStrokeSize = 5
        timeSlider.primaryCircleHandleRadius = 15
        timeSlider.shadowCircleStrokeSize = 3
        
        if ItineraireEnCours.itineraire.date != nil {
            if let date = NSCalendar.currentCalendar().dateFromComponents(ItineraireEnCours.itineraire.date!) {
                timeSlider.time = date
            }
            labelHeure.text = NSDateFormatter.localizedStringFromDate(NSCalendar.currentCalendar().dateFromComponents(ItineraireEnCours.itineraire.date!)!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        }
     
        timeSlider.primaryCircleColor = AppValues.textColor
        timeSlider.shadowCircleColor = AppValues.secondaryColor
        timeSlider.timeLabelColor = AppValues.textColor
		
		boutonValider.backgroundColor = AppValues.secondaryColor
		boutonValider.setTitleColor(AppValues.textColor, forState: .Normal)
		view.addSubview(boutonValider)
        
        timeSlider.addTarget(self, action: "hourChanged:", forControlEvents: .ValueChanged)
        
        timeSlider.backgroundColor = AppValues.primaryColor
        view.backgroundColor = AppValues.primaryColor
        labelHeure.textColor = AppValues.textColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        actualiserTheme()
        
        timeSlider.primaryCircleColor = AppValues.textColor
        timeSlider.shadowCircleColor = AppValues.secondaryColor
        timeSlider.timeLabelColor = AppValues.textColor
        
        boutonValider.setTitleColor(AppValues.textColor, forState: .Normal)
        boutonValider.backgroundColor = AppValues.secondaryColor
        timeSlider.backgroundColor = AppValues.primaryColor
        view.backgroundColor = AppValues.primaryColor
        labelHeure.textColor = AppValues.textColor
    }
    
    func hourChanged(sender: AnyObject!) {
        labelHeure.text = NSDateFormatter.localizedStringFromDate(NSCalendar.currentCalendar().dateFromComponents(ItineraireEnCours.itineraire.date!)!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        if ItineraireEnCours.itineraire.date == nil {
            ItineraireEnCours.itineraire.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: NSDate())
            ItineraireEnCours.itineraire.date!.hour = 0
            ItineraireEnCours.itineraire.date!.minute = 0
        }
        let compenents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: timeSlider.time)
        ItineraireEnCours.itineraire.date!.hour = compenents.hour
        ItineraireEnCours.itineraire.date!.minute = compenents.minute
    }
	
	@IBAction func boutonValiderPressed(sender: AnyObject!) {
		navigationController?.popViewControllerAnimated(true)
	}
}