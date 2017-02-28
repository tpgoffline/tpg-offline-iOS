//
//  CalendarSelectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 15/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Chameleon
import FSCalendar

class CalendarSelectionViewController: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshTheme()

        calendar.appearance.selectionColor = AppValues.primaryColor.darken(byPercentage: 0.1)
        calendar.appearance.todayColor = AppValues.primaryColor.lighten(byPercentage: 0.2)
        calendar.backgroundColor = AppValues.primaryColor
        calendar.tintColor = AppValues.textColor
        calendar.appearance.headerTitleColor = AppValues.textColor
        calendar.appearance.weekdayTextColor = AppValues.textColor
        calendar.appearance.titleDefaultColor = AppValues.textColor
        calendar.appearance.titlePlaceholderColor = AppValues.textColor
        calendar.appearance.titleTodayColor = AppValues.textColor
        calendar.appearance.titleSelectionColor = AppValues.textColor
        calendar.select(Calendar(identifier: Calendar.Identifier.gregorian).date(from: ActualRoutes.route.date!)!, scrollToDate: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshTheme()

        calendar.appearance.selectionColor = AppValues.primaryColor.darken(byPercentage: 0.1)
        calendar.appearance.todayColor = AppValues.primaryColor.lighten(byPercentage: 0.2)
        calendar.backgroundColor = AppValues.primaryColor
        calendar.tintColor = AppValues.textColor
        calendar.appearance.headerTitleColor = AppValues.textColor
        calendar.appearance.weekdayTextColor = AppValues.textColor
        calendar.appearance.titleDefaultColor = AppValues.textColor
        calendar.appearance.titlePlaceholderColor = AppValues.textColor
        calendar.appearance.titleTodayColor = AppValues.textColor
        calendar.appearance.titleSelectionColor = AppValues.textColor
        calendar.select(Calendar(identifier: Calendar.Identifier.gregorian).date(from: ActualRoutes.route.date!)!, scrollToDate: true)
    }
}

extension CalendarSelectionViewController : FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        if ActualRoutes.route.date == nil {
            ActualRoutes.route.date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
            ActualRoutes.route.date!.hour = 0
            ActualRoutes.route.date!.minute = 0
        } else {
            let dateCalendar = Calendar.current.dateComponents([.day, .month, .year], from: date)
            ActualRoutes.route.date!.day = dateCalendar.day!
            ActualRoutes.route.date!.month = dateCalendar.month!
            ActualRoutes.route.date!.year = dateCalendar.year!
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}
