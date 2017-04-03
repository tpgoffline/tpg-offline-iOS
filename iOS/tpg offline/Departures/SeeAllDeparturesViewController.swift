//
//  SeeAllDeparturesViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import SwiftyJSON

class SeeAllDeparturesViewController: UIViewController {

    @IBOutlet weak var departuresCollectionView: UICollectionView!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var noDeparturesLabel: UILabel!

    var line = "1"
    var direction = "Jar.-Botanique"
    var destinationCode = "JAR.-BOTANIQUE"
    var stop: Stop = AppValues.stops[AppValues.stopsKeys[0]]!
    var departuresList: [Int: [Departures]] = [:]
    var actualHour = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        lineLabel.text = line
        directionLabel.text = direction

        if AppValues.primaryColor.contrast == .white {
            lineLabel.textColor = AppValues.linesColor[line]
            lineLabel.backgroundColor = AppValues.linesBackgroundColor[line]

            directionLabel.textColor = AppValues.linesColor[line]
            directionLabel.backgroundColor = AppValues.linesBackgroundColor[line]
        } else {
            if AppValues.linesBackgroundColor[line]!.contrast == .white {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]
                lineLabel.backgroundColor = AppValues.primaryColor

                directionLabel.textColor = AppValues.linesBackgroundColor[line]
                directionLabel.backgroundColor = AppValues.primaryColor
            } else {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(percentage: 0.2)
                lineLabel.backgroundColor = AppValues.primaryColor

                directionLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(percentage: 0.2)
                directionLabel.backgroundColor = AppValues.primaryColor
            }

        }

        departuresCollectionView.allowsSelection = false
        departuresCollectionView.backgroundColor = AppValues.primaryColor

        self.noDeparturesLabel.isHidden = true

        refresh()
        refreshTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()

        if AppValues.primaryColor.contrast == .white {
            lineLabel.textColor = AppValues.linesColor[line]
            lineLabel.backgroundColor = AppValues.linesBackgroundColor[line]

            directionLabel.textColor = AppValues.linesColor[line]
            directionLabel.backgroundColor = AppValues.linesBackgroundColor[line]
        } else {
            if AppValues.linesBackgroundColor[line]!.contrast == .white {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]
                lineLabel.backgroundColor = AppValues.primaryColor

                directionLabel.textColor = AppValues.linesBackgroundColor[line]
                directionLabel.backgroundColor = AppValues.primaryColor
            } else {
                lineLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(percentage: 0.2)
                lineLabel.backgroundColor = AppValues.primaryColor

                directionLabel.textColor = AppValues.linesBackgroundColor[line]!.darken(percentage: 0.2)
                directionLabel.backgroundColor = AppValues.primaryColor
            }

        }

        departuresCollectionView.backgroundColor = AppValues.primaryColor

        departuresCollectionView.reloadData()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                                                                 style: UIBarButtonItemStyle.done,
                                                                 target: self,
                                                                 action: #selector(refresh))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh() {
        self.departuresCollectionView.isHidden = false
        self.noDeparturesLabel.isHidden = true

        DispatchQueue.main.async {
            self.departuresList = [:]
            Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": self.stop.stopCode, "lineCode": self.line, "destinationCode": self.destinationCode]).responseJSON { response in
                if let data = response.result.value {
                    let departs = JSON(data)
                    for (_, subjson) in departs["departures"] {
                        let departure: Departures
                        if AppValues.linesColor[subjson["line"]["lineCode"].string!] == nil {
                            departure = Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: .white,
                                lineBackgroundColor: .flatGray,

                                code: String(subjson["departureCode"].int ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                            )
                        } else {
                            departure = Departures(
                                line: subjson["line"]["lineCode"].string!,
                                direction: subjson["line"]["destinationName"].string!,
                                destinationCode: subjson["line"]["destinationCode"].string!,
                                lineColor: AppValues.linesColor[subjson["line"]["lineCode"].string!]!,
                                lineBackgroundColor: AppValues.linesBackgroundColor[subjson["line"]["lineCode"].string!]!,

                                code: String(subjson["departureCode"].int ?? 0),
                                leftTime: subjson["waitingTime"].string!,
                                timestamp: subjson["timestamp"].string
                            )
                        }
                        departure.calculateLeftTime()
                        if self.departuresList[departure.dateCompenents?.hour ?? -1] == nil {
                            self.departuresList[departure.dateCompenents?.hour ?? -1] = []
                        }
                        (self.departuresList[departure.dateCompenents?.hour ?? -1])!.append(departure)
                    }
                    for (key, array) in self.departuresList {
                        self.departuresList[key] = array.sorted(by: { return ($0.dateCompenents?.hour ?? 0) < ($1.dateCompenents?.hour ?? 0) })
                    }
                } else {
                    #if DEBUG
                        if let error = response.result.error {
                            let alert = SCLAlertView()
                            alert.showError("Alamofire", subTitle: "DEBUG - \(error.localizedDescription)", feedbackType: .impactMedium)
                        }
                    #endif
                    let day = Calendar.current.dateComponents([.weekday], from: Date())
                    var path: URL
                    let dir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
                    switch day.weekday! {
                    case 7:
                        path = dir.appendingPathComponent(self.stop.stopCode + "departsSAM.json")
                        break
                    case 1:
                        path = dir.appendingPathComponent(self.stop.stopCode + "departsDIM.json")
                        break
                    default:
                        path = dir.appendingPathComponent(self.stop.stopCode + "departsLUN.json")

                        break
                    }

                    do {
                        let departuresJSONString = try NSString(contentsOf: path, encoding: String.Encoding.utf8.rawValue)
                        let departs = JSON(data: departuresJSONString.data(using: String.Encoding.utf8.rawValue)!)

                        for (_, subJson) in departs {
                            let departure: Departures
                            if AppValues.linesColor[subJson["ligne"].string!] != nil {
                                departure = Departures(
                                    line: subJson["ligne"].string!,
                                    direction: subJson["destination"].string!,
                                    destinationCode: "",
                                    lineColor: AppValues.linesColor[subJson["ligne"].string!]!,
                                    lineBackgroundColor: AppValues.linesBackgroundColor[subJson["ligne"].string!]!,
                                    code: nil,
                                    leftTime: "0",
                                    timestamp: subJson["timestamp"].string!
                                )
                            } else {
                                departure = Departures(
                                    line: subJson["ligne"].string!,
                                    direction: subJson["destination"].string!,
                                    destinationCode: subJson["line"]["destinationCode"].string!,
                                    lineColor: .white,
                                    lineBackgroundColor: .flatGrayDark,
                                    code: nil,
                                    leftTime: "0",
                                    timestamp: subJson["timestamp"].string!
                                )
                            }
                            departure.calculateLeftTime()
                            if self.departuresList[departure.dateCompenents?.hour ?? -1] == nil {
                                self.departuresList[departure.dateCompenents?.hour ?? -1] = []
                            }
                            (self.departuresList[departure.dateCompenents?.hour ?? -1])!.append(departure)
                        }

                        if self.departuresList.isEmpty {
                            SCLAlertView().showError(
                                "Pas de réseau".localized,
                                subTitle: "Nous ne pouvons charger la totalité des départs car vous n'avez pas télécharger les départs et vous n'êtes pas connecté à internet".localized,
                                closeButtonTitle: "OK",
                                feedbackType: .notificationError).setDismissBlock({
                                    _ = self.navigationController?.popViewController(animated: true)
                                })
                        }

                        for (key, array) in self.departuresList {
                            self.departuresList[key] = array.sorted(by: { return ($0.dateCompenents?.hour ?? 0) < ($1.dateCompenents?.hour ?? 0) })
                        }
                    } catch {
                        SCLAlertView().showError(
                            "Pas de réseau".localized,
                            subTitle: "Nous ne pouvons charger la totalité des départs car vous n'avez pas télécharger les départs et vous n'êtes pas connecté à internet".localized,
                            closeButtonTitle: "OK",
                            feedbackType: .notificationError).setDismissBlock({
                                _ = self.navigationController?.popViewController(animated: true)
                            })
                    }
                }
                self.departuresCollectionView.reloadData()
                if self.departuresList.isEmpty {
                    self.departuresCollectionView.isHidden = true
                    self.noDeparturesLabel.isHidden = false
                    self.noDeparturesLabel.textColor = AppValues.textColor
                }
            }
        }
    }
}

extension SeeAllDeparturesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.departuresList.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.departuresList[([Int](departuresList.keys).sorted())[section]]!.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allDeparturesCell", for: indexPath) as! AllDeparturesCollectionViewCell // swiftlint:disable:this force_cast

        let departure = self.departuresList[([Int](departuresList.keys).sorted())[indexPath.section]]![indexPath.row]
        let date = departure.dateCompenents?.date!

        cell.title.text = DateFormatter.localizedString(from: date!, dateStyle: .none, timeStyle: .short)
        cell.title.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor.lighten(percentage: 0.1)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 4, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "allDeparturesHeader", for: indexPath) as! AllDeparturesHeader // swiftlint:disable:this force_cast
            var dateComponents = self.departuresList[([Int](departuresList.keys).sorted())[indexPath.section]]![0].dateCompenents
            dateComponents?.minute = 0
            let date = dateComponents?.date!
            headerView.label.text = DateFormatter.localizedString(from: date!, dateStyle: .none, timeStyle: .short)
            headerView.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)
            headerView.label.textColor = AppValues.textColor
            headerView.layer.cornerRadius = headerView.bounds.height / 2

            return headerView
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
}
