//
//  IncidentsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 17/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Chameleon
import FontAwesomeKit
import Alamofire
import FirebaseCrash

class IncidentsTableViewController: UITableViewController {
    let defaults = UserDefaults.standard
    var distrubtions: [Distrubtions] = []
    var error = false
    var noDistrubtions = false
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRCrashMessage("Incidents")
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            self!.refresh(loadingView)
            self?.tableView.dg_stopLoading()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1)!)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        navigationController?.navigationBar.barTintColor = UIColor.flatOrangeDark
        navigationController?.navigationBar.tintColor = UIColor.white
        
        var barButtonsItems: [UIBarButtonItem] = []
        
        barButtonsItems.append(UIBarButtonItem(image: FAKIonIcons.refreshIcon(withSize: 20)!.image(with: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(IncidentsTableViewController.refresh(_:))))
        
        self.navigationItem.rightBarButtonItems = barButtonsItems

        refresh(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.primaryColor.darken(byPercentage: 0.1)!)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        refreshTheme()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh(_ sender:AnyObject)
    {
        noDistrubtions = false
        error = false
        distrubtions = []
        loading = true
        tableView.reloadData()
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetDisruptions.json", method: .get, parameters: ["key": "d95be980-0830-11e5-a039-0002a5d5c51b"]).responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)
                    FIRCrashMessage("\(json.rawString())")
                    if json["disruptions"].count != 0 {
                        for x in 0...json["disruptions"].count - 1 {
                            if AppValues.linesColor[json["disruptions"][x]["lineCode"].string!] != nil {
                                self.distrubtions.append(Distrubtions(lineCode: json["disruptions"][x]["lineCode"].string!, title: json["disruptions"][x]["nature"].string!, subTitle: json["disruptions"][x]["consequence"].string!))
                            }
                        }
                    }
                    else {
                        self.noDistrubtions = true
                    }
                    self.loading = false
                    self.tableView.reloadData()
                }
                else {
                    #if DEBUG
                        if let error = response.result.error {
                            let alert = SCLAlertView()
                            alert.showError("Alamofire", subTitle: "DEBUG - \(error.localizedDescription)")
                        }
                    #endif
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
        }
        else if noDistrubtions == true {
            return 1
        }
        else if error == true {
            return 1
        }
        else {
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
        if loading == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! loadingCellTableViewCell
            
            cell.activityIndicator.stopAnimating()
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = UIColor.flatBlue
                cell.titleLabel?.textColor = UIColor.white
                cell.subTitleLabel?.textColor = UIColor.white
                cell.activityIndicator.color = UIColor.white
            }
            else {
                cell.backgroundColor = UIColor.white
                cell.titleLabel?.textColor = UIColor.flatBlue
                cell.subTitleLabel?.textColor = UIColor.flatBlue
                cell.activityIndicator.color = UIColor.flatBlue
            }
            cell.titleLabel?.text = "Chargement".localized
            cell.subTitleLabel?.text = "Merci de patienter".localized
            cell.accessoryView = nil
            
            cell.activityIndicator.startAnimating()

            return cell
        }
        else if noDistrubtions {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incidentsCell", for: indexPath)
            cell.textLabel?.text = "Aucun incident".localized
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH"
            let heure = Int(dateFormatter.string(from: Date()))
            if heure! < 6 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !".localized
            }
            else if heure! < 18 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne journée !".localized
            }
            else if heure! < 22 {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne soirée !".localized
            }
            else {
                cell.detailTextLabel!.text = "Tout va bien sur tout le réseau. Bonne nuit !".localized
            }
            
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.flatYellow
                
                let iconeSmile = FAKFontAwesome.smileOIcon(withSize: 20)!
                iconeSmile.addAttribute(NSForegroundColorAttributeName, value: UIColor.black)
                cell.imageView?.image = iconeSmile.image(with: CGSize(width: 25, height: 25))
            }
            else {
                cell.textLabel?.textColor = UIColor.flatYellowDark
                cell.detailTextLabel?.textColor = UIColor.flatYellowDark
                cell.backgroundColor = UIColor.flatWhite
                
                let iconeSmile = FAKFontAwesome.smileOIcon(withSize: 20)!
                iconeSmile.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatYellowDark)
                cell.imageView?.image = iconeSmile.image(with: CGSize(width: 25, height: 25))
            }
            return cell
        }
        else if error {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incidentsCell", for: indexPath)
            cell.textLabel?.text = "Pas de réseau !".localized
            
            cell.detailTextLabel!.text = "tpg offline n'est pas connecté au réseau. Il est impossible de charger les perturbations en cours sur le réseau tpg sans réseau.".localized
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
                cell.backgroundColor = UIColor.flatYellowDark
                
                let iconeError = FAKFontAwesome.timesCircleIcon(withSize: 20)!
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
                cell.imageView?.image = iconeError.image(with: CGSize(width: 25, height: 25))
            }
            else {
                cell.textLabel?.textColor = UIColor.flatYellowDark
                cell.detailTextLabel?.textColor = UIColor.flatYellowDark
                cell.backgroundColor = UIColor.flatWhite
                
                let iconeError = FAKFontAwesome.timesCircleIcon(withSize: 20)!
                iconeError.addAttribute(NSForegroundColorAttributeName, value: UIColor.flatYellowDark)
                cell.imageView?.image = iconeError.image(with: CGSize(width: 25, height: 25))
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "incidentsCell", for: indexPath)
            cell.textLabel?.text = distrubtions[indexPath.row].title
            cell.detailTextLabel!.text = distrubtions[indexPath.row].subTitle
            
            let labelPictoLigne = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 24))
            labelPictoLigne.text = distrubtions[indexPath.row].lineCode
            labelPictoLigne.textAlignment = .center
            
            labelPictoLigne.layer.cornerRadius = labelPictoLigne.layer.bounds.height / 2
            labelPictoLigne.layer.borderWidth = 1
            
            FIRCrashMessage(distrubtions[indexPath.row].describe())
            
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                cell.backgroundColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                cell.textLabel?.textColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]
                cell.detailTextLabel?.textColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]
                labelPictoLigne.textColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]
                labelPictoLigne.layer.borderColor = AppValues.linesColor[distrubtions[indexPath.row].lineCode]?.cgColor
            }
            else {
                if ContrastColorOf(AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!, returnFlat: true) == FlatWhite() {
                    cell.backgroundColor = UIColor.flatWhite
                    cell.textLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                    cell.detailTextLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                    labelPictoLigne.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]
                    labelPictoLigne.layer.borderColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]?.cgColor
                }
                else {
                    cell.backgroundColor = UIColor.flatWhite
                    cell.textLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.darken(byPercentage: 0.2)
                    cell.detailTextLabel?.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.darken(byPercentage: 0.2)
                    labelPictoLigne.textColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]!.darken(byPercentage: 0.2)
                    labelPictoLigne.layer.borderColor = AppValues.linesBackgroundColor[distrubtions[indexPath.row].lineCode]?.darken(byPercentage: 0.2)?.cgColor
                }
                
            }
            
            let image = labelToImage(labelPictoLigne)
            cell.imageView?.image = image
            return cell
        }
        
    }
    
    
}
