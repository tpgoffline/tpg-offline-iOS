//
//  PlansViewController.swift
//  Mon tpg
//
//  Created by remy on 21/06/2015.
//  Copyright (c) 2015 dacostafaro. All rights reserved.
//

import Cocoa

class PlansViewController: NSViewController {
    @IBOutlet weak var combo: NSComboBox!
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = NSImage(named: "Plan peripherique")
        imageView.image = image
        combo.stringValue = "Plan périphérique"
        // Do view setup here.
    }
    
    @IBAction func actualiserImage(sender: AnyObject!) {
        var image: NSImage!
        if combo.stringValue == "Plan périphérique" {
            image = NSImage(named: "Plan peripherique")
        }
        else {
            image = NSImage(named: combo.stringValue)
        }
        imageView.image = image
    }
    
}
