//
//  FilterDeparturesTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 3/11/17.
//  Copyright © 2017 Rémy DA COSTA FARO. All rights reserved.
//

import UIKit
import TKSwitcherCollection
import FirebaseAnalytics

class FilterDeparturesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAnalytics.logEvent(withName: "filterViewController", parameters: [:])

        refreshTheme()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshTheme()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StopLinesList.linesList.count + 1
    }

    func labelToImage(_ label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterDeparturesCell", for: indexPath)

        let aSwitch = UISwitch()

        aSwitch.tag = indexPath.row
        aSwitch.addTarget(self, action: #selector(toogleStateOfLine(aSwitch:)), for: .valueChanged)

        if indexPath.row == 0 {
            cell.imageView?.image = #imageLiteral(resourceName: "cross").maskWithColor(color: AppValues.textColor)
            aSwitch.isOn = !StopLinesList.filterNoMore
            if AppValues.primaryColor.contrast == .white {
                aSwitch.onTintColor = AppValues.primaryColor.darken(percentage: 0.05)
            } else {
                aSwitch.onTintColor = AppValues.textColor
            }

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = AppValues.primaryColor
            } else {
                cell.backgroundColor = UIColor.white
            }

            cell.textLabel?.text = "No more service"
            cell.textLabel?.textColor = AppValues.textColor
        } else {
            let line = StopLinesList.linesList[indexPath.row - 1]
            let textColor: UIColor

            if AppValues.primaryColor.contrast == .white {
                textColor = AppValues.linesColor[line] ?? .flatGray
            } else {
                if (AppValues.linesBackgroundColor[line] ?? .flatGray).contrast == .white {
                    textColor = AppValues.linesBackgroundColor[line] ?? .flatGray
                } else {
                    textColor = (AppValues.linesBackgroundColor[line] ?? .flatGray).darken(percentage: 0.2)!
                }
            }

            cell.textLabel?.text = "\("Ligne".localized) \(line)"
            cell.textLabel?.textColor = textColor

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = AppValues.linesBackgroundColor[line]
            } else {
                cell.backgroundColor = UIColor.white
            }

            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = line
            labelPictoLigne.textAlignment = .center
            labelPictoLigne.textColor = textColor
            labelPictoLigne.layer.borderColor = textColor.cgColor
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image

            aSwitch.isOn = StopLinesList.linesDisabled.index(of: line) == nil ? true : false
            if AppValues.primaryColor.contrast == .white {
                aSwitch.onTintColor = AppValues.linesBackgroundColor[line]?.darken(percentage: 0.05) ?? .flatGray
            } else {
                aSwitch.onTintColor = textColor
            }

        }

        cell.accessoryView = aSwitch
        return cell
    }

    func toogleStateOfLine(aSwitch: UISwitch!) {
        if aSwitch.tag == 0 {
            StopLinesList.filterNoMore = !StopLinesList.filterNoMore
        } else {
            let line = StopLinesList.linesList[aSwitch.tag - 1]
            if let index = StopLinesList.linesDisabled.index(of: line) {
                StopLinesList.linesDisabled.remove(at: index)
            } else {
                StopLinesList.linesDisabled.append(line)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
