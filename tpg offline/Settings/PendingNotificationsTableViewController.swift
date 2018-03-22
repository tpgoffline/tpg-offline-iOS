//
//  PendingNotificationsTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 16/01/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import UserNotifications
import Crashlytics
import Alamofire

class PendingNotificationsTableViewController: UITableViewController {

    var requestStatus: RequestStatus = .loading {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var pendingNotifications: [[String]] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var smartNotifications: [SmartNotificationStatus] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications".localized

        App.log("Show pending notifications")
        Answers.logCustomEvent(withName: "Show pending notifications")

        if App.darkMode {
            self.tableView.backgroundColor = .black
            self.navigationController?.navigationBar.barStyle = .black
            self.tableView.separatorColor = App.separatorColor
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        ColorModeManager.shared.addColorModeDelegate(self)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        pendingNotifications = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                for request in requests {
                    if let trigger = (request.trigger as? UNCalendarNotificationTrigger) {
                        self.pendingNotifications.append(["\(dateFormatter.string(from: Calendar.current.date(from: trigger.dateComponents) ?? Date())) - \(request.content.title)", request.content.body, request.identifier])
                        print(request.identifier)
                    }
                }
            }
        } else {
            for notification in (UIApplication.shared.scheduledLocalNotifications ?? []) {
                pendingNotifications.append([dateFormatter.string(from: notification.fireDate ?? Date()), notification.alertBody ?? "Unknow content".localized, notification.identifier ?? ""])
            }
        }

        self.requestStatus = .loading
        Alamofire.request("https://tpgoffline-apns.alwaysdata.net/reminders/status/\(App.apnsToken)")
            .responseData { (response) in
                if let data = response.result.value {
                    let jsonDecoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                    let json = try? jsonDecoder.decode([SmartNotificationStatus].self, from: data)

                    self.smartNotifications = json ?? []
                    self.requestStatus = .ok
                } else {
                    print(response.error)
                    self.requestStatus = .error
                }
        }
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if requestStatus == any(of: .error, .loading) { return 1 }
            return smartNotifications.count
        }
        return pendingNotifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pendingNotificationCell", for: indexPath)

        let titleAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline),
                               NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        let subtitleAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline),
                                  NSAttributedStringKey.foregroundColor: App.textColor] as [NSAttributedStringKey: Any]
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        if indexPath.section == 1 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            switch requestStatus {
            case .error:
                cell.textLabel?.attributedText = NSAttributedString(string: "Could not load Smart Notifications".localized, attributes: titleAttributes)
                cell.detailTextLabel?.attributedText = NSAttributedString(string: "Are you connected to internet?".localized, attributes: subtitleAttributes)
            case .loading:
                cell.textLabel?.attributedText = NSAttributedString(string: "Loading Smart Notifications".localized, attributes: titleAttributes)
                cell.detailTextLabel?.attributedText = NSAttributedString(string: "", attributes: subtitleAttributes)
            case .ok:
                cell.textLabel?.attributedText = NSAttributedString(string: "\(dateFormatter.string(from: smartNotifications[indexPath.row].estimatedTriggerTime)) - \(smartNotifications[indexPath.row].title)", attributes: titleAttributes)
                cell.detailTextLabel?.attributedText = NSAttributedString(string: smartNotifications[indexPath.row].text, attributes: subtitleAttributes)
            default:
                print("I may repeat myself, but how did you ended here?")
            }
        } else {
            cell.textLabel?.attributedText = NSAttributedString(string: pendingNotifications[indexPath.row][0], attributes: titleAttributes)
            cell.detailTextLabel?.attributedText = NSAttributedString(string: pendingNotifications[indexPath.row][1], attributes: subtitleAttributes)
        }
        cell.backgroundColor = App.cellBackgroundColor
        let view = UIView()
        view.backgroundColor = App.cellBackgroundColor.darken(by: 0.1)
        cell.selectedBackgroundView = view

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return !(requestStatus == any(of: .error, .loading))
        }
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 1 {
                let parameters: Parameters = [
                    "device": App.apnsToken,
                    "id": smartNotifications[indexPath.row].id
                ]
                Alamofire.request("https://tpgoffline-apns.alwaysdata.net/reminders/remove", method: .post, parameters: parameters).responseString(completionHandler: { (response) in
                    if let string = response.result.value, string == "1" {
                        self.smartNotifications.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                })
            } else {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [pendingNotifications[indexPath.row][2]])
                pendingNotifications.remove(at: indexPath.row)
            } else {
                guard let notification = UIApplication.shared.scheduledLocalNotifications?.filter({ $0.identifier == pendingNotifications[indexPath.row][2]})[safe: 0] else {
                    return
                }
                UIApplication.shared.cancelLocalNotification(notification)
                pendingNotifications.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Notifications".localized, "Smart Notifications".localized][section]
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

@available(iOS 10.0, *)
extension PendingNotificationsTableViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.tableView.reloadData()
    }
}