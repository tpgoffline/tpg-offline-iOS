//
//  MapsTableViewController.swift
//  tpg offline
//
//  Created by Remy on 18/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

class MapsTableViewController: UITableViewController {

    var maps: [String: UIImage] = [
        "Urban map".localized: #imageLiteral(resourceName: "urbainMap"),
        "Regional map".localized: #imageLiteral(resourceName: "periurbainMap"),
        "Noctambus urban map".localized: #imageLiteral(resourceName: "nocUrbainMap"),
        "Noctambus regional map".localized: #imageLiteral(resourceName: "nocPeriurbainMap")
    ]
    
    var maps2018: [String: UIImage] = [
        "Urban map".localized: #imageLiteral(resourceName: "urbainMap2018"),
        "Regional map".localized: #imageLiteral(resourceName: "periurbainMap2018"),
        "Noctambus urban map".localized: #imageLiteral(resourceName: "nocUrbainMap2018"),
        "Noctambus regional map".localized: #imageLiteral(resourceName: "nocPeriurbainMap2018")
    ]

    var titles = [
        "Urban map".localized,
        "Regional map".localized,
        "Noctambus urban map".localized,
        "Noctambus regional map".localized
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Maps".localized

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as? MapsTableViewControllerRow else {
            return UITableViewCell()
        }

        cell.titleLabel.text = titles[indexPath.row]
        if Date().timeIntervalSince1970 < 1512860400 {
            cell.mapImage = self.maps[titles[indexPath.row]]
        } else {
            cell.mapImage = self.maps2018[titles[indexPath.row]]
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            guard let destinationViewController = segue.destination as? MapViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let row = tableView.cellForRow(at: indexPath) as? MapsTableViewControllerRow else { return }
            tableView.deselectRow(at: indexPath, animated: false)
            destinationViewController.mapImage = row.mapImage
            destinationViewController.title = row.titleLabel.text
        }
    }
}

class MapsTableViewControllerRow: UITableViewCell {
    @IBOutlet private weak var mapImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var mapImage: UIImage? {
        get {
            return mapImageView.image
        } set {
            mapImageView.image = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = .black

        let view = UIView()
        view.backgroundColor = .clear
        self.selectedBackgroundView = view
    }
}
