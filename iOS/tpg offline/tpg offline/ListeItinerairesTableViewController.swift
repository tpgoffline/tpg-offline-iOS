//
//  ListeItinerairesTableViewController.swift
//  tpg offline
//
//  Created by Alice on 19/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import SCLAlertView

class ListeItinerairesTableViewController: UITableViewController {

	let defaults = NSUserDefaults.standardUserDefaults()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        var url = "http://transport.opendata.ch/v1/connections?"
        url += "from=" + ItineraireEnCours.itineraire.depart!.idTransportAPI
        url += "&to=" + ItineraireEnCours.itineraire.arrivee!.idTransportAPI
        url += "&date=" + String(ItineraireEnCours.itineraire.date!.year) + "-" + String(ItineraireEnCours.itineraire.date!.month) + "-" + String(ItineraireEnCours.itineraire.date!.day)
        url += "&time=" + String(ItineraireEnCours.itineraire.date!.hour) + ":" + String(ItineraireEnCours.itineraire.date!.minute)
        url += "&isArrivalTime=" + String(Int(ItineraireEnCours.itineraire.dateArrivee))
        ItineraireEnCours.json = JSON(data: "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            ItineraireEnCours.json = JSON(data: data)
        }
        else {
            let alerte = SCLAlertView()
            alerte.showError("Pas de réseau", subTitle: "Vous devez être connecté au réseau pour construire un itinéraire. Si vous êtes connecté au réseau, le serveur est peut-être indisponible.", closeButtonTitle: "OK", duration: 10).setDismissBlock({ () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }

        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        tableView.backgroundColor = AppValues.primaryColor
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
        tableView.backgroundColor = AppValues.primaryColor
		
		var listeItems: [UIBarButtonItem] = []
		if AppValues.favorisItineraires.indexForKey(ItineraireEnCours.itineraire.id.UUIDString) != nil {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		else {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		self.navigationItem.rightBarButtonItems = listeItems
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if ItineraireEnCours.json["connections"].count == 0 {
			return 1
		}
        return ItineraireEnCours.json["connections"].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listeItineaireCell", forIndexPath: indexPath) as! ListeItinerairesTableViewCell

		if ItineraireEnCours.json["connections"].count == 0 {
			cell.textLabel?.text = "Itinéraires non trouvées"
			cell.detailTextLabel?.text = "Essayez de faire une nouvelle recherche avec différents paramètres."
			cell.textLabel?.textColor = UIColor.whiteColor()
			cell.detailTextLabel?.textColor = UIColor.whiteColor()
			cell.backgroundColor = UIColor.flatRedColorDark()
			let iconeError = FAKFontAwesome.timesCircleIconWithSize(20)
			iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
			cell.imageView?.image = iconeError.imageWithSize(CGSize(width: 25, height: 25))
			return cell
		}
		
        var icone = FAKIonIcons.logOutIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)

        var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][indexPath.row]["from"]["station"]["name"].stringValue))
        cell.labelDepart.attributedText = attributedString
        cell.labelDepart.textColor = AppValues.textColor

        icone = FAKIonIcons.logInIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        
        attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + ItineraireEnCours.json["connections"][indexPath.row]["to"]["station"]["name"].stringValue))
        cell.labelArrivee.attributedText = attributedString
        cell.labelArrivee.textColor = AppValues.textColor
        
        icone = FAKIonIcons.clockIconWithSize(21)
        icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        
        attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
        attributedString.appendAttributedString(NSAttributedString(string: " " + String(ItineraireEnCours.json["connections"][indexPath.row]["duration"].stringValue.characters.dropFirst().dropFirst().dropFirst())))
        cell.labelDuree.attributedText = attributedString
        cell.labelDuree.textColor = AppValues.textColor
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var timestamp = ItineraireEnCours.json["connections"][indexPath.row]["from"]["departureTimestamp"].intValue
        cell.labelHeureDepart.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        cell.labelHeureDepart.textColor = AppValues.textColor
        
        timestamp = ItineraireEnCours.json["connections"][indexPath.row]["to"]["arrivalTimestamp"].intValue
        cell.labelHeureArrivee.text = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: Double(timestamp)))
        cell.labelHeureArrivee.textColor = AppValues.textColor
        
        cell.backgroundColor = AppValues.primaryColor
        
        let view = UIView()
        view.backgroundColor = AppValues.secondaryColor
        cell.selectedBackgroundView = view
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "voirItineraire" {
            let destinationViewController: VueItineraireTableViewController = (segue.destinationViewController) as! VueItineraireTableViewController
            destinationViewController.compteur = (tableView.indexPathForSelectedRow?.row)!
            var listeHoraires = [NSDate]()
            for (_, subJson) in ItineraireEnCours.json["connections"][(tableView.indexPathForSelectedRow?.row)!]["sections"] {
                listeHoraires.append(NSDate(timeIntervalSince1970: Double(subJson["departure"]["departureTimestamp"].intValue)))
            }
            destinationViewController.listeHeures = listeHoraires
            
        }
    }
	func toggleFavorite(sender: AnyObject!) {
		if AppValues.favorisItineraires.isEmpty {
			let itineraire = Itineraire(depart: ItineraireEnCours.itineraire.depart, arrivee: ItineraireEnCours.itineraire.arrivee)
			itineraire.id = ItineraireEnCours.itineraire.id
			let array: [String:Itineraire] = [ItineraireEnCours.itineraire.id.UUIDString : itineraire]
			AppValues.favorisItineraires = array
			
			let encodedData = NSKeyedArchiver.archivedDataWithRootObject(array)
			defaults.setObject(encodedData, forKey: "itinerairesFavoris")
		}
		else {
			if AppValues.favorisItineraires.indexForKey(ItineraireEnCours.itineraire.id.UUIDString) != nil {
				AppValues.favorisItineraires.removeValueForKey(ItineraireEnCours.itineraire!.id.UUIDString)
			}
			else {
				AppValues.favorisItineraires[ItineraireEnCours.itineraire.id.UUIDString] = Itineraire(depart: ItineraireEnCours.itineraire.depart, arrivee: ItineraireEnCours.itineraire.arrivee)
				AppValues.favorisItineraires[ItineraireEnCours.itineraire.id.UUIDString]!.id = ItineraireEnCours.itineraire.id
			}
			let encodedData = NSKeyedArchiver.archivedDataWithRootObject(AppValues.arretsFavoris!)
			defaults.setObject(encodedData, forKey: "arretsFavoris")
		}
		var listeItems: [UIBarButtonItem] = []
		if AppValues.favorisItineraires.indexForKey(ItineraireEnCours.itineraire.id.UUIDString) != nil {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		else {
			listeItems.append(UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20,height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:"))
		}
		self.navigationItem.rightBarButtonItems = listeItems
	}

}
