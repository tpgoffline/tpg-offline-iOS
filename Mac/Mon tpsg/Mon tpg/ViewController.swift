//
//  ViewController.swift
//  tpg
//
//  Created by remy on 03/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate  {
    
    @IBOutlet weak var stationField: NSTextField!
    @IBOutlet weak var tableau: NSTableView!
    var tpgURLconstructor: tpgURLconstruct! = nil
    var horaires: Int = 0
    var xmlNextDepartures: XMLIndexer! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        tpgURLconstructor = tpgURLconstruct(cleAPI: "d95be980-0830-11e5-a039-0002a5d5c51b")
        let nib = NSNib(nibNamed: "HorairesCellView", bundle: NSBundle.mainBundle())
        tableau.registerNib(nib!, forIdentifier: "HorairesCellView")
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func enumerate(indexer: XMLIndexer) {
        for child in indexer.children {
            print(child.element!.name)
            enumerate(child)
        }
    }
    
    @IBAction func rechercheCodeStation(sender: AnyObject) {
        let urlString = tpgURLconstructor.getStopsURL(stationField.stringValue)
        if urlString == "" {
            let alerte = NSAlert()
            alerte.alertStyle = NSAlertStyle.WarningAlertStyle
            alerte.messageText = "Ouuups !"
            alerte.informativeText = "L'arret n'as pas été trouvé"
            alerte.runModal()
        }
        else {
            let url = NSURL(string: urlString)!
            let data = NSData(contentsOfURL: url)!
            var xml = SWXMLHash.parse(data)
            switch xml["stops"]["stops"]["stop"][0]["stopName"] {
            case .Element(let elem):
                stationField.stringValue = elem.text!
                rechercheHoraire((xml["stops"]["stops"]["stop"][0]["stopCode"].element?.text)!)
            case .Error( _):
                let alerte = NSAlert()
                alerte.alertStyle = NSAlertStyle.WarningAlertStyle
                alerte.messageText = "Ouuups !"
                alerte.informativeText = "L'arret n'as pas été trouvé"
                alerte.runModal()
            default:
                print("", appendNewline: false)
            }
        }
    }
    
    func rechercheHoraire(codeStation: String) {
        let urlString = tpgURLconstructor.getNextDeparturesURL(codeStation)
        if urlString == "" {
            let alerte = NSAlert()
            alerte.alertStyle = NSAlertStyle.WarningAlertStyle
            alerte.messageText = "Ouuups !"
            alerte.informativeText = "L'arret n'as pas été trouvé"
            alerte.runModal()
        }
        else {
            let url = NSURL(string: urlString)!
            let data = NSData(contentsOfURL: url)!
            xmlNextDepartures = SWXMLHash.parse(data)
            horaires = 0
            horaires = xmlNextDepartures["nextDepartures"]["departures"]["departure"].all.count
            tableau.reloadData()
        }
        
    }
    func numberOfRowsInTableView(tableau: NSTableView) -> Int
    {
        let numberOfRows:Int = horaires
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("HorairesCellView", owner: self) as! HorairesCellView
        let nomImageLigne = "Picto " + (xmlNextDepartures["nextDepartures"]["departures"]["departure"][row]["connection"]["lineCode"].element?.text)!
        cell.ligne.stringValue = "Ligne " + (xmlNextDepartures["nextDepartures"]["departures"]["departure"][row]["connection"]["lineCode"].element?.text)!
        cell.imageLigne.image = NSImage(named: nomImageLigne)
        if cell.imageLigne.image?.name() == nil {
            cell.imageLigne.image = NSImage(named: "Picto ?")
        }
        cell.direction.stringValue = (xmlNextDepartures["nextDepartures"]["departures"]["departure"][row]["connection"]["destinationName"].element?.text)!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        switch xmlNextDepartures["nextDepartures"]["departures"]["departure"][row]["timestamp"] {
        case .Element(let elem):
            if (xmlNextDepartures["nextDepartures"]["departures"]["departure"][row]["waitingTime"].element?.text)! == "&gt;1h" {
                let date = dateFormatter.dateFromString(elem.text!)
                dateFormatter.dateFormat = "HH:mm:ss"
                var texte = dateFormatter.stringFromDate(date!)
                texte += " | >1h"
               cell.time.stringValue = texte
            }
            else {
                let date = dateFormatter.dateFromString(elem.text!)
                dateFormatter.dateFormat = "HH:mm:ss"
                var texte = dateFormatter.stringFromDate(date!)
                texte += " | "
                texte += (xmlNextDepartures["nextDepartures"]["departures"]["departure"][row]["waitingTime"].element?.text)!
                texte += " min"
                cell.time.stringValue = texte
            }
        case .Error( _):
            cell.time.stringValue = "Plus aucun départ"
        default:
            print("", appendNewline: false)
        }
        
        return cell
    }
}

