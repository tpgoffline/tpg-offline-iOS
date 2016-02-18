//
//  ThemesCollectionViewController.swift
//  tpg offline
//
//  Created by Alice on 12/02/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import FontAwesomeKit
import ChameleonFramework

private let reuseIdentifier = "ThemesCell"

class ThemesCollectionViewController: UICollectionViewController {
    let themes = [
        "Default" : [UIColor.flatOrangeColor(), UIColor.flatOrangeColorDark(), UIColor.whiteColor()],
        "Inverse" : [UIColor.flatWhiteColor(), UIColor.flatWhiteColor().darkenByPercentage(0.1), UIColor.flatOrangeColorDark()],
        "Nuit" : [UIColor.flatNavyBlueColor(), UIColor.flatNavyBlueColorDark(), UIColor.flatOrangeColor()]
    ]
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var keys = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keys = themes.keys.sort({ (key1, key2) -> Bool in
            if key1.lowercaseString < key2.lowercaseString {
                return true
            }
            return false
        })
        collectionView!.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.2)
        
        title = "Thèmes"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ThemeCollectionViewCell
    
        cell.primaryColorView.backgroundColor = themes[keys[indexPath.row]]![0]
        cell.secondaryColorView.backgroundColor = themes[keys[indexPath.row]]![1]
        cell.textColorLabel.textColor = themes[keys[indexPath.row]]![2]
        cell.textColorLabel.text = keys[indexPath.row]
    
        return cell
    }

	func collectionView(collectionView: UICollectionView,
	     layout collectionViewLayout: UICollectionViewLayout,
	            sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSize(width: UIScreen.mainScreen().bounds.width / 2 - 15, height: 100)
	}
	
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        AppValues.primaryColor = themes[keys[indexPath.row]]![0]
        AppValues.secondaryColor = themes[keys[indexPath.row]]![1]
        AppValues.textColor = themes[keys[indexPath.row]]![2]
        navigationController?.navigationBar.barTintColor = AppValues.secondaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        collectionView.backgroundColor = AppValues.primaryColor.darkenByPercentage(0.2)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], forState: .Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], forState: .Normal)
        
        tabBarController!.tabBar.barTintColor = AppValues.secondaryColor
        tabBarController!.tabBar.tintColor = AppValues.textColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 49))
        view.backgroundColor = AppValues.secondaryColor.darkenByPercentage(0.1)
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tabBarController!.tabBar.selectionIndicatorImage = image
        
        let iconeHorloge = FAKIonIcons.iosClockIconWithSize(20)
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![0].image = iconeHorloge.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController!.tabBar.items![0].selectedImage = iconeHorloge.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeAttention = FAKFontAwesome.warningIconWithSize(20)
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![1].image = iconeAttention.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController!.tabBar.items![1].selectedImage = iconeAttention.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeItineraire = FAKFontAwesome.mapSignsIconWithSize(20)
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![2].image = iconeItineraire.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController!.tabBar.items![2].selectedImage = iconeItineraire.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconePlan = FAKFontAwesome.mapIconWithSize(20)
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![3].image = iconePlan.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController!.tabBar.items![3].selectedImage = iconePlan.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        let iconeParametre = FAKFontAwesome.cogIconWithSize(20)
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![4].image = iconeParametre.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        tabBarController!.tabBar.items![4].selectedImage = iconeParametre.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        defaults.setColor(AppValues.primaryColor, forKey: "primaryColor")
        defaults.setColor(AppValues.secondaryColor, forKey: "secondaryColor")
        defaults.setColor(AppValues.textColor, forKey: "textColor")
        
        self.setThemeUsingPrimaryColor(AppValues.primaryColor, withSecondaryColor: AppValues.secondaryColor, andContentStyle: UIContentStyle.Contrast)
    }
}
