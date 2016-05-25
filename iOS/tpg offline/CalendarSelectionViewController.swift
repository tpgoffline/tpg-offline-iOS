//
//  CalendarSelectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 15/01/2016.
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
        refreshTheme()
     
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
        calendar.selectDate(NSCalendar(identifier: NSCalendarIdentifierGregorian)!.dateFromComponents(ActualRoutes.route.date!)!, scrollToDate: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()
     
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
        calendar.selectDate(NSCalendar(identifier: NSCalendarIdentifierGregorian)!.dateFromComponents(ActualRoutes.route.date!)!, scrollToDate: true)
    }
}

extension CalendarSelectionViewController : FSCalendarDataSource, FSCalendarDelegate {
    func minimumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return NSDate()
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        if ActualRoutes.route.date == nil {
            ActualRoutes.route.date = NSCalendar.currentCalendar().components([.Day, .Month, .Year, .Hour, .Minute], fromDate: date)
            ActualRoutes.route.date!.hour = 0
            ActualRoutes.route.date!.minute = 0
        }
        else {
            let dateCalendar = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date)
            ActualRoutes.route.date!.day = dateCalendar.day
            ActualRoutes.route.date!.month = dateCalendar.month
            ActualRoutes.route.date!.year = dateCalendar.year
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}