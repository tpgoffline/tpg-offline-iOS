//
//  AppDelegate.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 01/10/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

class WindowController: NSWindowController {
    
    @IBOutlet weak var categoriesSegmentedControl: NSSegmentedControl!
    override func windowDidLoad() {
        super.windowDidLoad()
        dump(window)
        window!.titleVisibility = .hidden
        
        let categories = ["Departures", "Incidents", "Itineraires", "Plans", "Réglages"]
        categoriesSegmentedControl.segmentCount = categories.count
        for (i, x) in categories.enumerated() {
            categoriesSegmentedControl.setLabel(x, forSegment: i)
        }
    }
}
