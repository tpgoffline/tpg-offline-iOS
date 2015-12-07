//
//  DepartsArretTableViewController.swift
//  tpg offline
//
//  Created by Alice on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import FontAwesomeKit

class DepartsArretTableViewController: UITableViewController {
    var stopCode = ""
    var departs:JSON = []
    var listeBackgroundColor = [String:UIColor]()
    var listeColor = [String:UIColor]()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        if let dataDeparts = NSData(contentsOfURL: NSURL(string: "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode=" + stopCode)!) {
            departs = JSON(data: dataDeparts)
            title = departs["stop"]["stopName"].string
            let dataCouleurs = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("couleursLignes", ofType: "json")!)
            let couleurs = JSON(data: dataCouleurs!)
            for var i = 0; i < couleurs["colors"].count; i++ {
                listeBackgroundColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["background"].string)
                listeColor[couleurs["colors"][i]["lineCode"].string!] = UIColor(hexString: couleurs["colors"][i]["text"].string)
            }
        }
        else {
            let alert = UIAlertController(title: "Données non disponibles", message: "tpg offline n'est actuellement pas connecté à internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        var arrayFavoris = defaults.valueForKey("arretsFavoris") as! [String:String]?
        if arrayFavoris != nil {
            if arrayFavoris![title!] != nil {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
        }
        else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
        }
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
        return departs["departures"].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("departArretCell", forIndexPath: indexPath) as! DepartsTableViewCell
        
        cell.backgroundColor = listeBackgroundColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        
        cell.pictoLigne.text = departs["departures"][indexPath.row]["line"]["lineCode"].string!
        cell.labelDirection.text = departs["departures"][indexPath.row]["line"]["destinationName"].string
        
        cell.pictoLigne.textColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        cell.labelDirection.textColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        cell.labelTempsRestant.textColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]
        
        cell.pictoLigne.layer.cornerRadius = cell.pictoLigne.layer.bounds.height / 2
        cell.pictoLigne.layer.borderColor = listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!]?.CGColor
        cell.pictoLigne.layer.borderWidth = 1
        
        if (departs["departures"][indexPath.row]["waitingTime"].string == "no more") {
            cell.labelTempsRestant.text = "Fin"
        }
        else if (departs["departures"][indexPath.row]["waitingTime"].string == "&gt;1h") {
            cell.labelTempsRestant.text = ">1h"
        }
        else if (departs["departures"][indexPath.row]["waitingTime"].string == "0") {
            let iconeBus = FAKFontAwesome.busIconWithSize(20)
            iconeBus.addAttribute(NSForegroundColorAttributeName, value: listeColor[departs["departures"][indexPath.row]["line"]["lineCode"].string!])
            cell.labelTempsRestant.attributedText = iconeBus.attributedString()
        }
        else {
            cell.labelTempsRestant.text = departs["departures"][indexPath.row]["waitingTime"].string! + "'"
        }
        
        return cell
    }
    
    func toggleFavorite(sender: AnyObject!) {
        var arrayFavoris = defaults.valueForKey("arretsFavoris") as! [String:String]?
        if arrayFavoris == nil {
            let array: [String:String] = [title! : stopCode]
            defaults.setValue(array, forKey: "arretsFavoris")
        }
        else {
            if arrayFavoris![title!] != nil {
                arrayFavoris?.removeAtIndex((arrayFavoris?.indexForKey(title!))!)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starOIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            else {
                arrayFavoris![title!] = stopCode
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: FAKFontAwesome.starIconWithSize(20).imageWithSize(CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: "toggleFavorite:")
            }
            defaults.setValue(arrayFavoris, forKey: "arretsFavoris")
        }
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
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func refresh(sender:AnyObject)
    {
        if let dataDeparts = NSData(contentsOfURL: NSURL(string: "http://prod.ivtr-od.tpg.ch/v1/GetNextDepartures.json?key=d95be980-0830-11e5-a039-0002a5d5c51b&stopCode=" + stopCode)!) {
            departs = JSON(data: dataDeparts)
        }
        else {
            let alert = UIAlertController(title: "Données non disponibles", message: "tpg offline n'est actuellement pas connecté à internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
        tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
}
