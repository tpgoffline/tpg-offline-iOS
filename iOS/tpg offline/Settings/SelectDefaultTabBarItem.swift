//
//  SelectDefaultTabBarItem.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 20/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Chameleon
import FontAwesomeKit

class SelectDefaultTabBarItem: UITableViewController {
    let defaults = UserDefaults.standard
    var rowSelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        rowSelected = defaults.integer(forKey: "selectedTabBar")
        tableView.backgroundColor = AppValues.primaryColor
     
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabBarController!.tabBar.items!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choixTabDefaultCell", for: indexPath)

        cell.imageView?.image = tabBarController!.tabBar.items![indexPath.row].image
        cell.textLabel?.text = tabBarController!.tabBar.items![indexPath.row].title
        cell.selectionStyle = .none
        if indexPath.row == rowSelected {
            let iconOk = FAKFontAwesome.checkIcon(withSize: 20)!
            iconOk.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            cell.accessoryView = UIImageView(image: iconOk.image(with: CGSize(width: 20, height: 20)))
        }
        else {
            cell.accessoryView = nil
        }
        cell.textLabel?.textColor = AppValues.textColor
        cell.backgroundColor = AppValues.primaryColor
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.set(indexPath.row, forKey: UserDefaultsKeys.selectedTabBar.rawValue)
        rowSelected = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
