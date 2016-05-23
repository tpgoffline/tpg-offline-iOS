//
//  VoirTousLesDepartsViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/05/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import AKPickerView_Swift
import SwiftyJSON
import Alamofire
import SCLAlertView
import Async
import ChameleonFramework

class VoirTousLesDepartsViewController: UIViewController {
    
    @IBOutlet weak var hourPicker: AKPickerView!
    @IBOutlet weak var departuresCollectionView: UICollectionView!
    @IBOutlet weak var labelLigne: UILabel!
    @IBOutlet weak var labelDirection: UILabel!
    
    var ligne = "1"
    var direction = "Jar.-Botanique"
    var destinationCode = "JAR.-BOTANIQUE"
    var arret: Arret = AppValues.arrets[AppValues.arretsKeys[0]]!
    var listeDeparts: [Departs] = []
    var listeDepartsInitial: [Departs] = []
    var listeHeures: [Int] = []
    var heureActuelle = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelLigne.text = ligne
        labelLigne.textColor = AppValues.listeColor[ligne]
        labelLigne.backgroundColor = AppValues.listeBackgroundColor[ligne]
        
        labelDirection.text = direction
        labelDirection.textColor = AppValues.listeColor[ligne]
        labelDirection.backgroundColor = AppValues.listeBackgroundColor[ligne]
        
        departuresCollectionView.allowsSelection = false
        departuresCollectionView.backgroundColor = AppValues.primaryColor
        
        hourPicker.backgroundColor = AppValues.primaryColor
        hourPicker.textColor = AppValues.textColor
        hourPicker.highlightedTextColor = AppValues.textColor
        hourPicker.interitemSpacing = 7
        hourPicker.delegate = self
        hourPicker.dataSource = self
        
        refresh()
        actualiserTheme()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        departuresCollectionView.backgroundColor = AppValues.primaryColor
        actualiserTheme()
        departuresCollectionView.reloadData()
        
