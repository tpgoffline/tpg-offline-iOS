
//
//  ArretsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 16/11/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import SwiftyJSON
import ChameleonFramework
import FontAwesomeKit
import PermissionScope
import DGElasticPullToRefresh
import INTULocationManager
import Localize_Swift
import Onboard

class ArretsTableViewController: UITableViewController, UISplitViewControllerDelegate {
    var arretsLocalisation = [Arret]()
    var filtredResults = [Arret]()
    let searchController = UISearchController(searchResultsController: nil)
    let tpgUrl = tpgURL()
    let defaults = NSUserDefaults.standardUserDefaults()
    var arretsKeys: [String] = []
    let pscope = PermissionScope()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .AllVisible
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = AppValues.textColor
        
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            self!.requestLocation()
            self?.tableView.dg_stopLoading()
            
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        // Result Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Rechercher parmi les arrêts".localized()
        
        arretsKeys = [String](AppValues.arrets.keys)
        arretsKeys.sortInPlace({ (string1, string2) -> Bool in
            let stringA = String((AppValues.arrets[string1]?.titre)! + (AppValues.arrets[string1]?.sousTitre)!)
            let stringB = String((AppValues.arrets[string2]?.titre)! + (AppValues.arrets[string2]?.sousTitre)!)
            if stringA.lowercaseString < stringB.lowercaseString {
                return true
            }
            return false
        })
        
        actualiserTheme()
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        tableView.tableHeaderView = self.searchController.searchBar
        
        if #available(iOS 9.0, *) {
            if(traitCollection.forceTouchCapability == .Available){
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
        
        if !(NSProcessInfo.processInfo().arguments.contains("-donotask")) {
            
            switch PermissionScope().statusNotifications() {
            case .Unknown:
                // ask
                pscope.addPermission(NotificationsPermission(notificationCategories: nil), message: "Cette autorisation sert à envoyer des rappels.".localized())
            case .Unauthorized, .Disabled:
                // bummer
                return
            case .Authorized:
                // thanks!
                return
            }
            switch PermissionScope().statusLocationAlways() {
            case .Unknown:
                // ask
                pscope.addPermission(LocationAlwaysPermission(), message: "Cette autorisation sert à indiquer les arrets les plus proches.".localized())
            case .Unauthorized, .Disabled:
                // bummer
                return
            case .Authorized:
                requestLocation()
                return
            }
            
            pscope.headerLabel.text = "Bonjour".localized()
            pscope.bodyLabel.text = "Nous avons besoin de quelques autorisations".localized()
            pscope.closeButton.setTitle("X", forState: .Normal)
            pscope.show({ finished, results in
                print("got results \(results)")
                for x in results {
                    if x.type == PermissionType.LocationInUse {
                        self.requestLocation()
                    }
                }
                }, cancelled: { (results) -> Void in
                    print("thing was cancelled")
            })
            
        }
    }
    
