//
//  ConnectionsViewController.swift
//  Mon tpg
//
//  Created by remy on 24/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import Cocoa
import MapKit


class ConnectionsViewController: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate, MKMapViewDelegate, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var arret: NSComboBox!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var tableau: NSTableView!
    @IBOutlet weak var labelStation: NSTextField!
    var tpgURLconstructor: tpgURLconstruct! = nil
    var xmlStops: XMLIndexer!
    var arrets:Int! = 0
    var arretSelectione = 0
    var idAnnotation = 0
    var tableauArretsPhysiques = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tpgURLconstructor = tpgURLconstruct(cleAPI: "d95be980-0830-11e5-a039-0002a5d5c51b")
        let urlString = tpgURLconstructor.getStopsURL(nil)
        let url = NSURL(string: urlString)!
        let data = NSData(contentsOfURL: url)!
        xmlStops = SWXMLHash.parse(data)
        arret.reloadData()
        let nib = NSNib(nibNamed: "ConnectionsCellView", bundle: NSBundle.mainBundle())
        tableau.registerNib(nib!, forIdentifier: "ConnectionsCellView")
    }
    
    @IBAction func actualiserArret(sender: AnyObject!) {
        tableauArretsPhysiques = [[String]]()
        if map.annotations.count != 0 {
            print( "\(_stdlib_getDemangledTypeName(map.annotations[0]))")
        }
        for x in map.annotations {
            if ("\(_stdlib_getDemangledTypeName(x))" == "NSKVONotifying_MKPointAnnotation") {
                map.removeAnnotation((x as! MKPointAnnotation))
            }
        }
        let urlString = tpgURLconstructor.getPhysicalStops(arret.stringValue)
        let url = NSURL(string: urlString)!
        let data = NSData(contentsOfURL: url)!
        var xmlPhysicalStop = SWXMLHash.parse(data)
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.005 , 0.005)
        for x in (xmlPhysicalStop["stops"]["stops"]["stop"][0]["physicalStops"]["physicalStop"]) {
            let latitude = CLLocationDegrees(((x["coordinates"]["latitude"].element?.text)!).doubleValue)
            let longitude = CLLocationDegrees(((x["coordinates"]["longitude"].element?.text)!).doubleValue)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let theRegion:MKCoordinateRegion = MKCoordinateRegionMake(location, theSpan)
            map.setRegion(theRegion, animated: true)
            let anotation = MKPointAnnotation()
            anotation.coordinate = location
            anotation.title = x["stopName"].element?.text
            anotation.subtitle = x["physicalStopCode"].element?.text
            map.addAnnotation(anotation)
            idAnnotation += 1
            print(idAnnotation)
            for y in x["connections"]["connection"] {
                tableauArretsPhysiques.append([String(UTF8String: (x["physicalStopCode"].element?.text)!)!, String(UTF8String: (y["lineCode"].element?.text)!)!, String(UTF8String: (y["destinationName"].element?.text)!)!])
            }
        }
        labelStation.stringValue = arret.stringValue + " (" + String(tableauArretsPhysiques.count) + " arrets)"
        print(tableauArretsPhysiques, appendNewline: true)
        tableau.reloadData()
        idAnnotation = 0
    }
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        if xmlStops != nil {
            return xmlStops["stops"]["stops"]["stop"].all.count
        }
        return 0
    }
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        return (xmlStops["stops"]["stops"]["stop"][index]["stopName"].element?.text)!
    }
    
    func numberOfRowsInTableView(tableau: NSTableView) -> Int
    {
        return tableauArretsPhysiques.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        return false
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("ConnectionsCellView", owner: self) as! ConnectionsCellView
        
        let nomImageLigne = "Picto " + tableauArretsPhysiques[row][1]
        cell.imageLigne.image = NSImage(named: nomImageLigne)
        if cell.imageLigne.image?.name() == nil {
            cell.imageLigne.image = NSImage(named: "Picto ?")
        }
        
        cell.direction.stringValue = tableauArretsPhysiques[row][2]
        cell.arret.stringValue = tableauArretsPhysiques[row][0]
        return cell
    }
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return AnyObject?()
    }
}
