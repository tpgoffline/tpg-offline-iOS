//
//  CalendarSelectionViewController.swift
//  tpg offline
//
//  Created by Alice on 15/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import FSCalendar

class CalendarSelectionViewController: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()
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

}

extension CalendarSelectionViewController : FSCalendarDataSource, FSCalendarDelegate {
    func minimumDateForCalendar(calendar: FSCalendar!) -> NSDate! {
        return NSDate()
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        if ItineraireEnCours.itineraire.date == nil {
            ItineraireEnCours.itineraire.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: date)
            ItineraireEnCours.itineraire.date!.hour = 0
            ItineraireEnCours.itineraire.date!.minute = 0
        }
        else {
            let dateCalendar = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date)
            ItineraireEnCours.itineraire.date!.day = dateCalendar.day
            ItineraireEnCours.itineraire.date!.month = dateCalendar.month
            ItineraireEnCours.itineraire.date!.year = dateCalendar.year
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}