//
//  TicketTableViewController.swift
//  tpg offline
//
//  Created by Alice on 21/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesomeKit

class TicketTableViewController: UITableViewController {
    var typesTickets = [Ticket]()
    override func viewDidLoad() {
        super.viewDidLoad()
        typesTickets.append(Ticket(nom: "Tout Genève", prix: "CHF 3.-", code: "tpg1", description: "Le billet Tout Genève vous permet de voyager dans la zone 10 pendant une heure.", heure: true))
        typesTickets.append(Ticket(nom: "1/2 Tout Genève", prix: "CHF 2.-", code: "tpg2", description: "Le billet Tout Genève vous permet de voyager dans la zone 10 pendant une heure. Ce billet est au demi tarif.", heure: true))
        typesTickets.append(Ticket(nom: "Journée Tout Genève", prix: "CHF 10.-", code: "cj1", description: "Le billet journalier Tout Genève vous permet de voyager dans la zone 10 pendant une journée.", heure: false))
        typesTickets.append(Ticket(nom: "1/2 Journée Tout Genève", prix: "CHF 7.30", code: "cj2", description: "Le billet journalier Tout Genève vous permet de voyager dans la zone 10 pendant une journée. Ce billet est au demi tarif.", heure: false))
        typesTickets.append(Ticket(nom: "9h Journée Tout Genève", prix: "CHF 8.-", code: "cj91", description: "Le billet journalier Tout Genève vous permet de voyager dans la zone 10 pendant une journée à partir de 9h00.", heure: false))
        typesTickets.append(Ticket(nom: "1/2 9h Journée Tout Genève", prix: "CHF 5.60", code: "cj92", description: "Le billet journalier Tout Genève vous permet de voyager dans la zone 10 pendant une journée à partir de 9h00. Ce billet est au demi tarif.", heure: false))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return typesTickets.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ticketCell", forIndexPath: indexPath)

        let iconeTicket = FAKFontAwesome.ticketIconWithSize(20)
        iconeTicket.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        cell.imageView?.image = iconeTicket.imageWithSize(CGSize(width: 20, height: 20))
        cell.textLabel?.text = typesTickets[indexPath.row].nom
        cell.detailTextLabel?.text = typesTickets[indexPath.row].prix
        return cell
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as! AchatTicketViewController
        viewController.ticket = typesTickets[tableView.indexPathForSelectedRow!.row]
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
