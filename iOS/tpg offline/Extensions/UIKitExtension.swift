//
//  UIKitExtension.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 18/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

extension UIViewController {
    func refreshTheme() {
        navigationController?.navigationBar.barTintColor = AppValues.primaryColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
        navigationController?.navigationBar.tintColor = AppValues.textColor
        view.backgroundColor = AppValues.primaryColor

        if self.splitViewController != nil {
            guard let viewController0 = self.splitViewController?.viewControllers[0] as? UINavigationController else {
                return
            }
            viewController0.navigationBar.barTintColor = AppValues.primaryColor
            viewController0.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
            viewController0.navigationBar.tintColor = AppValues.textColor

            if (self.splitViewController?.viewControllers.count)! > 1 {
                guard let viewController1 = self.splitViewController?.viewControllers[1] as? UINavigationController else {
                    return
                }
                viewController1.navigationBar.barTintColor = AppValues.primaryColor
                viewController1.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppValues.textColor]
                viewController1.navigationBar.tintColor = AppValues.textColor
            }
        }

        if AppValues.primaryColor.contrast == .white {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }

        if self.tabBarController != nil {
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
            if BeforeStarting.predefinedTabBarItem != -1 {
                tabBarController?.selectedIndex = BeforeStarting.predefinedTabBarItem
                BeforeStarting.predefinedTabBarItem = -1
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTheme), name: .UIApplicationDidBecomeActive, object: nil)
    }
}

extension UITableViewController {
    override func refreshTheme() {
        super.refreshTheme()

        tableView.sectionIndexColor = AppValues.textColor
        tableView.sectionIndexBackgroundColor = AppValues.primaryColor
        tableView.backgroundColor = AppValues.primaryColor
        tableView.reloadData()
    }
}

extension UICollectionViewController {
    override func refreshTheme() {
        super.refreshTheme()

        collectionView!.backgroundColor = AppValues.primaryColor
        collectionView!.reloadData()
    }
}

extension UIColor {

    // Thanks to Chameleon by ViccAlexander for colors
    public static let flatOrange = #colorLiteral(red: 0.9, green: 0.492, blue: 0.135, alpha: 1)
    public static let flatOrangeDark = #colorLiteral(red: 0.83, green: 0.332, blue: 0, alpha: 1)
    public static let flatBlue = #colorLiteral(red: 0.315, green: 0.399, blue: 0.63, alpha: 1)
    public static let flatYellow = #colorLiteral(red: 1, green: 0.802, blue: 0.01, alpha: 1)
    public static let flatYellowDark = #colorLiteral(red: 1, green: 0.6666666667, blue: 0, alpha: 1)
    public static let flatNavyBlue = #colorLiteral(red: 0.2035, green: 0.28675, blue: 0.37, alpha: 1)
    public static let flatRedDark = #colorLiteral(red: 0.75, green: 0.2235, blue: 0.165, alpha: 1)
    public static let flatSkyBlue = #colorLiteral(red: 0.2064, green: 0.59856, blue: 0.86, alpha: 1)
    public static let flatGray = #colorLiteral(red: 0.585, green: 0.6456666667, blue: 0.65, alpha: 1)
    public static let flatGrayDark = #colorLiteral(red: 0.495, green: 0.5463333333, blue: 0.55, alpha: 1)
    public static let flatGreen = #colorLiteral(red: 0.184, green: 0.8, blue: 0.4406666667, alpha: 1)
    public static let flatGreenDark = #colorLiteral(red: 0.1496, green: 0.68, blue: 0.3706, alpha: 1)
    public static let flatForestGreen = #colorLiteral(red: 0.2035, green: 0.37, blue: 0.25345, alpha: 1)
    public static let flatMagenta = #colorLiteral(red: 0.619475, green: 0.3905, blue: 0.71, alpha: 1)

    func darken(percentage: CGFloat) -> UIColor? {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if percentage > 0 {
                b = min(b - percentage, 1.0)
            }
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }

        return nil
    }

    func lighten(percentage: CGFloat) -> UIColor? {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if percentage > 0 {
                b = min(b + percentage, 1.0)
            }
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }

        return nil
    }

    public var contrast: UIColor {
        var color = self

        if cgColor.pattern != nil {
            let size = CGSize(width: 1, height: 1)

            UIGraphicsBeginImageContext(size)
            let context = UIGraphicsGetCurrentContext()

            context?.interpolationQuality = .medium

            let image = UIImage()
            image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size), blendMode: .copy, alpha: 1)

            let dataPointer = context?.data?.assumingMemoryBound(to: UInt8.self)
            let data = UnsafePointer<UInt8>(dataPointer)
            color = UIColor(red: CGFloat(data![2] / 255),
                            green: CGFloat(data![1] / 255),
                            blue: CGFloat(data![0] / 255),
                            alpha: 1)

            UIGraphicsEndImageContext()
        }

        var luminance: CGFloat = 0
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha1: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha1)

        red *= 0.2126
        green *= 0.7152
        blue *= 0.0722

        luminance = red + green + blue

        return luminance > 0.6 ? .black : .white
    }

    convenience init?(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.characters.count) != 6 {
            return nil
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }

    var hexValue: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(NSString(format:"#%06x", rgb))
    }
}

extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()

        color.setFill()

        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)

        context!.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.draw(self.cgImage!, in: rect)

        context!.setBlendMode(CGBlendMode.sourceIn)
        context!.addRect(rect)
        context!.drawPath(using: CGPathDrawingMode.fill)

        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return coloredImage!
    }

    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }

    func imageWithInsets(_ insetDimen: CGFloat) -> UIImage {
        return imageWithInset(UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }

    func imageWithInset(_ insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right, height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
