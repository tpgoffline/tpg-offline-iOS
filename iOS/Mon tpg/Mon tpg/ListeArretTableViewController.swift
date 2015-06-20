//
//  FirstViewController.swift
//  Mon tpg
//
//  Created by remy on 02/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import UIKit

class ListeArretTableViewController: UITableViewController {
    var listeArrets = [XMLIndexer]()
    var xmlArrets:XMLIndexer! = nil
    var tpgURLConstruct: tpgURLconstruct!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tpgURLConstruct = tpgURLconstruct(cleAPI: "d95be980-0830-11e5-a039-0002a5d5c51b")
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("arrets", ofType: "xml")!)
        let data = NSData(contentsOfURL: url)!
        self.xmlArrets = SWXMLHash.lazy(data)
        listeArrets = self.xmlArrets["stops"]["stops"]["stop"].all
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listeArrets.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArretCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = listeArrets[indexPath.row]["stopName"].element?.text
        cell.detailTextLabel?.text = String(listeArrets[indexPath.row]["connections"]["connection"].all.count) + " lignes"
        cell.tag = indexPath.row
        return cell
    }
    
    @IBAction func refreshArretListe(sender:AnyObject!) {
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "arret" {
            print((sender as! UITableViewCell).tag, appendNewline: true)
            let arretViewController = segue.destinationViewController as! ArretTableViewController
            arretViewController.arret = ((sender as! UITableViewCell).textLabel?.text)!
            arretViewController.arretCode = (self.xmlArrets["stops"]["stops"]["stop"][(sender as! UITableViewCell).tag]["stopName"].element?.text)!
        }
    }
}

