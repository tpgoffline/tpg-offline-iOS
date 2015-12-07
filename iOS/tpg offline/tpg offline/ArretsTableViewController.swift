//
//  ArretsTableViewController.swift
//  tpg offline
//
//  Created by Alice on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import CoreLocation
import INTULocationManager

class ArretsTableViewController: UITableViewController, UISearchResultsUpdating {
    var arrets:JSON = []
    var arretsLocalisation:JSON = []
    var arretsFavoris = [String:String]?()
    var listeNomsArrets: [String] = []
    var filtredResults = [String]()
    var resultSearchController = UISearchController()
    let locationManager = CLLocationManager()
    let tpgUrl = tpgURL()
    let defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        arretsFavoris = defaults.valueForKey("arretsFavoris") as! [String:String]?
        /*locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()*/
        
        let locMgr = INTULocationManager.sharedInstance()
        locMgr.requestLocationWithDesiredAccuracy(INTULocationAccuracy.Block, timeout: 20.0) { (location, achievedAccuracy, status) -> Void in
            if status == INTULocationStatus.Success {
                let location = location
                self.locationManager.stopUpdatingLocation()
                if let dataArretsLocalisation = self.tpgUrl.getStopsbyLocation(location!) {
                    self.arretsLocalisation = JSON(data: dataArretsLocalisation)
                    self.tableView.reloadData()
                }
            }
            else if status == INTULocationStatus.TimedOut {
                print("TimedOut")
            }
            else {
                print("Error")
            }
        }
        
        // Result Search Controller
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.barTintColor = UIColor.flatOrangeColorDark()
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.placeholder = "Rechercher parmi les arrets"
        resultSearchController.searchBar.tintColor = UIColor.whiteColor()
        tableView.tableHeaderView = self.resultSearchController.searchBar
        
        // Tab Bar and Navigation Bar
        tabBarController!.tabBar.barTintColor = UIColor.flatOrangeColorDark()
        tabBarController!.tabBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor.flatOrangeColorDark()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        tabBarController!.tabBar.items![0].title = "Arrets"
        let iconeBus = FAKFontAwesome.busIconWithSize(20)
        iconeBus.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController!.tabBar.items![0].image = iconeBus.imageWithSize(CGSize(width: 20, height: 20))
        
        if let dataArrets = tpgUrl.getAllStops() {
            arrets = JSON(data: dataArrets)
            
            for var i = 0; i < arrets["stops"].count; i++ {
                listeNomsArrets.append(arrets["stops"][i]["stopName"].string!)
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        arretsFavoris = defaults.valueForKey("arretsFavoris") as! [String:String]?
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.resultSearchController.active {
            return 1
        }
        else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.resultSearchController.active {
            return self.filtredResults.count
        }
        else if section == 0 {
            return arretsLocalisation.count
        }
        else if section == 1 {
            return arretsFavoris!.count
        }
        else {
            return arrets["stops"].count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !self.resultSearchController.active {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("iconeArretsCell", forIndexPath: indexPath) as! ArretsImageTableViewCell
                
                let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                iconLocation.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.labelLogo.attributedText = iconLocation.attributedString()
                
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                
                cell.nomArret?.text = arretsLocalisation["stops"][indexPath.row]["stopName"].stringValue
                
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.flatOrangeColorDark()
                cell.selectedBackgroundView = backgroundView
                
                return cell
            }
            else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("iconeArretsCell", forIndexPath: indexPath) as! ArretsImageTableViewCell
                
                let iconFavoris = FAKFontAwesome.starIconWithSize(20)
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.labelLogo.attributedText = iconFavoris.attributedString()
                
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                
                cell.nomArret?.text = [String](arretsFavoris!.keys)[indexPath.row]
                
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.flatOrangeColorDark()
                cell.selectedBackgroundView = backgroundView
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                
                cell.textLabel?.text = listeNomsArrets[indexPath.row]
                
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.flatOrangeColorDark()
                cell.selectedBackgroundView = backgroundView
                
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            
            cell.textLabel?.text = filtredResults[indexPath.row]
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            
            return cell
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        self.filtredResults.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.listeNomsArrets as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filtredResults = array as! [String]
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "afficherProchainsDeparts") {
            let departsArretsViewController:DepartsArretTableViewController = (segue.destinationViewController) as! DepartsArretTableViewController
            departsArretsViewController.stopCode = arrets["stops"][listeNomsArrets.indexOf((tableView.cellForRowAtIndexPath((tableView.indexPathForSelectedRow)!)?.textLabel?.text)!)!]["stopCode"].string!
            resultSearchController.active = false
        }
        if (segue.identifier == "afficherProchainsDepartsIcone") {
            let departsArretsViewController:DepartsArretTableViewController = (segue.destinationViewController) as! DepartsArretTableViewController
            if tableView.indexPathForSelectedRow!.section == 0 {
                departsArretsViewController.stopCode = arretsLocalisation["stops"][tableView.indexPathForSelectedRow!.row]["stopCode"].string!
            }
            else {
                departsArretsViewController.stopCode = arretsFavoris![[String](arretsFavoris!.keys)[tableView.indexPathForSelectedRow!.row]]!
            }
            resultSearchController.active = false
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
