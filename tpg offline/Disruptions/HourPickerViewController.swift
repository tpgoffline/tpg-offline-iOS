//
//  HourPickerViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class HourPickerViewController: UIViewController {

  @IBOutlet weak var beginTimePicker: UIDatePicker!
  @IBOutlet weak var endTimePicker: UIDatePicker!
  @IBOutlet weak var beginTextLabel: UILabel!
  @IBOutlet weak var endTextLabel: UILabel!
  @IBOutlet weak var beginImageView: UIImageView!
  @IBOutlet weak var endImageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Hours".localized

    var comps = Calendar.current.dateComponents([.year,
                                                 .month,
                                                 .day,
                                                 .hour,
                                                 .minute,
                                                 .second], from: Date())
    comps.day = (comps.day ?? 0) + 1
    comps.hour = 0
    comps.minute = 0
    comps.second = 0

    self.endTimePicker.maximumDate = Calendar.current.date(from: comps) ?? Date()

    ColorModeManager.shared.addColorModeDelegate(self)

    self.view.backgroundColor = App.cellBackgroundColor
    self.beginTimePicker.setValue(App.textColor, forKeyPath: "textColor")
    self.endTimePicker.setValue(App.textColor, forKeyPath: "textColor")
    self.beginTextLabel.textColor = App.textColor
    self.endTextLabel.textColor = App.textColor
    self.beginImageView.image = #imageLiteral(resourceName: "clock").maskWith(color: App.textColor)
    self.endImageView.image = #imageLiteral(resourceName: "clock-reversed").maskWith(color: App.textColor)

    beginTimePickerChanged()
    endTimePickerChanger()

    if UIDevice.current.orientation.isLandscape,
      UIDevice.current.userInterfaceIdiom == .phone {
      self.stackView.axis = .horizontal
    } else {
      self.stackView.axis = .vertical
    }
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    // swiftlint:disable:previous line_length
    if UIDevice.current.orientation.isLandscape,
      UIDevice.current.userInterfaceIdiom == .phone {
      self.stackView.axis = .horizontal
    } else {
      self.stackView.axis = .vertical
    }
  }

  override func colorModeDidUpdated() {
    super.colorModeDidUpdated()
    self.view.backgroundColor = App.cellBackgroundColor
    self.beginTimePicker.setValue(App.textColor, forKeyPath: "textColor")
    self.endTimePicker.setValue(App.textColor, forKeyPath: "textColor")
    self.beginTextLabel.textColor = App.textColor
    self.endTextLabel.textColor = App.textColor
    self.beginImageView.image = #imageLiteral(resourceName: "clock").maskWith(color: App.textColor)
    self.endImageView.image = #imageLiteral(resourceName: "clock-reversed").maskWith(color: App.textColor)
  }

  @IBAction func beginTimePickerChanged() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    AddMonitoring.fromHour = dateFormatter.string(from: beginTimePicker.date)
    self.endTimePicker.minimumDate = beginTimePicker.date.addingTimeInterval(60)
  }

  @IBAction func endTimePickerChanger() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    AddMonitoring.toHour = dateFormatter.string(from: endTimePicker.date)
    self.beginTimePicker.maximumDate = endTimePicker.date.addingTimeInterval(-60)
  }

  deinit {
    ColorModeManager.shared.removeColorModeDelegate(self)
  }
}
