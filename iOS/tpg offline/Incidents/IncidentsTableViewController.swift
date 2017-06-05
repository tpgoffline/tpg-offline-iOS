//
//  IncidentsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseCrash
import DGElasticPullToRefresh
import SCLAlertView
import SwiftyJSON

class IncidentsTableViewController: UITableViewController {
    let defaults = UserDefaults.standard
    var distrubtions: [Distrubtions] = []
    var error = false
    var noDistrubtions = false
    var loading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseCrashMessage("Incidents")

        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.primaryColor

        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in

            self!.refresh()
            self?.tableView.dg_stopLoading()

            }, loadingView: loadingView)

        tableView.dg_setPullToRefreshFillColor(AppValues.textColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        navigationController?.navigationBar.barTintColor = .flatOrangeDark
        navigationController?.navigationBar.tintColor = .white

        var barButtonsItems: [UIBarButtonItem] = []

        barButtonsItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"), style: UIBarButtonItemStyle.done, target: self, action: #selector(IncidentsTableViewController.refresh)))

        self.navigationItem.rightBarButtonItems = barButtonsItems

        refresh()

        refreshTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.dg_setPullToRefreshFillColor(AppValues.textColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)

        refreshTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func refresh() {
        noDistrubtions = false
        error = false
        distrubtions = []
        loading = true
        tableView.reloadData()
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetDisruptions.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b"]).responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    FirebaseCrashMessage("\(String(describing: json.rawString()))")
                    if json["disruptions"].count != 0 {
                        for x in 0...json["disruptions"].count - 1 where AppValues.linesColor[json["disruptions"][x]["lineCode"].string!] != nil {
                                self.distrubtions.append(Distrubtions(lineCode: json["disruptions"][x]["lineCode"].string!, title: json["disruptions"][x]["nature"].string!, subTitle: json["disruptions"][x]["consequence"].string!))
                        }
                    } else {
                        self.noDistrubtions = true
                    }
                    self.loading = false
                    self.tableView.reloadData()
                } else {
                    #if DEBUG
                        if let error = response.result.error {
                            let alert = SCLAlertView()
                            alert.showError("Alamofire", subTitle: "DEBUG - \(error.localizedDescription)", feedbackType: .impactMedium)
                        }
                    #endif
                    self.loading = false
                    self.error = true
                    self.tableView.reloadData()
                }
        }
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    deinit {
        if let table = tableView {
            table.dg_removePullToRefresh()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 1
        } else if noDistrubtions == true {
            return 1
        } else if error {
            return 1
        } else {
            return distrubtions.count
        }
    }

    func labelToImage(_ label: UILabel!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCellTableViewCell // swiftlint:disable:this force_cast

            cell.activityIndicator.stopAnimating()

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = .flatBlue
                cell.titleLabel?.textColor = .white
                cell.subTitleLabel?.textColor = .white
                cell.activityIndicator.color = .white
            } else {
                cell.backgroundColor = .white
                cell.titleLabel?.textColor = .flatBlue
                cell.subTitleLabel?.textColor = .flatBlue
                cell.activityIndicator.color = .flatBlue
            }
            cell.titleLabel?.text = "Chargement".localized
            cell.subTitleLabel?.text = "Merci de patienter".localized
            cell.accessoryView = nil

            cell.activityIndicator.startAnimating()

            return cell
        } else if noDistrubtions {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incidentsCell", for: indexPath)
            cell.textLabel?.text = "Aucun incident".localized

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH"
            let heure = Int(dateFormatter.string(from: Date())) ?? 12
            if heure < 6 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !".localized
            } else if heure < 18 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne journée !".localized
            } else if heure < 22 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne soirée !".localized
            } else {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !".localized
            }

            if AppValues.primaryColor.contrast == .white {
                cell.textLabel?.textColor = .black
                cell.detailTextLabel?.textColor = .black
                cell.backgroundColor = .flatYellow

                cell.imageView?.image = #imageLiteral(resourceName: "smile").maskWithColor(color: .black)
            } else {
                cell.textLabel?.textColor = .flatYellowDark
                cell.detailTextLabel?.textColor = .flatYellowDark
                cell.backgroundColor = .white

                cell.imageView?.image = #imageLiteral(resourceName: "smile").maskWithColor(color: .flatYellowDark)
            }
            return cell
        } else if error {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incidentsCell", for: indexPath)
            cell.textLabel?.text = "Pas de réseau !".localized

            cell.detailTextLabel!.text = "tpg offline n'est pas connecté au réseau. Il est impossible de charger les perturbations en cours sur le réseau tpg sans réseau.".localized

            if AppValues.primaryColor.contrast == .white {
                cell.textLabel?.textColor = .white
                cell.detailTextLabel?.textColor = .white

                cell.imageView?.image = #imageLiteral(resourceName: "internetError").maskWithColor(color: .white)
                cell.backgroundColor = .flatYellowDark
            } else {
                cell.textLabel?.textColor = .flatYellowDark
                cell.detailTextLabel?.textColor = .flatYellowDark

                cell.backgroundColor = .white
                cell.imageView?.image = #imageLiteral(resourceName: "internetError").maskWithColor(color: .flatYellowDark)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incidentsCell", for: indexPath)
            cell.textLabel?.text = distrubtions[indexPath.row].title
            cell.detailTextLabel!.text = distrubtions[indexPath.row].subTitle

            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = distrubtions[indexPath.row].lineCode
            labelPictoLigne.textAlignment = .center

            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1

            FirebaseCrashMessage(distrubtions[indexPath.row].describe())

            if AppValues.primaryColor.contrast == .white {
                cell.backgroundColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                cell.textLabel?.textColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]
                cell.detailTextLabel?.textColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]
                labelPictoLigne.textColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]
                labelPictoLigne.layer.borderColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]?.cgColor
            } else {
                if AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.contrast == .white {
                    cell.backgroundColor = .white
                    cell.textLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                    cell.detailTextLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                    labelPictoLigne.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                    labelPictoLigne.layer.borderColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]?.cgColor
                } else {
                    cell.backgroundColor = .white
                    cell.textLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.darken(percentage: 0.2)
                    cell.detailTextLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.darken(percentage: 0.2)
                    labelPictoLigne.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.darken(percentage: 0.2)
                    labelPictoLigne.layer.borderColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]?.darken(percentage: 0.2)?.cgColor
                }

            }

            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image
            return cell
        }

    }

}
