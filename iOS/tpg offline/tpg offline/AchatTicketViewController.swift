//
//  AchatTicketViewController.swift
//  tpg offline
//
//  Created by Alice on 21/12/2015.
//  Copyright © 2015 dacostafaro. All rights reserved.
//

import UIKit
import ChameleonFramework
import FontAwesomeKit
import MessageUI
import SCLAlertView

class AchatTicketViewController: UIViewController {
    var ticket: Ticket!
    @IBOutlet weak var iconeTicket: UILabel!
    @IBOutlet weak var titreLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var boutonAcheter: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageTicket = FAKFontAwesome.ticketIconWithSize(iconeTicket.bounds.height)
        imageTicket.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        iconeTicket.attributedText = imageTicket.attributedString()
        titreLabel.text = ticket.nom
        descriptionLabel.text = ticket.description
        boutonAcheter.setTitle("Acheter ce ticket (\(ticket.prix))", forState: .Normal)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ouvrirConditions(sender: AnyObject!) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.tpg.ch/billets-sms")!)
    }
    @IBAction func envoyerSMS(sender: AnyObject!) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ticket.code
            controller.recipients = ["788"]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

extension AchatTicketViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        let alert = SCLAlertView()
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue:
            alert.showWarning("Envoi annulé", subTitle: "L'envoi du SMS a été annulé.", closeButtonTitle: "OK", duration: 10)
        case MessageComposeResultFailed.rawValue:
            alert.showError("Echec de l'envoi", subTitle: "L'envoi du SMS à rencontré un problème.", closeButtonTitle: "OK", duration: 10)
        case MessageComposeResultSent.rawValue:
            if ticket.heure == true {
                alert.addButton("Ajouter un rappel dans 1h", action: { () -> Void in
                    let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: NSDate())
                    
                    let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                    let date = cal.dateBySettingHour(now.hour + 1, minute: now.minute, second: now.second, ofDate: NSDate(), options: NSCalendarOptions())
                    let reminder = UILocalNotification()
                    reminder.fireDate = date
                    reminder.alertBody = "Le billet SMS a expiré"
                    reminder.soundName = "Sound.aif"
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(reminder)
                    
                    print("Firing at \(now.hour+1):\(now.minute):\(now.second)")
                    
                    alert.hideView()
                    let okView = SCLAlertView()
                    okView.showSuccess("Vous serez notifié", subTitle: "La notification à été enregistrée et sera affichée à l'heure de l'expiration du billet.", closeButtonTitle: "OK", duration: 10)
                    
                })
            }
            alert.showSuccess("Envoi Réussi", subTitle: "La demande de billet à été envoyée. Votre billet sera valable lors de la reception d'un SMS du 788", closeButtonTitle: "OK", duration: 10)
        default:
            print("")
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}