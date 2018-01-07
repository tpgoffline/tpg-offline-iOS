//
//  HourPickerViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 17/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class HourPickerViewController: UIViewController {

    var endHour = false
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add new".localized

        if endHour {
            self.timePicker.minimumDate = AddMonitoring.fromDate

            var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            comps.day = (comps.day ?? 0) + 1
            comps.hour = 0
            comps.minute = 0
            comps.second = 0

            self.timePicker.maximumDate = Calendar.current.date(from: comps) ?? Date()
        }

        ColorModeManager.shared.addColorModeDelegate(self)

        if App.darkMode {
            self.view.backgroundColor = App.cellBackgroundColor
            self.timePicker.setValue(UIColor.white, forKeyPath: "textColor")
            self.textLabel.textColor = App.textColor
            self.nextButton.backgroundColor = .black
            self.nextButton.setTitleColor(App.textColor, for: .normal)
        }
    }

    @IBAction func nextButtonPressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if endHour {
            AddMonitoring.toHour = dateFormatter.string(from: timePicker.date)
        } else {
            AddMonitoring.fromHour = dateFormatter.string(from: timePicker.date)
            AddMonitoring.fromDate = timePicker.date
        }
    }

    override func colorModeDidUpdated() {
        super.colorModeDidUpdated()
        self.view.backgroundColor = App.cellBackgroundColor
        self.timePicker.setValue(App.textColor, forKeyPath: "textColor")
        self.textLabel.textColor = App.textColor
        self.nextButton.backgroundColor = App.darkMode ? .black : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        self.nextButton.setTitleColor(.white, for: .normal)
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEndHour" {
            guard let destination = segue.destination as? HourPickerViewController else {
                return
            }
            destination.endHour = true
        }
    }

}
