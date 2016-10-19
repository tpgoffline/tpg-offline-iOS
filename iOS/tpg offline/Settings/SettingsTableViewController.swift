//
//  SettingsTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 20/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import SwiftyJSON
import Chameleon
import Onboard
import Alamofire
import SCLAlertView
import SafariServices
import VHUD
import FontAwesomeKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    var rowsList = [
        [FAKFontAwesome.barsIcon(withSize: 20)!, "Choix du menu par défaut".localized(), "showChoixDuMenuParDefault"],
        [FAKFontAwesome.locationArrowIcon(withSize: 20)!, "Localisation".localized(), "showLocationMenu"],
        [FAKFontAwesome.infoCircleIcon(withSize: 20)!, "Crédits".localized(), "showCredits"],
        [FAKFontAwesome.commentIcon(withSize: 20)!, "Donnez votre avis !".localized(), "sendEmail"],
        [FAKFontAwesome.githubIcon(withSize: 20)!, "Page GitHub du projet".localized(), "showGitHub"],
        [FAKFontAwesome.graduationCapIcon(withSize: 20)!, "Revoir le tutoriel".localized(), "showTutoriel"],
        [FAKFontAwesome.paintBrushIcon(withSize: 20)!, "Thèmes".localized(), "showThemesMenu"],
        [FAKFontAwesome.refreshIcon(withSize: 20)!, "Actualiser les départs (Offline)".localized(), "actualiserDeparts"]
    ]
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTheme()
        
        if !defaults.bool(forKey: "tutorial") && !(ProcessInfo.processInfo.arguments.contains("-donotask")) {
            afficherTutoriel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTheme()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "parametresCell", for: indexPath)
        
        cell.textLabel!.text = (rowsList[indexPath.row][1] as! String)
        let iconCheveron = FAKFontAwesome.chevronRightIcon(withSize: 15)!
        iconCheveron.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        cell.accessoryView = UIImageView(image: iconCheveron.image(with: CGSize(width: 20, height: 20)))
        let icone = rowsList[indexPath.row][0] as! FAKFontAwesome
        icone.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        cell.imageView?.image = icone.image(with: CGSize(width: 20, height: 20))
        cell.backgroundColor = AppValues.primaryColor
        cell.textLabel?.textColor = AppValues.textColor
        
        let view = UIView()
        view.backgroundColor = AppValues.primaryColor
        cell.selectedBackgroundView = view
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rowsList[indexPath.row][2] as! String == "showTutoriel" {
            afficherTutoriel()
        }
        else if rowsList[indexPath.row][2] as! String == "actualiserDeparts" {
            actualiserDeparts()
        }
        else if rowsList[indexPath.row][2] as! String == "sendEmail" {
            sendEmail()
        }
        else if rowsList[indexPath.row][2] as! String == "showGitHub" {
            let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/RemyDCF/tpg-offline")!, entersReaderIfAvailable: true)
            if ContrastColorOf(AppValues.primaryColor, returnFlat: true) == FlatWhite() {
                safariViewController.view.tintColor = AppValues.primaryColor
            }
            else {
                safariViewController.view.tintColor = AppValues.textColor
            }
            present(safariViewController, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: rowsList[indexPath.row][2] as! String, sender: self)
        }
    }
    
    func sendEmail() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["support@dacostafaro.com"])
        mailComposerVC.setSubject("tpg offline")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            SCLAlertView().showError("Vous ne pouvez pas envoyer d'emails".localized(), subTitle: "Nous sommes désolés, mais vous ne pouvez pas envoyer d'emails. Vérifiez que un compte email est configuré dans les réglages".localized(), closeButtonTitle: "OK", duration: 30)
        }
    }
    
    func actualiserDeparts() {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        let alerte = SCLAlertView()
        alerte.addButton("OK, démarrer") {
            var content = VHUDContent(.loop(3.0))
            content.shape = .circle
            content.style = .light
            content.mode = .percentComplete
            content.background = .color(#colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 0.7))
            content.completionText = "100%"
            VHUD.show(content)
            VHUD.updateProgress(0.0)
            
            Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/Departs/listeDeparts.json", method: .get).validate().responseJSON { response in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        var _compteur = 0
                        var compteur: Int {
                            get {
                                return _compteur
                            }
                            set(value) {
                                _compteur = value
                                AppValues.logger.error("Error")
                            }
                        }
                        var ok = 0
                        let json = JSON(value)
                        for (_, subJson) in json {
                            let url = "https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/iOS/Departs/\(subJson.stringValue)"
                            
                            Alamofire.request(url).responseString { response in
                                switch response.result {
                                case .failure(_):
                                    Alamofire.request(url).responseString { response in
                                        switch response.result {
                                        case .failure(_):
                                            Alamofire.request(url).responseString { response in
                                                switch response.result {
                                                case .failure(_):
                                                    Alamofire.request(url).responseString { response in
                                                        switch response.result {
                                                        case .failure(_):
                                                            Alamofire.request(url).responseString { response in
                                                                switch response.result {
                                                                case .failure(_):
                                                                    compteur += 1
                                                                case .success:
                                                                    if self.writeDataToFile(response.result.value!, fileName: subJson.stringValue) == nil {
                                                                        ok += 1
                                                                    }
                                                                    else {
                                                                        compteur += 1
                                                                    }
                                                                    break
                                                                }
                                                            }
                                                        case .success:
                                                            if self.writeDataToFile(response.result.value!, fileName: subJson.stringValue) == nil {
                                                                ok += 1
                                                            }
                                                            else {
                                                                compteur += 1
                                                            }
                                                            break
                                                        }
                                                        var progress = Float(Int(ok + compteur) * 100)
                                                        progress /= Float(json.count)
                                                        progress /= Float(100)
                                                        VHUD.updateProgress(CGFloat(progress))
                                                        
                                                        if compteur + ok == json.count {
                                                            VHUD.dismiss(1.0, 1.0, "100 %", { (Void) in
                                                                let alerte2 = SCLAlertView()
                                                                if compteur != 0 {
                                                                    alerte2.showWarning("Opération terminée", subTitle: "L'opération est terminée. Toutrefois, nous n'avons pas pu télécharger les départs pour \(compteur) arrêts.", closeButtonTitle: "Fermer")
                                                                }
                                                                else {
                                                                    alerte2.showSuccess("Opération terminée", subTitle: "L'opération s'est terminée avec succès.", closeButtonTitle: "Fermer")
                                                                }
                                                            })
                                                        }
                                                    }
                                                case .success:
                                                    if self.writeDataToFile(response.result.value!, fileName: subJson.stringValue) == nil {
                                                        ok += 1
                                                    }
                                                    else {
                                                        compteur += 1
                                                    }
                                                    var progress = Float(Int(ok + compteur) * 100)
                                                    progress /= Float(json.count)
                                                    progress /= Float(100)
                                                    VHUD.updateProgress(CGFloat(progress))
                                                    
                                                    if compteur + ok == json.count {
                                                        VHUD.dismiss(1.0, 1.0, "100 %", { (Void) in
                                                            let alerte2 = SCLAlertView()
                                                            if compteur != 0 {
                                                                alerte2.showWarning("Opération terminée", subTitle: "L'opération est terminée. Toutrefois, nous n'avons pas pu télécharger les départs pour \(compteur) arrêts.", closeButtonTitle: "Fermer")
                                                            }
                                                            else {
                                                                alerte2.showSuccess("Opération terminée", subTitle: "L'opération s'est terminée avec succès.", closeButtonTitle: "Fermer")
                                                            }
                                                        })
                                                    }
                                                    break
                                                }
                                            }
                                        case .success:
                                            if self.writeDataToFile(response.result.value!, fileName: subJson.stringValue) == nil {
                                                ok += 1
                                            }
                                            else {
                                                compteur += 1
                                            }
                                            var progress = Float(Int(ok + compteur) * 100)
                                            progress /= Float(json.count)
                                            progress /= Float(100)
                                            VHUD.updateProgress(CGFloat(progress))
                                            
                                            if compteur + ok == json.count {
                                                VHUD.dismiss(1.0, 1.0, "100 %", { (Void) in
                                                    let alerte2 = SCLAlertView()
                                                    if compteur != 0 {
                                                        alerte2.showWarning("Opération terminée", subTitle: "L'opération est terminée. Toutrefois, nous n'avons pas pu télécharger les départs pour \(compteur) arrêts.", closeButtonTitle: "Fermer")
                                                    }
                                                    else {
                                                        alerte2.showSuccess("Opération terminée", subTitle: "L'opération s'est terminée avec succès.", closeButtonTitle: "Fermer")
                                                    }
                                                })
                                            }
                                            break
                                        }
                                    }
                                case .success:
                                    if self.writeDataToFile(response.result.value!, fileName: subJson.stringValue) == nil {
                                        ok += 1
                                    }
                                    else {
                                        compteur += 1
                                    }
                                    var progress = Float(Int(ok + compteur) * 100)
                                    progress /= Float(json.count)
                                    progress /= Float(100)
                                    VHUD.updateProgress(CGFloat(progress))
                                    
                                    if compteur + ok == json.count {
                                        VHUD.dismiss(1.0, 1.0, "100 %", { (Void) in
                                            let alerte2 = SCLAlertView()
                                            if compteur != 0 {
                                                alerte2.showWarning("Opération terminée", subTitle: "L'opération est terminée. Toutrefois, nous n'avons pas pu télécharger les départs pour \(compteur) arrêts.", closeButtonTitle: "Fermer")
                                            }
                                            else {
                                                alerte2.showSuccess("Opération terminée", subTitle: "L'opération s'est terminée avec succès.", closeButtonTitle: "Fermer")
                                            }
                                        })
                                    }
                                    break
                                }
                            }
                        }
                    }
                case .failure( _):
                    VHUD.dismiss(1.0, 1.0, "Erreur", { (Void) in
                        let alerte = SCLAlertView()
                        alerte.showError("Pas de réseau", subTitle: "Vous n'êtes pas connecté au réseau. Pour actualiser les départs, merci de vous connecter au réseau.", closeButtonTitle: "Fermer", duration: 10)
                    })
                }
            }
        }
        alerte.showInfo("Actualisation", subTitle: "Vous allez actualiser les départs. Attention : Nous vous recommandons d'utiliser le wifi pour éviter d'utiliser votre forfait data (50 Mo). Cette opération peut prendre plusieurs minutes et n'est pas annulable. Veuillez également laisser l'application au premier plan pour ne pas interrompre le téléchargement.", closeButtonTitle: "Annuler")
    }
    
    func writeDataToFile(_ data: String, fileName: String) -> Error? {
        var fileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)[0])
        fileURL.appendPathComponent(fileName)
        
        do {
            try data.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch (let error) {
            AppValues.logger.error(error)
            return error
        }
        
        return nil
    }
    
    func afficherTutoriel() {
        let rect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(AppValues.primaryColor.cgColor)
        
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let page1 = OnboardingContentViewController (title: "Bienvenue dans tpg offline".localized(), body: "tpg offline est une application qui facilite vos déplacements avec les transports publics genevois, même sans réseau.".localized(), image: nil, buttonText: "Continuer".localized(), actionBlock: nil)
        
        let iconeI = FAKIonIcons.iosClockIcon(withSize: 50)!
        iconeI.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page2 = OnboardingContentViewController (title: "Départs".localized(), body: "Le menu Départs vous informe des prochains départs pour un arrêt.".localized(), image: iconeI.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        var iconeF = FAKFontAwesome.globeIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page3 = OnboardingContentViewController (title: "Mode offline".localized(), body: "Le Mode offline vous permet de connaitre les horaires à un arrêt même si vous n’avez pas de réseau.".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.warningIcon(withSize: 50)!
        
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page4 = OnboardingContentViewController (title: "Avertissement".localized(), body: "Sans réseau, tpg offline ne permet pas d’avoir des horaires garantis ni de connaitre les possibles perturbations du réseau. \rtpg offline ne peut aucunement être tenu pour responsable en cas de retard, d’avance, ni de connection manquée.".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "J'ai compris, continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.mapSignsIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page5 = OnboardingContentViewController (title: "Itinéraires".localized(), body: "l’application propose un menu Itinéraires. Vous pouvez vous déplacer très facilement grâce à cette fonction.".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.mapIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page6 = OnboardingContentViewController (title: "Plans".localized(), body: "Tous les plans des tpg sont disponibles dans le menu Plans.".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.warningIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page7 = OnboardingContentViewController (title: "Incidents".localized(), body: "Soyez avertis en cas de perturbations sur le réseau tpg grâce au menu Incidents.".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.bellOIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page8 = OnboardingContentViewController (title: "Rappels".localized(), body: "Dans les menus Départs et Itinéraires, faite glisser un des horaires proposés vers la gauche pour être notifié(e) d’un départ et éviter de rater votre transport ou votre connection.".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.githubIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page9 = OnboardingContentViewController (title: "Open Source", body: "tpg offline est Open Source. Vous pouvez donc modifier et améliorer l’application si vous le souhaitez.\rSi vous avez des idées ou que vous trouvez un bug, n'hésitez pas à consulter notre projet sur GitHub. (https://github.com/RemyDCF/tpg-offline)".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Continuer".localized(), actionBlock: nil)
        iconeF = FAKFontAwesome.ellipsisHIcon(withSize: 50)!
        iconeF.addAttribute(NSForegroundColorAttributeName, value: AppValues.textColor)
        let page10 = OnboardingContentViewController (title: "Et beaucoup d'autres choses".localized(), body: "D'autres surprises vous attendent dans l'application. Alors, partez à l'aventure et bon voyage !".localized(), image: iconeF.image(with: CGSize(width: 50, height: 50)), buttonText: "Terminer".localized(), actionBlock: { (onboardingvc) in
            self.dismiss(animated: true, completion: nil)
            if !self.defaults.bool(forKey: "tutorial") {
                self.defaults.set(true, forKey: "tutorial")
                self.defaults.set(true, forKey: "version4")
                self.tabBarController?.selectedIndex = 0
            }
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
        
        let pages = [page1, page2, page3, page4, page5, page6, page7, page8, page9, page10]
        for x in pages {
            x.titleLabel.textColor = AppValues.textColor
            
            x.bodyLabel.textColor = AppValues.textColor
            x.bodyLabel.font = x.bodyLabel.font.withSize(18)
            
            x.actionButton.setTitleColor(AppValues.textColor, for: .normal)
        }
        
        let onboardingVC = OnboardingViewController(backgroundImage: image, contents: pages)
        onboardingVC?.pageControl.pageIndicatorTintColor = AppValues.primaryColor.darken(byPercentage: 0.1)
        onboardingVC?.pageControl.currentPageIndicatorTintColor = AppValues.textColor
        onboardingVC?.skipButton.setTitleColor(AppValues.textColor, for: .normal)
        onboardingVC?.shouldMaskBackground = false
        onboardingVC?.shouldFadeTransitions = true
        onboardingVC?.allowSkipping = true
        onboardingVC?.skipButton.setTitle("Passer".localized(), for: .normal)
        onboardingVC?.skipHandler = {
            self.dismiss(animated: true, completion: nil)
            if !self.defaults.bool(forKey: "tutorial") {
                self.defaults.set(true, forKey: "tutorial")
                self.defaults.set(true, forKey: "version4")
                self.tabBarController?.selectedIndex = 0
            }
        }
        present(onboardingVC!, animated: true, completion: nil)
    }
}

extension SettingsTableViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
