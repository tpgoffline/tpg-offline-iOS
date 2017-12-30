//
//  NewFeaturesViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 22/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit

struct Feature {
    let image: UIImage
    let title: String
    let text: String
}
class NewFeaturesViewController: UIViewController {

    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet var clouds: [UIImageView]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newFeaturesLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!

    var features: [Feature] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        features.append(Feature(image: #imageLiteral(resourceName: "handshake"), title: "SNOTPG and Orientation".localized, text: "The Maps tab is no longer. Long live the Orientation tab! You will find the plans, as well as the routes and certain information of the lines. Speaking of lines, you can now take the wayback machine, and browse the great work of SNOTPG on the history of tpg.".localized))
        features.append(Feature(image: #imageLiteral(resourceName: "moon"), title: "Dark Mode".localized, text: "The dark mode of iOS would be a feature that makes you dream? Do you appreciate the black depths of the iPhone X? Or you just want to see the fusion between a japanese monster and an evil intergalactic emperor? From now on, tpg offline offers you a dark mode, and it’s easy to activate. Just switch the switch in the settings. We asked for an expert opinion with an independent commission, and the president, a man named Bruce Wayne, said that this mode is sublime.".localized))
        features.append(Feature(image: #imageLiteral(resourceName: "binoculars"), title: "NINJA!".localized, text: "Now you can monitor disruptions. In other words, you can define times when you will receive notification of disruptions on the lines of your choice by Express Notification®. This way, no more bad surprises at the connections (well, you still have some bad surprises, but at least you will not be warned at the last moment. This gives you the opportunity to think about the rest of your journey). The binoculars in the Disruptions tab is the access point.".localized))
        features.append(Feature(image: #imageLiteral(resourceName: "tick"), title: "Stability improvements".localized, text: "As always, this version improve stability and removes bugs. If you have been confront with one of them, we have a special offer. For the price of an update, we offer you a second update!".localized))

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(version, forKey: "lastVersion")
        }

        if App.darkMode {
            self.tableView.sectionIndexBackgroundColor = App.cellBackgroundColor
            self.tableView.backgroundColor = .black
            self.view.backgroundColor = .black
            self.newFeaturesLabel.textColor = .white
        }

        for cloud in clouds {
            cloud.image = #imageLiteral(resourceName: "cloud").maskWith(color: App.textColor)
        }

        self.newFeaturesLabel.text = "What's new!".localized

        self.dismissButton.setTitle("Dismiss".localized, for: .normal)
        self.dismissButton.setTitleColor(App.darkMode ? #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1) : .white, for: .normal)
        self.dismissButton.backgroundColor = App.darkMode ? App.cellBackgroundColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        self.dismissButton.cornerRadius = self.dismissButton.bounds.height / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        cityImageView.transform = CGAffineTransform(translationX: scrollView.contentOffset.y / -5, y: 0)
        for cloud in clouds {
            cloud.transform = CGAffineTransform(translationX: scrollView.contentOffset.y / -10, y: 0)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            return UIInterfaceOrientationMask.portrait
        } else {
            return .all
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func exit() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewFeaturesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newFeature", for: indexPath) as? NewFeaturesTableViewCell
            else { return UITableViewCell() }
        cell.feature = features[indexPath.row]
        return cell
    }
}
