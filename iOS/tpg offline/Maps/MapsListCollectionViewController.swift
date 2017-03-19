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
    fileprivate let itemsPerRow: CGFloat = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

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
	}

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapsList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapsCell", for: indexPath) as! MapsCollectionViewCell // swiftlint:disable:this force_cast

        cell.mapsImage.image = UIImage(named: mapsList[indexPath.row])
        cell.titleLabel.text = mapsList[indexPath.row].localized
        cell.titleLabel.textColor = AppValues.textColor
        cell.titleLabel.backgroundColor = AppValues.primaryColor.withAlphaComponent(0.8)
        cell.backgroundColor = .white

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
			mapViewController.mapImage = UIImage(named: mapsList[(collectionView?.indexPathsForSelectedItems?[0].row)!])
		}
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
        let availableWidth = view.frame.width - paddingSpace
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
