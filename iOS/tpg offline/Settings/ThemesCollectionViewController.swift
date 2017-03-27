//
//  ThemesCollectionViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 12/02/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ThemesCell"

class ThemesCollectionViewController: UICollectionViewController {
    let themes: [String: [UIColor]] = [
        "Inversé".localized: [.flatOrange, .white],
        "Défaut".localized: [.white, .flatOrangeDark],
        "Nuit".localized: [.flatNavyBlue, .white],
        "Bleu".localized: [.white, .flatSkyBlue],
        "Vert".localized: [.white, .flatGreenDark],
        "Noir".localized: [.white, .black],
        "Forêt".localized: [.white, .flatForestGreen],
        "Mauve".localized: [.white, .flatMagenta]
    ]

    let defaults = UserDefaults.standard
    var keys = [String]()

    fileprivate let itemsPerRow: CGFloat = 2
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        keys = themes.keys.sorted(by: { (key1, key2) -> Bool in
            if key1.lowercased() < key2.lowercased() {
                return true
            }
            return false
        })

        collectionView!.backgroundColor = AppValues.primaryColor
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemeCollectionViewCell // swiftlint:disable:this force_cast

        cell.primaryColorView.backgroundColor = themes[keys[indexPath.row]]![0]
        cell.textColorLabel.textColor = themes[keys[indexPath.row]]![1]
        cell.textColorLabel.text = keys[indexPath.row]

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppValues.primaryColor = themes[keys[indexPath.row]]![0]
        AppValues.textColor = themes[keys[indexPath.row]]![1]
        refreshTheme()
        collectionView.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)

        defaults.setColor(AppValues.primaryColor, forKey: UserDefaultsKeys.primaryColor.rawValue)
        defaults.setColor(AppValues.textColor, forKey: UserDefaultsKeys.textColor.rawValue)

        setTabBar()

        refreshTheme()
    }

    func setTabBar() {
        if AppValues.primaryColor.contrast == .white {
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: AppValues.textColor], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: AppValues.textColor], for: UIControlState())
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: AppValues.textColor], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gray], for: UIControlState())
        }

        tabBarController!.tabBar.tintColor = AppValues.textColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 49))

        tabBarController!.tabBar.barTintColor = AppValues.primaryColor
        view.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)

        if AppValues.primaryColor.contrast == .white {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            tabBarController!.tabBar.selectionIndicatorImage = image
        } else {
            tabBarController!.tabBar.selectionIndicatorImage = nil
        }

        if AppValues.primaryColor.contrast == .white {
            var iconImage = #imageLiteral(resourceName: "clock").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![0].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![0].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "warning").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![1].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![1].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "routes").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![2].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![2].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "map").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![3].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![3].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)

            iconImage = #imageLiteral(resourceName: "cog").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![4].image = iconImage.withRenderingMode(.alwaysOriginal)
            tabBarController!.tabBar.items![4].selectedImage = iconImage.withRenderingMode(.alwaysOriginal)
        } else {
            var iconImage = #imageLiteral(resourceName: "clock").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![0].image = iconImage
            tabBarController!.tabBar.items![0].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "warning").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![1].image = iconImage
            tabBarController!.tabBar.items![1].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "routes").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![2].image = iconImage
            tabBarController!.tabBar.items![2].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "map").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![3].image = iconImage
            tabBarController!.tabBar.items![3].selectedImage = iconImage

            iconImage = #imageLiteral(resourceName: "cog").maskWithColor(color: AppValues.textColor)
            tabBarController!.tabBar.items![4].image = iconImage
            tabBarController!.tabBar.items![4].selectedImage = iconImage
        }

        if AppValues.primaryColor.contrast == .white {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
}

extension ThemesCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
