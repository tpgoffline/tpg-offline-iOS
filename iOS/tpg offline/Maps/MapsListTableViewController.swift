//
//  MapsListTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class MapsListTableViewController: UITableViewController {

	let mapsList = ["Plan urbain", "Plan régional", "Plan Noctambus urbain", "Plan Noctambus régional"]

	override func viewDidLoad() {
		super.viewDidLoad()
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        refreshTheme()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		refreshTheme()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return mapsList.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "plansCell", for: indexPath)

		cell.textLabel?.text = mapsList[indexPath.row].localized
		cell.textLabel?.textColor = AppValues.textColor
		cell.backgroundColor = AppValues.primaryColor

		return cell
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showMap" {
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let mapViewController = nav.viewControllers[0] as? MapViewController else {
                return
            }
			mapViewController.mapImage = UIImage(named: mapsList[(tableView.indexPathForSelectedRow?.row)!])
		}
	}

}

extension MapsListTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}
