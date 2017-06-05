//
//  RoutesTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 14/01/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import UIKit
import FirebaseCrash
import DGRunkeeperSwitch
import SCLAlertView
import MapKit
import SwiftLocation

struct ActualRoutes {
    static var route: SearchRoute! = SearchRoute(departure: nil, arrival: nil, date: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: Date()), isArrivalDate: false)
    static var canFavorite: Bool! = false
    static var routeResult: [Route]! = []
}

class RoutesCollectionViewController: UICollectionViewController {

    let row = [
        ["itineraryCell", #imageLiteral(resourceName: "logOut"), "Départ".localized, "voirArretsItineraire"],
        ["itineraryCell", #imageLiteral(resourceName: "logIn"), "Arrivée".localized, "voirArretsItineraire"],
        ["itineraryCell", #imageLiteral(resourceName: "calendar"), "Date".localized, "selectDate"],
        ["itineraryCell", #imageLiteral(resourceName: "clock"), "Heure".localized, "selectHour"],
        ["switchCell", "Heure de départ".localized, "Heure d'arrivée".localized],
        ["buttonCell", "Rechercher".localized]]

    let headers = ["Recherche".localized, "Favoris".localized]
    let imagesHeaders = [#imageLiteral(resourceName: "search"), #imageLiteral(resourceName: "starNavbar")]

    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseCrashMessage("Routes")

        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        title = "Itinéraires".localized

        var barButtonsItems: [UIBarButtonItem] = []
        barButtonsItems.append(UIBarButtonItem(image: #imageLiteral(resourceName: "exchangeNavBar"), style: .done, target: self, action: #selector(echangerArrets)))
        navigationItem.leftBarButtonItems = barButtonsItems

        refreshTheme()
        getRoutesFromMaps()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ActualRoutes.canFavorite = true
        refreshTheme()
        getRoutesFromMaps()
    }

    func getRoutesFromMaps() {
        if let directionsRequest = BeforeStarting.directionsRequest {
            BeforeStarting.directionsRequest = nil

            if directionsRequest.source?.placemark.coordinate.latitude == 0.0 && directionsRequest.source?.placemark.coordinate.longitude == 0.0 {
                var accuracy = Accuracy.block
                if UserDefaults.standard.integer(forKey: "locationAccurency") == 1 {
                    accuracy = .house
                } else if UserDefaults.standard.integer(forKey: "locationAccurency") == 2 {
                    accuracy = .room
                }

                Location.getLocation(accuracy: accuracy, frequency: .oneShot, success: { (_, location) -> (Void) in
                    ActualRoutes.route.departure = self.getNearStopFrom(location)
                    ActualRoutes.route.arrival = self.getNearStopFrom(CLLocation(latitude: (directionsRequest.destination?.placemark.coordinate.latitude)!, longitude: (directionsRequest.destination?.placemark.coordinate.longitude)!))
                    ActualRoutes.route.date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: directionsRequest.departureDate ?? Date())
                    ActualRoutes.route.isArrivalDate = false
                    self.rechercher(sender: self)
                }) { (_, _, _) -> (Void) in
                    DispatchQueue.main.sync {
                        //TODO: Localize that
                        SCLAlertView().showError("Error".localized, subTitle: "We can't make a route, because we can't access to your location. Allow the app to access to your location in settings and retry", closeButtonTitle: "OK", duration: 60, feedbackType: .notificationError)
                    }
                }
            } else if directionsRequest.destination?.placemark.coordinate.latitude == 0.0 && directionsRequest.destination?.placemark.coordinate.longitude == 0.0 {
                var accuracy = Accuracy.block
                if UserDefaults.standard.integer(forKey: "locationAccurency") == 1 {
                    accuracy = .house
                } else if UserDefaults.standard.integer(forKey: "locationAccurency") == 2 {
                    accuracy = .room
                }

                Location.getLocation(accuracy: accuracy, frequency: .oneShot, success: { (_, location) -> (Void) in
                    ActualRoutes.route.departure = self.getNearStopFrom(CLLocation(latitude: (directionsRequest.source?.placemark.coordinate.latitude)!, longitude: (directionsRequest.source?.placemark.coordinate.longitude)!))
                    ActualRoutes.route.arrival = self.getNearStopFrom(location)
                    ActualRoutes.route.date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: directionsRequest.departureDate ?? Date())
                    ActualRoutes.route.isArrivalDate = false
                    self.rechercher(sender: self)
                }) { (_, _, _) -> (Void) in
                    DispatchQueue.main.sync {
                        //TODO: Localize that
                        SCLAlertView().showError("Error".localized, subTitle: "We can't make a route, because we can't access to your location. Allow the app to access to your location in settings and retry", closeButtonTitle: "OK", duration: 60, feedbackType: .notificationError)
                    }
                }
            } else {
                ActualRoutes.route.departure = getNearStopFrom(CLLocation(latitude: (directionsRequest.source?.placemark.coordinate.latitude)!, longitude: (directionsRequest.source?.placemark.coordinate.longitude)!))
                ActualRoutes.route.arrival = getNearStopFrom(CLLocation(latitude: (directionsRequest.destination?.placemark.coordinate.latitude)!, longitude: (directionsRequest.destination?.placemark.coordinate.longitude)!))
                ActualRoutes.route.date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: directionsRequest.departureDate ?? Date())
                ActualRoutes.route.isArrivalDate = false
                rechercher(sender: self)
            }
        }
    }

    func getNearStopFrom(_ location: CLLocation) -> Stop {
        var localizedStop: Stop = AppValues.stops[AppValues.stopsKeys[0]]!

        for x in [Stop](AppValues.stops.values) {
            x.distance = location.distance(from: x.location)

            if x.distance ?? 10000 <= localizedStop.distance ?? 10000 {
                localizedStop = x
            }
        }
        return localizedStop
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func echangerArrets() {
        let arretDepart = ActualRoutes.route.departure
        let arretArrivee = ActualRoutes.route.arrival
        ActualRoutes.route.departure = arretArrivee
        ActualRoutes.route.arrival = arretDepart
        collectionView!.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if AppValues.favoritesRoutes.count == 0 {
            return 1
        }
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return row.count
        } else {
            return AppValues.favoritesRoutes.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if (row[indexPath.row][0] as? String ?? "") == "itineraryCell" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itineraryCell", for: indexPath) as! ItineraryCellCollectionViewCell // swiftlint:disable:this force_cast

                cell.title?.text = (row[indexPath.row][2] as? String ?? "")

                guard let image = row[indexPath.row][1] as? UIImage else {
                    FirebaseCrashMessage("ERROR: row[indexPath.row][1] does not match with UIImage")
                    abort()
                }

                cell.imageView?.image = image.maskWithColor(color: AppValues.textColor)

                if (row[indexPath.row][2] as? String ?? "") == "Départ".localized {
                    cell.subTitle?.text = ActualRoutes.route.departure?.fullName != "" ? ActualRoutes.route.departure?.fullName : "-"
                } else if (row[indexPath.row][2] as? String ?? "") == "Arrivée".localized {
                    cell.subTitle?.text = ActualRoutes.route.arrival?.fullName != "" ? ActualRoutes.route.arrival?.fullName : "-"
                } else if (row[indexPath.row][2] as? String ?? "") == "Date".localized && ActualRoutes.route.date != nil {
                    cell.subTitle?.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
                } else if (row[indexPath.row][2] as? String ?? "") == "Heure".localized && ActualRoutes.route.date != nil {
                    cell.subTitle?.text = DateFormatter.localizedString(from: Calendar.current.date(from: ActualRoutes.route.date! as DateComponents)!, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
                } else {
                    cell.subTitle?.text = "-"
                }
                cell.title?.textColor = AppValues.textColor
                cell.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)
                cell.subTitle?.textColor = AppValues.textColor
                cell.subTitle?.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)
                cell.title?.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)

                let view = UIView()
                view.backgroundColor = AppValues.primaryColor
                cell.selectedBackgroundView = view

                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 10

                return cell
            } else if (row[indexPath.row][0] as? String ?? "") == "switchCell" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "switchCell", for: indexPath) as! SwitchCollectionViewCell // swiftlint:disable:this force_cast
                cell.switchObject.titles = [row[indexPath.row][1] as? String ?? "", row[indexPath.row][2] as? String ?? ""]
                if AppValues.primaryColor.contrast == .white {
                    cell.switchObject.backgroundColor = AppValues.primaryColor.lighten(percentage: 0.1)
                    cell.switchObject.selectedBackgroundColor = AppValues.primaryColor.darken(percentage: 0.1)
                } else {
                    cell.switchObject.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)
                    cell.switchObject.selectedBackgroundColor = AppValues.primaryColor.lighten(percentage: 0.1)
                }