        hourPicker.backgroundColor = AppValues.primaryColor
        hourPicker.textColor = AppValues.textColor
        hourPicker.highlightedTextColor = AppValues.textColor
        hourPicker.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        Async.background {
            self.listeDeparts = []
            let day = NSCalendar.currentCalendar().components([.Weekday], fromDate: NSDate())
            var path = ""
            if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                switch day.weekday {
                case 7:
                    path = dir.stringByAppendingPathComponent(self.arret.stopCode + "departsSAM.json")
                    break
                case 1:
                    path = dir.stringByAppendingPathComponent(self.arret.stopCode + "departsDIM.json");
                    break
                default:
                    path = dir.stringByAppendingPathComponent(self.arret.stopCode + "departsLUN.json");
                    
                    break
                }
            }
            
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                if self.listeDepartsInitial.isEmpty {
                    let dataDeparts = NSData(contentsOfFile: path)
                    let departs = JSON(data: dataDeparts!)
                    for (_, subJson) in departs {
                        if AppValues.listeColor[subJson["ligne"].string!] != nil {
                            self.listeDepartsInitial.append(Departs(
                                ligne: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                destinationCode: "",
                                couleur: AppValues.listeColor[subJson["ligne"].string!]!,
                                couleurArrierePlan: AppValues.listeBackgroundColor[subJson["ligne"].string!]!,
                                code: nil,
                                tempsRestant: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                        }
                        else {
                            self.listeDepartsInitial.append(Departs(
                                ligne: subJson["ligne"].string!,
                                direction: subJson["destination"].string!,
                                destinationCode: subJson["line"]["destinationCode"].string!,
                                couleur: UIColor.whiteColor(),
                                couleurArrierePlan: UIColor.flatGrayColorDark(),
                                code: nil,
                                tempsRestant: "0",
                                timestamp: subJson["timestamp"].string!
                                ))
                        }
                        self.listeDepartsInitial.last?.calculerTempsRestant()
                    }
                    
                    self.listeDepartsInitial = self.listeDepartsInitial.filter({ (depart) -> Bool in
                        if depart.ligne == self.ligne && depart.direction == self.direction {
                            return true
                        }
                        return false
                    })
                }
                
                if self.listeHeures.isEmpty {
                    for depart in self.listeDepartsInitial {
                        if self.listeHeures.indexOf((depart.dateCompenents?.hour)!) == nil {
                            self.listeHeures.append((depart.dateCompenents?.hour)!)
                        }
                    }
                    
                    
                    self.heureActuelle = self.listeHeures[0]
                }
                
                self.listeDeparts = self.listeDepartsInitial.filter({ (depart) -> Bool in
                    if depart.dateCompenents?.hour == self.heureActuelle {
                        return true
                    }
                    return false
                })
            }
            else {
                if self.listeDepartsInitial.isEmpty {
                    Alamofire.request(.GET, "http://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json", parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b", "stopCode": self.arret.stopCode, "lineCode": self.ligne, "destinationCode": self.destinationCode]).responseJSON { response in
                        if let data = response.result.value {
                            let departs = JSON(data)
                            for (_, subjson) in departs["departures"] {
                                if AppValues.listeColor[subjson["line"]["lineCode"].string!] == nil {
                                    self.listeDepartsInitial.append(Departs(
                                        ligne: subjson["line"]["lineCode"].string!,
                                        direction: subjson["line"]["destinationName"].string!,
                                        destinationCode: subjson["line"]["destinationCode"].string!,
                                        couleur: UIColor.whiteColor(),
                                        couleurArrierePlan: UIColor.flatGrayColor(),
                                        
                                        code: String(subjson["departureCode"].intValue ?? 0),
                                        tempsRestant: subjson["waitingTime"].string!,
                                        timestamp: subjson["timestamp"].string
                                        ))
                                }
                                else {
                                    self.listeDepartsInitial.append(Departs(
                                        ligne: subjson["line"]["lineCode"].string!,
                                        direction: subjson["line"]["destinationName"].string!,
                                        destinationCode: subjson["line"]["destinationCode"].string!,
                                        couleur: AppValues.listeColor[subjson["line"]["lineCode"].string!]!,
                                        couleurArrierePlan: AppValues.listeBackgroundColor[subjson["line"]["lineCode"].string!]!,
                                        
                                        code: String(subjson["departureCode"].intValue ?? 0),
                                        tempsRestant: subjson["waitingTime"].string!,
                                        timestamp: subjson["timestamp"].string
                                        ))
                                }
                                self.listeDepartsInitial.last?.calculerTempsRestant()
                            }
                            
                            if self.listeHeures.isEmpty {
                                for depart in self.listeDepartsInitial {
                                    if self.listeHeures.indexOf((depart.dateCompenents?.hour)!) == nil {
                                        self.listeHeures.append((depart.dateCompenents?.hour)!)
                                    }
                                }
                                
                                self.hourPicker.reloadData()
                                self.heureActuelle = self.listeHeures[0]
                            }
                            
                            self.listeDeparts = self.listeDepartsInitial.filter({ (depart) -> Bool in
                                if depart.dateCompenents?.hour == self.heureActuelle {
                                    return true
                                }
                                return false
                            })
                        }
                        else {
                            SCLAlertView().showError("Pas de réseau", subTitle: "Nous ne pouvons charger la totalité des départs car vous n'avez pas télécharger les départs (si vous avez acheté le mode premium) et vous n'êtes pas connecté à internet", closeButtonTitle: "OK").setDismissBlock({
                                self.navigationController?.popViewControllerAnimated(true)
                            })
                        }
                    }
                }
                else {
                    self.listeDeparts = self.listeDepartsInitial.filter({ (depart) -> Bool in
                        if depart.dateCompenents?.hour == self.heureActuelle {
                            return true
                        }
                        return false
                    })
                }
            }
            }.main {
                self.hourPicker.reloadData()
                self.departuresCollectionView.reloadData()
        }
    }
}

extension VoirTousLesDepartsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listeDeparts.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("tousLesDepartsCell", forIndexPath: indexPath) as! TousLesDepartsCollectionViewCell
        
        cell.titre.text = NSDateFormatter.localizedStringFromDate(NSDate(components: listeDeparts[indexPath.row].dateCompenents!), dateStyle: .NoStyle, timeStyle: .ShortStyle)
        cell.titre.textColor = AppValues.textColor
        if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
            cell.backgroundColor = AppValues.primaryColor.lightenByPercentage(0.1)
        }
        else {
            cell.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.1)
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.width / 4, height: 50)
    }
}

extension VoirTousLesDepartsViewController : AKPickerViewDataSource, AKPickerViewDelegate {
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return listeHeures.count
    }
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return "\(listeHeures[item])h"
    }
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        self.heureActuelle = listeHeures[item]
        refresh()
    }
}