    func requestLocation() {
        var accurency = INTULocationAccuracy.Block
        if self.defaults.integerForKey("locationAccurency") == 1 {
            accurency = INTULocationAccuracy.House
        }
        else if self.defaults.integerForKey("locationAccurency") == 2 {
            accurency = INTULocationAccuracy.Room
        }
        
        let localisationManager = INTULocationManager.sharedInstance()
        localisationManager.requestLocationWithDesiredAccuracy(accurency, timeout: 60, delayUntilAuthorized: true) { (location, accurency, status) in
            if status == .Success {
                self.arretsLocalisation = []
                print("Résultat de la localisation")
                
                if self.defaults.integerForKey("proximityDistance") == 0 {
                    self.defaults.setInteger(500, forKey: "proximityDistance")
                }
                
                for x in [Arret](AppValues.arrets.values) {
                    x.distance = location.distanceFromLocation(x.location)
                    
                    if (location.distanceFromLocation(x.location) <= Double(self.defaults.integerForKey("proximityDistance"))) {
                        
                        self.arretsLocalisation.append(x)
                        print(x.stopCode)
                        print(String(location.distanceFromLocation(x.location)))
                    }
                }
                self.arretsLocalisation.sortInPlace({ (arret1, arret2) -> Bool in
                    if arret1.distance < arret2.distance {
                        return true
                    }
                    else {
                        return false
                    }
                })
                self.tableView.reloadData()
            }
            else {
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        actualiserTheme()
        searchController.searchBar.barTintColor = AppValues.primaryColor
        searchController.searchBar.tintColor = AppValues.textColor
        
        tableView.dg_setPullToRefreshFillColor(AppValues.secondaryColor)
        tableView.dg_setPullToRefreshBackgroundColor(AppValues.primaryColor)
        
        if !(NSProcessInfo.processInfo().arguments.contains("-donotask")) {
            switch PermissionScope().statusLocationAlways() {
            case .Unauthorized, .Disabled, .Unknown:
                // bummer
                return
            case .Authorized:
                requestLocation()
                return
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func afficherTutoriel() {
        let rect = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, AppValues.primaryColor.CGColor)
        
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let page1 = OnboardingContentViewController (title: "Bienvenue dans tpg offline".localized(), body: "tpg offline est une application qui facilite vos déplacements avec les transports publics genevois, même sans réseau.".localized(), image: nil, buttonText: "Continuer".localized(), actionBlock: nil)
        
        let iconeI = FAKIonIcons.iosClockIconWithSize(50)
        iconeI.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page2 = OnboardingContentViewController (title: "Départs".localized(), body: "Le menu Départs vous informe des prochains départs pour un arrêt.".localized(), image: iconeI.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        var iconeF = FAKFontAwesome.globeIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page3 = OnboardingContentViewController (title: "Mode offline".localized(), body: "Le Mode offline vous permet de connaitre les horaires à un arrêt même si vous n’avez pas de réseau.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.warningIconWithSize(50)
        
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page4 = OnboardingContentViewController (title: "Avertissement".localized(), body: "Sans réseau, tpg offline ne permet pas d’avoir des horaires garantis ni de connaitre les possibles perturbations du réseau. \rtpg offline ne peut aucunement être tenu pour responsable en cas de retard, d’avance, ni de connection manquée.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "J'ai compris, continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.mapSignsIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page5 = OnboardingContentViewController (title: "Itinéraires".localized(), body: "l’application propose un menu Itinéraires. Vous pouvez vous déplacer très facilement grâce à cette fonction.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.mapIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page6 = OnboardingContentViewController (title: "Plans".localized(), body: "Tous les plans des tpg sont disponibles dans le menu Plans.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.warningIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page7 = OnboardingContentViewController (title: "Incidents".localized(), body: "Soyez avertis en cas de perturbations sur le réseau tpg grâce au menu Incidents.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.bellOIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page8 = OnboardingContentViewController (title: "Rappels".localized(), body: "Dans les menus Départs et Itinéraires, faite glisser un des horaires proposés vers la gauche pour être notifié(e) d’un départ et éviter de rater votre transport ou votre connection.".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.githubIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page9 = OnboardingContentViewController (title: "Open Source", body: "tpg offline est Open Source. Vous pouvez donc modifier et améliorer l’application si vous le souhaitez.\rSi vous avez des idées ou que vous trouvez un bug, n'hésitez pas à consulter notre projet sur GitHub. (https://github.com/RemyDCF/tpg-offline)".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.ellipsisHIconWithSize(50)
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page10 = OnboardingContentViewController (title: "Et beaucoup d'autres choses".localized(), body: "D'autres surprises vous attendent dans l'application. Alors, partez à l'aventure et bon voyage !".localized(), image: iconeF.imageWithSize(CGSize(width: 50, height: 50)), buttonText: "Terminer".localized(), actionBlock: { (onboardingvc) in
            self.defaults.setBool(true, forKey: "tutorial")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        page1.movesToNextViewController = true
        page2.movesToNextViewController = true
        page3.movesToNextViewController = true
        page4.movesToNextViewController = true
        page5.movesToNextViewController = true
        page6.movesToNextViewController = true
        page7.movesToNextViewController = true
        page8.movesToNextViewController = true
        page9.movesToNextViewController = true
        
        let onboardingVC = OnboardingViewController(backgroundImage: image, contents: [page1, page2, page3, page4, page5, page6, page7, page8, page9, page10])
        onboardingVC.titleTextColor = AppValues.textColor
        onboardingVC.bodyTextColor = AppValues.textColor
        onboardingVC.buttonTextColor = AppValues.textColor
        onboardingVC.pageControl.pageIndicatorTintColor = AppValues.secondaryColor
        onboardingVC.pageControl.currentPageIndicatorTintColor = AppValues.textColor
        onboardingVC.skipButton.setTitleColor(AppValues.textColor, forState: .Normal)
        onboardingVC.bodyFontSize = 18
        onboardingVC.shouldMaskBackground = false
        onboardingVC.shouldFadeTransitions = true
        onboardingVC.allowSkipping = true
        onboardingVC.skipButton.setTitle("Passer".localized(), forState: .Normal)
        onboardingVC.skipHandler = {
            self.defaults.setBool(true, forKey: "tutorial")
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(onboardingVC, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if searchController.active {
            return 1
        }
        else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            return self.filtredResults.count
        }
        else {
            if section == 0 {
                return arretsLocalisation.count
            }
            else if section == 1 {
                if (AppValues.arretsFavoris == nil) {
                    return 0
                }
                else {
                    return AppValues.arretsFavoris.count
                }
            }
            else {
                return AppValues.arrets.count
            }
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !searchController.active {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            if indexPath.section == 0 {
                let iconLocation = FAKFontAwesome.locationArrowIconWithSize(20)
                iconLocation.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconLocation.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = arretsLocalisation[indexPath.row].nomComplet
                cell.detailTextLabel!.text = "~" + String(Int(arretsLocalisation[indexPath.row].distance!)) + "m"
            }
            else if indexPath.section == 1 {
                let iconFavoris = FAKFontAwesome.starIconWithSize(20)
                iconFavoris.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconFavoris.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.titre
                cell.detailTextLabel?.text = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]?.sousTitre
            }
            else {
                let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
                iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
                cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
                cell.textLabel?.text = AppValues.arrets[arretsKeys[indexPath.row]]!.titre
                cell.detailTextLabel!.text = AppValues.arrets[arretsKeys[indexPath.row]]!.sousTitre
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = backgroundView
            cell.backgroundColor = AppValues.primaryColor
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel?.textColor = AppValues.textColor
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("arretsCell", forIndexPath: indexPath)
            let iconCheveron = FAKFontAwesome.chevronRightIconWithSize(15)
            iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = AppValues.secondaryColor
            cell.selectedBackgroundView = backgroundView
            cell.textLabel?.text = filtredResults[indexPath.row].titre
            cell.textLabel?.textColor = AppValues.textColor
            cell.detailTextLabel!.text = filtredResults[indexPath.row].sousTitre
            cell.accessoryView = UIImageView(image: iconCheveron.imageWithSize(CGSize(width: 20, height: 20)))
            cell.backgroundColor = AppValues.primaryColor
            
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "afficherProchainsDeparts") {
            let nav = segue.destinationViewController as! UINavigationController
            let departsArretsViewController = nav.viewControllers[0] as! DepartsArretTableViewController
            if searchController.active {
                departsArretsViewController.arret = filtredResults[(tableView.indexPathForSelectedRow?.row)!]
            }
            else {
                if tableView.indexPathForSelectedRow!.section == 0 {
                    departsArretsViewController.arret = arretsLocalisation[tableView.indexPathForSelectedRow!.row]
                }
                else if tableView.indexPathForSelectedRow!.section == 1 {
                    departsArretsViewController.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[tableView.indexPathForSelectedRow!.row]]
                }
                else {
                    departsArretsViewController.arret = AppValues.arrets[self.arretsKeys[(tableView.indexPathForSelectedRow?.row)!]]
                }
            }
        }
    }
    
    deinit {
        tableView.dg_removePullToRefresh()
    }
    
    func filterContentForSearchText(searchText: String) {
        filtredResults = [Arret](AppValues.arrets.values).filter { arret in
            return arret.nomComplet.lowercaseString.containsString(searchText.lowercaseString)
        }
        filtredResults.sortInPlace { (arret1, arret2) -> Bool in
            let stringA = String(arret1.titre + arret1.sousTitre)
            let stringB = String(arret2.titre + arret2.sousTitre)
            if stringA.lowercaseString < stringB.lowercaseString {
                return true
            }
            return false
        }
        
        tableView.reloadData()
    }
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension ArretsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension ArretsTableViewController : UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else { return nil }
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
        
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("departsArretTableViewController") as? DepartsArretTableViewController else { return nil }
        
        if searchController.active {
            detailVC.arret = filtredResults[indexPath.row]
        }
        else {
            if indexPath.section == 0 {
                detailVC.arret = arretsLocalisation[indexPath.row]
            }
            else if indexPath.section == 1 {
                detailVC.arret = AppValues.arretsFavoris[AppValues.nomCompletsFavoris[indexPath.row]]
            }
            else {
                detailVC.arret = AppValues.arrets[self.arretsKeys[indexPath.row]]
            }
        }
        if #available(iOS 9.0, *) {
            previewingContext.sourceRect = cell.frame
        }
        return detailVC
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        showViewController(viewControllerToCommit, sender: self)
        
    }
}