                cell.switchObject.titleColor = AppValues.textColor
                cell.switchObject.selectedTitleColor = AppValues.textColor
                if ActualRoutes.route.isArrivalDate == true {
                    cell.switchObject.setSelectedIndex(1, animated: false)
                } else {
                    cell.switchObject.setSelectedIndex(0, animated: false)
                }
                cell.switchObject.autoresizingMask = [.flexibleWidth]
                cell.switchObject.addTarget(self, action:#selector(dateArriveeChange(_:)), for: .valueChanged)
                cell.backgroundColor = AppValues.primaryColor
                let view = UIView()
                view.backgroundColor = AppValues.primaryColor
                cell.selectedBackgroundView = view
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "buttonCell", for: indexPath) as! ButtonCollectionViewCell // swiftlint:disable:this force_cast
                cell.button.setTitle((row[indexPath.row][1] as? String ?? ""), for: .normal)
                cell.button.tintColor = AppValues.textColor
                cell.button.addTarget(self, action: #selector(self.rechercher(_:)), for: .touchUpInside)
                cell.backgroundColor = AppValues.primaryColor
                let view = UIView()
                view.backgroundColor = AppValues.primaryColor
                cell.selectedBackgroundView = view

                cell.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 25
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favorisCell", for: indexPath) as! FavoriteRouteCollectionViewCell // swiftlint:disable:this force_cast

            cell.departureLabel.text = AppValues.favoritesRoutes![indexPath.row][0].fullName
            cell.departureLabel.textColor = AppValues.textColor
            cell.departureLabel.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)

