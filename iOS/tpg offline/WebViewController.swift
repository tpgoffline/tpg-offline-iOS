//
//  WebViewController.swift
//  tpg offline
//
//  Created by remy on 25/02/16.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

	@IBOutlet weak var webView: UIWebView!
	
	var url: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
		webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.refreshTheme()
		webView.backgroundColor = AppValues.primaryColor
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
