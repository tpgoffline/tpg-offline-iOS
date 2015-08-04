//
//  ProblemesViewController.swift
//  Mon tpg
//
//  Created by remy on 17/06/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import Cocoa

func colorWithHexColorString(colorString: String) -> NSColor?
{
    var color: NSColor? = nil
    
    var colorCode = UInt32()
    
    var redByte:CGFloat = 255;
    var greenByte:CGFloat = 255;
    var blueByte: CGFloat = 255;
    
    let scanner = NSScanner(string: colorString)
    if scanner.scanHexInt(&colorCode) {
        redByte = CGFloat(colorCode & 0xff0000)
        greenByte = CGFloat(colorCode & 0x00ff00)
        blueByte =  CGFloat(colorCode & 0xff)
        color = NSColor(red: redByte, green: greenByte, blue: blueByte, alpha: 1.0)
    }
    
    return color
}


class ProblemesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate  {
    
    @IBOutlet weak var labelProblemes: NSTextField!
    @IBOutlet weak var tableau: NSTableView!
    var tpgURLconstructor: tpgURLconstruct! = nil
    var xml: XMLIndexer! = nil
    var xmlLinesColor: XMLIndexer! = nil
    var problemes: Int = 0
    override func viewDidAppear() {
        super.viewDidAppear()
        var urlString = tpgURLconstructor.getDisruptionsURL()
        var url = NSURL(string: urlString)!
        var data = NSData(contentsOfURL: url)!
        xml = SWXMLHash.parse(data)
        urlString = tpgURLconstructor.getLinesColorsURL()
        url = NSURL(string: urlString)!
        data = NSData(contentsOfURL: url)!
        xmlLinesColor = SWXMLHash.parse(data)
        problemes = 0
        problemes = xml["disruptions"]["disruptions"]["disruption"].all.count
        labelProblemes.stringValue = String(problemes) + " Problèmes en cours"
        tableau.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tpgURLconstructor = tpgURLconstruct(cleAPI: "d95be980-0830-11e5-a039-0002a5d5c51b")
        let nib = NSNib(nibNamed: "ProblemesCellView", bundle: NSBundle.mainBundle())
        tableau.registerNib(nib!, forIdentifier: "ProblemesCellView")
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfRowsInTableView(tableau: NSTableView) -> Int
    {
        let numberOfRows:Int = problemes
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("ProblemesCellView", owner: self) as! ProblemesCellView
        let nomImageLigne = "Picto " + (xml["disruptions"]["disruptions"]["disruption"][row]["lineCode"].element?.text)!
        cell.ligne.stringValue = "Ligne " + (xml["disruptions"]["disruptions"]["disruption"][row]["lineCode"].element?.text)!
        cell.imageLigne.image = NSImage(named: nomImageLigne)
        if cell.imageLigne.image?.name() == nil {
            cell.imageLigne.image = NSImage(named: "Picto ?")
        }
        cell.consequence.stringValue = (xml["disruptions"]["disruptions"]["disruption"][row]["consequence"].element?.text)!
        cell.cause.stringValue = (xml["disruptions"]["disruptions"]["disruption"][row]["nature"].element?.text)!
        return cell
    }
    func trouverHexa(lineCode:String!) -> NSColor!{
        for x in xmlLinesColor["colors"]["colors"]["color"] {
            if x["lineCode"].element?.text == lineCode {
                print(colorWithHexColorString((x["hexa"].element?.text)!), appendNewline: true)
                return colorWithHexColorString((x["hexa"].element?.text)!)
            }
        }
        return NSColor(red:0.78, green:0.78, blue:0.78, alpha:1)
    }
}



