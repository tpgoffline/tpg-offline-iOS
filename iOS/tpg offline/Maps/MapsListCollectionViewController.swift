//
//  MapsListTableViewController.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 19/12/2015.
//  Copyright © 2016 Rémy Da Costa Faro. All rights reserved.
//

import UIKit

class MapsListTableViewController: UICollectionViewController {

	let mapsList = ["Plan urbain", "Plan régional", "Plan Noctambus urbain", "Plan Noctambus régional"]
    let mapNamesList = ["urb", "reg", "nocUrb", "nocReg"]

    fileprivate let itemsPerRow: CGFloat = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

	override func viewDidLoad() {
		super.viewDidLoad()
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible

        refreshTheme()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		refreshTheme()
        view.backgroundColor = AppValues.primaryColor.darken(percentage: 0.1)
	}

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapsList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapsCell", for: indexPath) as! MapsCollectionViewCell // swiftlint:disable:this force_cast

        cell.mapsImage.image = UIImage(named: mapNamesList[indexPath.row])
        cell.titleLabel.text = mapsList[indexPath.row].localized
        cell.titleLabel.textColor = AppValues.textColor
        cell.titleLabel.backgroundColor = AppValues.primaryColor.withAlphaComponent(0.9)
        cell.backgroundColor = .white

        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15

        return cell
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showMap" {
            guard let nav = segue.destination as? UINavigationController else {
                return
            }
            guard let mapViewController = nav.viewControllers[0] as? MapViewController else {
                return
            }
			mapViewController.mapImage = UIImage(named: mapNamesList[(collectionView?.indexPathsForSelectedItems?[0].row)!])
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

extension MapsListTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}

extension MapsListTableViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth: CGFloat = view.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: 200)
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
