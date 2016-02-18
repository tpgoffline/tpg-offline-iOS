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
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        calendar.selectionColor = AppValues.secondaryColor
        calendar.todayColor = AppValues.primaryColor.lightenByPercentage(0.2)
        calendar.backgroundColor = AppValues.primaryColor
        calendar.tintColor = AppValues.textColor
        calendar.headerTitleColor = AppValues.textColor
        calendar.weekdayTextColor = AppValues.textColor
        calendar.titleDefaultColor = AppValues.textColor
        calendar.titlePlaceholderColor = AppValues.textColor
        calendar.titleTodayColor = AppValues.textColor
        calendar.titleSelectionColor = AppValues.textColor
        calendar.selectDate(NSCalendar(identifier: NSCalendarIdentifierGregorian)!.dateFromComponents(ItineraireEnCours.itineraire.date!), scrollToDate: true)
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
        calendar.selectionColor = AppValues.secondaryColor
        calendar.todayColor = AppValues.primaryColor.lightenByPercentage(0.2)
        calendar.backgroundColor = AppValues.primaryColor
        calendar.tintColor = AppValues.textColor
        calendar.headerTitleColor = AppValues.textColor
        calendar.weekdayTextColor = AppValues.textColor
        calendar.titleDefaultColor = AppValues.textColor
        calendar.titlePlaceholderColor = AppValues.textColor
        calendar.titleTodayColor = AppValues.textColor
        calendar.titleSelectionColor = AppValues.textColor
        calendar.selectDate(NSCalendar(identifier: NSCalendarIdentifierGregorian)!.dateFromComponents(ItineraireEnCours.itineraire.date!), scrollToDate: true)
    }
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