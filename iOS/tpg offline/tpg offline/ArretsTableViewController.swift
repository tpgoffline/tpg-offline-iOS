
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
import SwiftLocation

class ArretsTableViewController: UITableViewController {
    var arretsLocalisation:JSON = []
    var filtredResults = [Arret]()
    let searchController = UISearchController(searchResultsController: nil)
    let locationManager = CLLocationManager()
    let tpgUrl = tpgURL()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.backgroundColor = UIColor.flatOrangeColorDark()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        if defaults.objectForKey("arretsFavoris") == nil {
            AppValues.arretsFavoris = [:]
        }
        else {
            let decoded  = defaults.objectForKey("arretsFavoris")
            AppValues.arretsFavoris = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) as! [String:Arret]
            for (_, y) in AppValues.arretsFavoris {
                AppValues.nomCompletsFavoris.append(y.nomComplet)
            }
        }
        /*locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()*/
        
        requestLocation()
        
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = UIColor.flatOrangeColorDark()
        searchController.searchBar.placeholder = "Rechercher parmi les arrets"
        searchController.searchBar.tintColor = UIColor.whiteColor()
        tableView.tableHeaderView = self.searchController.searchBar
        
        // Tab Bar and Navigation Bar
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        tabBarController!.tabBar.barTintColor = UIColor.flatOrangeColorDark()
        tabBarController!.tabBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor.flatOrangeColorDark()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        tabBarController!.tabBar.items![0].title = "Horaires"
        let iconeHorloge = FAKIonIcons.iosClockIconWithSize(20)
        iconeHorloge.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController!.tabBar.items![0].image = iconeHorloge.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        tabBarController!.tabBar.items![1].title = "Incidents"
        let iconeAttention = FAKFontAwesome.warningIconWithSize(20)
        iconeAttention.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController!.tabBar.items![1].image = iconeAttention.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        tabBarController!.tabBar.items![2].title = "Plans"
        let iconePlan = FAKFontAwesome.mapIconWithSize(20)
        iconePlan.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        tabBarController!.tabBar.items![2].image = iconePlan.imageWithSize(CGSize(width: 20, height: 20)).imageWithRenderingMode(.AlwaysOriginal)
        
        if let dataArrets = tpgUrl.getAllStops() {
            let arrets = JSON(data: dataArrets)
            
            for var i = 0; i < arrets["stops"].count; i++ {
                AppValues.stopName.append(arrets["stops"][i]["stopName"].string!)
                AppValues.nomsCompletsArrets[arrets["stops"][i]["stopCode"].string!] = arrets["stops"][i]["stopName"].string!
                AppValues.arrets[arrets["stops"][i]["stopName"].string!] = Arret(
                    nomComplet: arrets["stops"][i]["stopName"].string!,
                    titre: arrets["stops"][i]["titleName"].string!,
                    sousTitre: arrets["stops"][i]["subTitleName"].string!,
                    stopCode: arrets["stops"][i]["stopCode"].string!
                )
            }
            AppValues.stopName = AppValues.stopName.sort({ (value1, value2) -> Bool in
                if (value1.lowercaseString < value2.lowercaseString) {
                    return true
                } else {
                    return false
                }
            })
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        requestLocation()
        tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if searchController.active {
            return 1
        }
        else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.active {
            return self.filtredResults.count
        }
        else {
            if section == 0 {
                return arretsLocalisation["stops"].count
            }
            else if section == 1 {
                if (AppValues.arretsFavoris == nil) {
                    return 0
                }
                else {
                    return AppValues.arretsFavoris.count
                }
            }
            else {
                return AppValues.arrets.count
            }
        }
    }
    
    func requestLocation() {
        do {
            try SwiftLocation.shared.currentLocation(Accuracy.Block, timeout: 20, onSuccess: { (location) -> Void in
                if let dataArretsLocalisation = self.tpgUrl.getStopsbyLocation(location!) {
                    self.arretsLocalisation = JSON(data: dataArretsLocalisation)
                    self.tableView.reloadData()
                }}, onFail: { (error) -> Void in
                    print("Erreur")
            })
        } catch (let error) {
            print("Error \(error)")
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !searchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            if indexPath.section == 0 {
                let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                iconLocation.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arrets[AppValues.nomsCompletsArrets[arretsLocalisation["stops"][indexPath.row]["stopCode"].stringValue]!]!.titre
                cell.detailTextLabel!.text = AppValues.arrets[AppValues.nomsCompletsArrets[arretsLocalisation["stops"][indexPath.row]["stopCode"].stringValue]!]!.sousTitre
            }
            else if indexPath.section == 1 {
                let iconFavoris = FAKFontAwesome.starIconWithSize(20)
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.accessoryView = UIImageView(image: iconFavoris.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.titre
                cell.detailTextLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.sousTitre
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arrets[(AppValues.stopName[indexPath.row])]!.titre
                cell.detailTextLabel!.text = AppValues.arrets[(AppValues.stopName[indexPath.row])]!.sousTitre
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.flatOrangeColorDark()
            cell.selectedBackgroundView = backgroundView
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
            
            cell.textLabel?.text = filtredResults[indexPath.row].titre
            cell.detailTextLabel!.text = filtredResults[indexPath.row].sousTitre
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            
            return cell
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "afficherProchainsDeparts") {
            let departsArretsViewController:DepartsArretTableViewController = (segue.destinationViewController) as! DepartsArretTableViewController
            if searchController.active {
                departsArretsViewController.arret = filtredResults[(tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                if tableView.indexPathForSelectedRow!.section == 0 {
                    departsArretsViewController.arret = AppValues.arrets[AppValues.nomsCompletsArrets[arretsLocalisation["stops"][tableView.indexPathForSelectedRow!.row]["stopCode"].stringValue]!]
                }
                else if tableView.indexPathForSelectedRow!.section == 1 {
                    departsArretsViewController.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[tableView.indexPathForSelectedRow!.row]]
                }
                else {
                    departsArretsViewController.arret = AppValues.arrets[AppValues.stopName[(tableView.indexPathForSelectedRow?.row)!]]!
                }
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func filterContentForSearchText(searchText: String) {
        filtredResults = [Arret](AppValues.arrets.values).filter { arret in
            return arret.nomComplet.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
}

extension ArretsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
