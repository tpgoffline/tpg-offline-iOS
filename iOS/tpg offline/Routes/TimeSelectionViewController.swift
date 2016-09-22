//
//  TimeSelectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Chameleon
import EFCircularSlider

class TimeSelectionViewController: UIViewController {
    @IBOutlet weak var hourSlider: EFCircularSlider!
    @IBOutlet weak var minuteSlider: EFCircularSlider!
    @IBOutlet weak var boutonValider: UIButton!
    @IBOutlet weak var labelHeure: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourSlider.innerMarkingLabels = (["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "0"])
        hourSlider.labelFont = UIFont.systemFont(ofSize: 12)
        hourSlider.handleType = CircularSliderHandleTypeBigCircle
        
        view.addSubview(hourSlider)
        hourSlider.addTarget(self, action: #selector(TimeSelectionViewController.hourChanged(_:)), for: .valueChanged)
        
        minuteSlider.innerMarkingLabels = (["5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "0"])
        minuteSlider.labelFont = UIFont.systemFont(ofSize: 10)
        minuteSlider.handleType = CircularSliderHandleTypeBigCircle
        view.addSubview(minuteSlider)
        
        minuteSlider.addTarget(self, action: #selector(TimeSelectionViewController.minuteChanged(_:)), for: .valueChanged)
        
        if ActualRoutes.route.date != nil {
            hourSlider.currentValue = Float(ActualRoutes.route.date!.hour!)
            minuteSlider.currentValue = Float(ActualRoutes.route.date!.minute!)
            labelHeure.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        }
        
        minuteSlider.unfilledColor = AppValues.primaryColor.darken(byPercentage: 0.1)
        minuteSlider.filledColor = AppValues.primaryColor.lighten(byPercentage: 0.2)
        hourSlider.unfilledColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
        hourSlider.filledColor = AppValues.primaryColor.darken(byPercentage: 0.2)
        hourSlider.labelColor = AppValues.textColor
        minuteSlider.labelColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor
        labelHeure.textColor = AppValues.textColor
        minuteSlider.handleColor = minuteSlider.filledColor
        hourSlider.handleColor = hourSlider.filledColor
        
        boutonValider.backgroundColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
        boutonValider.setTitle("Valider", for: UIControlState())
        boutonValider.setTitleColor(AppValues.textColor, for: UIControlState())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTheme()
        boutonValider.backgroundColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
        boutonValider.setTitleColor(AppValues.textColor, for: UIControlState())
        minuteSlider.unfilledColor = AppValues.primaryColor.darken(byPercentage: 0.1)
        minuteSlider.filledColor = AppValues.primaryColor.lighten(byPercentage: 0.2)
        hourSlider.unfilledColor = AppValues.primaryColor.lighten(byPercentage: 0.1)
        hourSlider.filledColor = AppValues.primaryColor.darken(byPercentage: 0.2)
        hourSlider.labelColor = AppValues.textColor
        minuteSlider.labelColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor
        labelHeure.textColor = AppValues.textColor
        minuteSlider.handleColor = minuteSlider.filledColor
        hourSlider.handleColor = hourSlider.filledColor
    }
    func minuteChanged(_ sender: Any!) {
        labelHeure.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        if ActualRoutes.route.date == nil {
            ActualRoutes.route.date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
            ActualRoutes.route.date!.hour = 0
        }
        ActualRoutes.route.date!.minute = Int(minuteSlider.currentValue)
    }
    func hourChanged(_ sender: Any!) {
        labelHeure.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
        if ActualRoutes.route.date == nil {
            ActualRoutes.route.date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
            ActualRoutes.route.date!.minute = 0
        }
        ActualRoutes.route.date!.hour = Int(hourSlider.currentValue)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        hourSlider.setNeedsLayout()
        minuteSlider.setNeedsLayout()
    }
    
    @IBAction func boutonValiderPressed(_ sender: AnyObject!) {
          _ = navigationController?.popViewController(animated: true)
    }
}