            cell.accessoryImage.backgroundColor = AppValues.primaryColor
            cell.accessoryImage.layer.cornerRadius = cell.accessoryImage.bounds.height / 2
            cell.accessoryImage.image = #imageLiteral(resourceName: "next").maskWithColor(color: AppValues.textColor).imageWithInset(UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 5))

            cell.arrivalLabel.text = AppValues.favoritesRoutes![indexPath.row][1].fullName
            cell.arrivalLabel.textColor = AppValues.textColor
            cell.arrivalLabel.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)

            cell.backgroundColor = AppValues.primaryColor.darken(percentage: 0.05)

            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 25

            return cell
        }
    }

    func rechercher(_ sender: Any) {
        if ActualRoutes.route.departure != nil && ActualRoutes.route.arrival != nil && ActualRoutes.route.date != nil {
            performSegue(withIdentifier: "rechercherItineraire", sender: self)
        } else {
            let alert = SCLAlertView()
            alert.showWarning("Information manquante".localized, subTitle: "Il manque une information pour rechercher un itinéraire".localized, closeButtonTitle: "OK".localized, duration: 10, feedbackType: .notificationWarning)
        }
    }

    func dateArriveeChange(_ sender: Any) {
        guard let switchArrivalDate = sender as? DGRunkeeperSwitch else {
            return
        }
        if switchArrivalDate.selectedIndex == 0 {
            ActualRoutes.route.isArrivalDate = false
        } else if switchArrivalDate.selectedIndex == 1 {
            ActualRoutes.route.isArrivalDate = true
        } else {
            print("The selected index of DGRunkeeperSwitch object is unknow")
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "routesHeader",
                                                                             for: indexPath) as! HeaderCollectionView // swiftlint:disable:this force_cast
            headerView.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)
            headerView.title.text = headers[indexPath.section]
            headerView.icon.image = imagesHeaders[indexPath.section].maskWithColor(color: AppValues.textColor)
            headerView.title.textColor = AppValues.textColor
            return headerView
        default:
            assert(false, "Unexpected element kind")
            abort()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "voirArretsItineraire" {
            let destinationViewController = segue.destination as! RoutesStopsTableViewController // swiftlint:disable:this force_cast

            if (collectionView?.cellForItem(at: (collectionView?.indexPathsForSelectedItems![0])!) as! ItineraryCellCollectionViewCell).title?.text == "Départ".localized { // swiftlint:disable:this force_cast
                destinationViewController.departure = true
            } else {
                destinationViewController.departure = false
            }
            collectionView?.deselectItem(at: (collectionView?.indexPathsForSelectedItems![0])!, animated: false)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            ActualRoutes.route = SearchRoute(departure: AppValues.favoritesRoutes[indexPath.row][0], arrival: AppValues.favoritesRoutes[indexPath.row][1])
            performSegue(withIdentifier: "rechercherItineraire", sender: self)
        } else if (row[indexPath.row][0] as? String ?? "") == "itineraryCell" {
            performSegue(withIdentifier: row[indexPath.row][3] as? String ?? "", sender: self)
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // The timer here allow the view to rotate first and let the time to refresh view size values
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(refreshCollectionView), userInfo: nil, repeats: false)
    }

    func refreshCollectionView() {
        self.collectionView?.reloadData()
    }
}

extension RoutesCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRowArray: [CGFloat]

        print(UIScreen.main.bounds.width)
        if UIDevice.current.userInterfaceIdiom == .pad {
            itemsPerRowArray = [2, 2, 2, 2, 1, 1]
        } else if UIScreen.main.bounds.width > 720.0 {
            itemsPerRowArray = [2, 2, 2, 2, 1, 1]
        } else if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            itemsPerRowArray = [3, 3, 3, 3, 1.5, 1]
        } else {
            itemsPerRowArray = [2, 2, 2, 2, 1, 1]
        }
        let heightArray: [CGFloat] = [100, 100, 100, 100, 50, 50]
        let itemsPerRow: CGFloat
        let height: CGFloat
        if indexPath.section == 0 {
            itemsPerRow = itemsPerRowArray[indexPath.row]
            height = heightArray[indexPath.row]
        } else {
            itemsPerRow = 1
            height = 100
        }
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth: CGFloat
            availableWidth = view.bounds.width - paddingSpace

        let widthPerItem = (availableWidth / itemsPerRow) - 1

        return CGSize(width: widthPerItem, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension RoutesCollectionViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
