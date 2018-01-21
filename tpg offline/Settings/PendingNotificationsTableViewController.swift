//
//  PendingNotificationsTableViewController.swift
//  tpg offline
//
//  Created by Rémy DA COSTA FARO on 16/01/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import UserNotifications

class PendingNotificationsTableViewController: UITableViewController {

    var pendingNotifications: [[String]] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notifications".localized

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
    }

    deinit {
        ColorModeManager.shared.removeColorModeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

        cell.textLabel?.attributedText = NSAttributedString(string: pendingNotifications[indexPath.row][0], attributes: titleAttributes)
        cell.detailTextLabel?.attributedText = NSAttributedString(string: pendingNotifications[indexPath.row][1], attributes: subtitleAttributes)

        cell.backgroundColor = App.cellBackgroundColor
        let view = UIView()
        view.backgroundColor = App.cellBackgroundColor.darken(by: 0.1)
        cell.selectedBackgroundView = view

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
