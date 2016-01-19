//
//  VueItineraireTableViewController.swift
//  tpg offline
//
//  Created by Alice on 16/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView

class VueItineraireTableViewController: UITableViewController {
    
    var compteur = 0
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
        let couleurs = JSON(data: dataCouleurs!)
        for var i = 0; i < couleurs["colors"].count; i++ {
            listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
            listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ItineraireEnCours.json["connections"][compteur]["sections"].count
    }
        
    func labelToImage(label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("itineraireCell", forIndexPath: indexPath) as! ItineraireTableViewCell
        
        var couleurTexte = UIColor.whiteColor()
        
        if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["walk"].type == .Null {
            
            cell.ligneLabel.text = "Ligne " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
            var icone = FAKIonIcons.androidTrainIconWithSize(21)
            switch ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["categoryCode"].intValue {
            case 6:
                icone = FAKIonIcons.androidBusIconWithSize(21)
            
            case 4:
                icone = FAKIonIcons.androidBoatIconWithSize(21)
                
            case 9:
                icone = FAKIonIcons.androidSubwayIconWithSize(21)
                
            default:
                cell.backgroundColor = UIColor(red:0.93, green:0, blue:0.01, alpha:1)
                cell.ligneLabel.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue
            }
            
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 21, height: 21))
            let attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
            attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["to"].stringValue))
            cell.directionLabel.attributedText = attributedString

            if ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["operator"].stringValue == "TPG" {
                cell.backgroundColor = listeBackgroundColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]
                couleurTexte = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                
                let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
                labelPictoLigne.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]
                labelPictoLigne.textAlignment = .Center
                labelPictoLigne.textColor = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!
                labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
                labelPictoLigne.layer.borderColor = listeColor[ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["journey"]["name"].stringValue.characters.split(" ").map(String.init)[1]]!.CGColor
                labelPictoLigne.layer.borderWidth = 1
                let image = labelToImage(labelPictoLigne)
                for x in cell.iconeImageView.constraints {
                    if x.identifier == "iconeImageViewHeight" {
                        x.constant = 24
                    }
                }
                cell.iconeImageView.image = image
            }
            
            
            cell.ligneLabel.textColor = couleurTexte
            cell.directionLabel.textColor = couleurTexte
            cell.departLabel.textColor = couleurTexte
            cell.heureDepartLabel.textColor = couleurTexte
            cell.arriveeLabel.textColor = couleurTexte
            cell.heureArriveeLabel.textColor = couleurTexte
        }
        else {
            let icone = FAKIonIcons.androidWalkIconWithSize(42)
            icone.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            cell.iconeImageView.image = icone.imageWithSize(CGSize(width: 42, height: 42))
            cell.ligneLabel.text = "Marche"
            cell.directionLabel.text = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["walk"]["duration"].stringValue.characters.split(":").map(String.init)[1] + " minute(s)"
        }
        
        var icone = FAKIonIcons.logOutIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["station"]["name"].stringValue))
        cell.departLabel.attributedText = attributedString

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var timestamp = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["departure"]["departureTimestamp"].intValue
        cell.heureDepartLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        
        timestamp = ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["arrival"]["arrivalTimestamp"].intValue
        cell.heureArriveeLabel.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        
        icone = FAKIonIcons.logInIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: couleurTexte)
        attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][compteur]["sections"][indexPath.row]["arrival"]["station"]["name"].stringValue))
        cell.arriveeLabel.attributedText = attributedString
        
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
