//
//  LineViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 13/12/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import SafariServices

class LineViewController: UIViewController {

    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var waybackMachineButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var arrowsImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!

    var line: Line?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let line = self.line else { return }
        if App.darkMode {
            self.navigationController?.navigationBar.tintColor = App.color(for: line.line)
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.color(for: line.line)]
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.color(for: line.line)]
            }
            self.tableView.backgroundColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = App.color(for: line.line)
            self.navigationController?.navigationBar.tintColor = App.color(for: line.line).contrast
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.color(for: line.line).contrast]
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedStringKey.foregroundColor: App.color(for: line.line).contrast]
            }
        }

        self.title = String(format: "Line %@".localized, line.line)
        if !App.darkMode {
            UIApplication.shared.statusBarStyle = App.color(for: line.line).contrast == .white ?
                .lightContent : .default
        }

        self.departureLabel.text = line.departureName
        self.departureLabel.textColor = App.textColor
        self.arrivalLabel.text = line.arrivalName
        self.arrivalLabel.textColor = App.textColor

        self.view.backgroundColor = App.cellBackgroundColor
        self.arrowsImageView.image = #imageLiteral(resourceName: "reverse").maskWith(color: App.textColor)

        if line.snotpgURL != "" {
            waybackMachineButton.setImage(#imageLiteral(resourceName: "rocket").maskWith(color: App.color(for: line.line)), for: .normal)
            waybackMachineButton.setTitle("Wayback Machine".localized, for: .normal)
            waybackMachineButton.setTitleColor(App.color(for: line.line), for: .normal)
            waybackMachineButton.addTarget(self, action: #selector(self.showSnotpgPage), for: .touchUpInside)
        } else {
            self.buttonHeightConstraint.constant = 0
        }
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let line = self.line else { return }
        if App.darkMode {
            self.navigationController?.navigationBar.tintColor = App.color(for: line.line)
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.color(for: line.line)]
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.color(for: line.line)]
            }
            self.tableView.backgroundColor = .black
        } else {
            self.navigationController?.navigationBar.barTintColor = App.color(for: line.line)
            self.navigationController?.navigationBar.tintColor = App.color(for: line.line).contrast
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.color(for: line.line).contrast]
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes =
                    [NSAttributedStringKey.foregroundColor: App.color(for: line.line).contrast]
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        }

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: App.textColor]
        navigationController?.navigationBar.tintColor = App.darkMode ? App.textColor : #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        if App.darkMode {
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.navigationController?.navigationBar.barStyle = .default
        }
        self.navigationController?.navigationBar.barTintColor = nil
        UIApplication.shared.statusBarStyle = App.darkMode ? .lightContent : .default
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
