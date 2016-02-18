//
//  FavorisItineraireCollectionViewController.swift
//  tpg offline
//
//  Created by remy on 16/02/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import FontAwesomeKit
import ChameleonFramework

class FavorisItineraireCollectionViewController: UICollectionViewController {

	let defaults = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
		self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
		navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
		navigationController?.navigationBar.tintColor = AppValues.textColor
		collectionView!.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.2)
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
		navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
		navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
		navigationController?.navigationBar.tintColor = AppValues.textColor
		collectionView!.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.2)
		
		collectionView!.reloadData()
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		ItineraireEnCours.itineraire = AppValues.favorisItineraires[[String](AppValues.favorisItineraires.keys)[(collectionView?.indexPathsForSelectedItems()![0].row)!]]
		ItineraireEnCours.itineraire.setCurrentDate()
		ItineraireEnCours.itineraire.id = AppValues.favorisItineraires[[String](AppValues.favorisItineraires.keys)[(collectionView?.indexPathsForSelectedItems()![0].row)!]]!.id
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppValues.favorisItineraires.count
    }

	func collectionView(collectionView: UICollectionView,
	     layout collectionViewLayout: UICollectionViewLayout,
	            sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: UIScreen.mainScreen().bounds.width - 10, height: 100)
	}
	
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("favoisItineraireCell", forIndexPath: indexPath) as! FavorisItineraireCollectionViewCell
    
		var icone = FAKIonIcons.logOutIconWithSize(21)
		icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		var attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
		attributedString.appendAttributedString(NSAttributedString(string: " " + (AppValues.favorisItineraires[[String](AppValues.favorisItineraires.keys)[indexPath.row]]!.depart?.nomComplet)!))
		cell.arretDepart.attributedText = attributedString
		cell.arretDepart.textColor = AppValues.textColor
		cell.arretDepart.backgroundColor = AppValues.primaryColor
		
		icone = FAKIonIcons.logInIconWithSize(21)
		icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
		attributedString = NSMutableAttributedString(attributedString: icone.attributedString())
		attributedString.appendAttributedString(NSAttributedString(string: " " + (AppValues.favorisItineraires[[String](AppValues.favorisItineraires.keys)[indexPath.row]]!.arrivee?.nomComplet)!))
		cell.arretArrivee.attributedText = attributedString
		cell.arretArrivee.textColor = AppValues.textColor
		cell.arretArrivee.backgroundColor = AppValues.secondaryColor
		
        return cell
    }

}
