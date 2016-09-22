//
//  ThemesCollectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 12/02/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import Chameleon
import FontAwesomeKit

private let reuseIdentifier = "ThemesCell"

class ThemesCollectionViewController: UICollectionViewController {
    let themes = [
        "Défaut".localized() : [UIColor.flatOrange(), UIColor.white],
        "Inversé".localized() : [UIColor.flatWhite(), UIColor.flatOrangeColorDark()],
        "Nuit".localized() : [UIColor.flatNavyBlue(), UIColor.flatWhite()],
        "Menthe".localized() : [UIColor.flatWhite(), UIColor.flatMintColorDark()],
        "Bleu".localized() : [UIColor.flatWhite(), UIColor.flatSkyBlue()],
        "Vert".localized() : [UIColor.flatWhite(), UIColor.flatGreenColorDark()],
        "Noir".localized() : [UIColor.flatWhite(), UIColor.flatBlackColorDark()],
        "Forêt".localized() : [UIColor.flatWhite(), UIColor.flatForestGreen()],
        "Mauve".localized() : [UIColor.flatWhite(), UIColor.flatMagenta()]
    ]
    
    let defaults = UserDefaults.standard
    var keys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keys = themes.keys.sorted(by: { (key1, key2) -> Bool in
            if key1.lowercased() < key2.lowercased() {
                return true
            }
            return false
        })

        collectionView!.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.1)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
        collectionView?.reloadData()
	}

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemeCollectionViewCell
    
        cell.primaryColorView.backgroundColor = themes[keys[(indexPath as NSIndexPath).row]]![0]
        cell.textColorLabel.textColor = themes[keys[(indexPath as NSIndexPath).row]]![1]
        cell.textColorLabel.text = keys[(indexPath as NSIndexPath).row]
    
        return cell
    }

	func collectionView(_ collectionView: UICollectionView,
	     layout collectionViewLayout: UICollectionViewLayout,
	            sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
		return CGSize(width: UIScreen.main.bounds.width / 2 - 15, height: 100)
	}
	
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppValues.primaryColor = themes[keys[(indexPath as NSIndexPath).row]]![0]
        AppValues.textColor = themes[keys[(indexPath as NSIndexPath).row]]![1]
        refreshTheme()
        collectionView.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.1)
		
        defaults.setColor(AppValues.primaryColor, forKey: "primaryColor")
        defaults.setColor(AppValues.textColor, forKey: "textColor")
		
		setTabBar()
		
		refreshTheme()
    }

	func setTabBar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : AppValues.textColor], for: UIControlState())
        
        tabBarController!.tabBar.tintColor = AppValues.textColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 49))
        
        tabBarController!.tabBar.barTintColor = AppValues.primaryColor
        view.backgroundColor = AppValues.primaryColor.darken(byPercentage: 0.05)
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tabBarController!.tabBar.selectionIndicatorImage = image
        
        let iconeHorloge = FAKIonIcons.iosClockIcon(withSize: 20)!
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![0].image = iconeHorloge.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        tabBarController!.tabBar.items![0].selectedImage = iconeHorloge.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconeAttention = FAKFontAwesome.warningIcon(withSize: 20)!
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![1].image = iconeAttention.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![1].selectedImage = iconeAttention.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconeItineraire = FAKFontAwesome.mapSignsIcon(withSize: 20)!
        iconeItineraire.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![2].image = iconeItineraire.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![2].selectedImage = iconeItineraire.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconePlan = FAKFontAwesome.mapIcon(withSize: 20)!
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![3].image = iconePlan.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![3].selectedImage = iconePlan.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        let iconeParametre = FAKFontAwesome.cogIcon(withSize: 20)!
        iconeParametre.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        tabBarController!.tabBar.items![4].image = iconeParametre.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        tabBarController!.tabBar.items![4].selectedImage = iconeParametre.image(with: CGSize(width: 20, height: 20)).withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
}
