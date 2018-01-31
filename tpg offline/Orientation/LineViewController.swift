//
//  LineViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 13/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import SafariServices
import Crashlytics

class LineViewController: UIViewController {

    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var waybackMachineButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var arrowsImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelTopConstraint: NSLayoutConstraint!

    var line: Line?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let line = self.line else { return }

        self.title = String(format: "Line %@".localized, line.line)

        App.log("Show line \(line.line)")
        Answers.logCustomEvent(withName: "Show departures",
                               customAttributes: ["line": line.line])

        self.departureLabel.text = line.departureName
        self.departureLabel.textColor = App.textColor
        self.arrivalLabel.text = line.arrivalName
        self.arrivalLabel.textColor = App.textColor
        self.descriptionLabel.textColor = App.textColor

        self.view.backgroundColor = App.cellBackgroundColor
        self.arrowsImageView.image = #imageLiteral(resourceName: "horizontalReverse").maskWith(color: App.textColor)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        if Locale.current.languageCode == "fr", let descriptionFR = line.textFR {
            self.descriptionLabel.text = descriptionFR
        } else if let descriptionEN = line.textEN {
            self.descriptionLabel.text = descriptionEN
        } else {
            self.descriptionLabel.text = ""
            descriptionLabelTopConstraint.constant = 0
        }

        if line.snotpgURL != "" {
            let color = App.color(for: line.line)
            waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            waybackMachineButton.setTitle("Wayback Machine".localized, for: .normal)
            waybackMachineButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            waybackMachineButton.addTarget(self, action: #selector(self.showSnotpgPage), for: .touchUpInside)
            waybackMachineButton.backgroundColor = App.darkMode ? .black : App.color(for: line.line)
            waybackMachineButton.cornerRadius = waybackMachineButton.bounds.height / 2
            waybackMachineButton.clipsToBounds = true
        } else {
            self.buttonHeightConstraint.constant = 0
        }

        if App.darkMode {
            self.tableView.sectionIndexBackgroundColor = App.cellBackgroundColor
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.backgroundColor = .black
        }

        ColorModeManager.shared.addColorModeDelegate(self)
    }

    @objc func showSnotpgPage() {
        guard let line = self.line else { return }
        let vc = SFSafariViewController(url: URL(string: line.snotpgURL)!, entersReaderIfAvailable: false)
        if App.darkMode, #available(iOS 10.0, *) {
            vc.preferredBarTintColor = .black
        }
        vc.delegate = self

        self.present(vc, animated: true)
    }

    override func colorModeDidUpdated() {
        super.colorModeDidUpdated()
        self.departureLabel.textColor = App.textColor
        self.arrivalLabel.textColor = App.textColor
        self.view.backgroundColor = App.cellBackgroundColor
        self.arrowsImageView.image = #imageLiteral(resourceName: "horizontalReverse").maskWith(color: App.textColor)
        self.tableView.backgroundColor = App.darkMode ? .black : .white
        self.tableView.reloadData()
        guard let line = self.line else { return }
        if line.snotpgURL != "" {
            let color = App.color(for: line.line)
            waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: App.darkMode ? color : color.contrast), for: .normal)
            waybackMachineButton.setTitleColor(App.darkMode ? color : color.contrast, for: .normal)
            waybackMachineButton.backgroundColor = App.darkMode ? .black : App.color(for: line.line)
        } else {
            self.buttonHeightConstraint.constant = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.view.traitCollection.verticalSizeClass == .compact && UIDevice.current.userInterfaceIdiom == .phone {
            self.stackView.axis = .horizontal
            self.stackView.distribution = .fillEqually
        } else {
            self.stackView.axis = .vertical
            self.stackView.distribution = .fill
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDepartures" {
            guard let destinationViewController = segue.destination as? DeparturesViewController else {
                return
            }
            let indexPath = tableView.indexPathForSelectedRow!
            self.tableView.deselectRow(at: indexPath, animated: true)
            destinationViewController.stop = (tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell)?.stop
        }
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }
}

extension LineViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.line?.courses.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.line?.courses[safe: section]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "busRouteCell",
            for: indexPath)
            as? BusRouteTableViewCell else {
                return UITableViewCell()
        }

        cell.configure(with: self.line?.courses[safe: indexPath.section]?[safe: indexPath.row] ?? 0,
                       color: App.color(for: line?.line ?? ""),
                       first: indexPath.row == 0,
                       last: (indexPath.row + 1) == self.line?.courses[safe: indexPath.section]?.count)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        let departureId = line?.courses[safe: section]?[safe: 0] ?? 0
        let departure = App.stops.filter({ $0.appId == departureId })[safe: 0]
        let arrivalId = line?.courses[safe: section]?[safe: (line?.courses[safe: section]?.count ?? 1) - 1]
        let arrival = App.stops.filter({ $0.appId == arrivalId })[safe: 0]
        headerCell?.textLabel?.text = "\(departure?.name ?? "") - \(arrival?.name ?? "")"
        headerCell?.backgroundColor = App.darkMode ? .black : App.color(for: line?.line ?? "")
        headerCell?.textLabel?.textColor = App.darkMode ? App.color(for: line?.line ?? "") : headerCell?.backgroundColor?.contrast

        return headerCell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

extension LineViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

extension LineViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        guard let row = tableView.cellForRow(at: indexPath) as? BusRouteTableViewCell else { return nil }

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "departuresViewController") as? DeparturesViewController
            else { return nil }

        detailVC.stop = row.stop
        previewingContext.sourceRect = row.frame
        return detailVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
