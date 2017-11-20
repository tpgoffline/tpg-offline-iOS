//
//  AllDeparturesCollectionViewController.swift
//  tpg offline
//
//  Created by Remy on 01/10/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import UIKit
import Alamofire

class FlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = 2.0

        let horizontalSpacing: CGFloat = 5

        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY
                || layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }

            if layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            } else {
                layoutAttribute.frame.origin.x = leftMargin
            }

            leftMargin += layoutAttribute.frame.width + horizontalSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return attributes
    }

    override open func invalidationContext(forPreferredLayoutAttributes preferred: UICollectionViewLayoutAttributes,
                                           withOriginalAttributes original: UICollectionViewLayoutAttributes)
        -> UICollectionViewLayoutInvalidationContext {
            let context: UICollectionViewLayoutInvalidationContext = super.invalidationContext(
                forPreferredLayoutAttributes: preferred,
                withOriginalAttributes: original
            )

            let indexPath = preferred.indexPath

            if indexPath.item == 0 {
                context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: [indexPath])
            }

            return context
    }
}

class AllDeparturesCollectionViewController: UICollectionViewController {

    var departure: Departure?
    var stop: Stop?
    var departuresList: DeparturesGroup?
    var hours: [Int] = []

    var loading = false {
        didSet {
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let flowLayout = FlowLayout()
        flowLayout.headerReferenceSize = CGSize(width: self.collectionView?.bounds.width ?? 15, height: 44)
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        self.collectionView?.collectionViewLayout = flowLayout

        title = String(format: "Line %@".localized, "\(departure?.line.code ?? "#!?")")

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: #imageLiteral(resourceName: "reloadNavBar"),
                            style: UIBarButtonItemStyle.plain,
                            target: self,
                            action: #selector(self.refresh))
        ]

        let refreshControl = UIRefreshControl()
        collectionView?.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)

        refresh()
    }

    @objc func refresh() {
        loading = true
        Alamofire.request("https://prod.ivtr-od.tpg.ch/v1/GetAllNextDepartures.json",
                          method: .get,
                          parameters: ["key": API.key,
                                       "stopCode": self.stop?.code ?? "#?!",
                                       "lineCode": self.departure?.line.code ?? "#?!",
                                       "destinationCode": self.departure?.line.destinationCode ?? "#?!"])
            .responseData { (response) in
                if let data = response.result.value {
                    var options = DeparturesOptions()
                    options.networkStatus = .online
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.userInfo = [ DeparturesOptions.key: options ]

                    do {
                        let json = try jsonDecoder.decode(DeparturesGroup.self, from: data)
                        self.departuresList = json
                    } catch {
                        self.loading = false
                        self.collectionView?.refreshControl?.endRefreshing()
                        return
                    }

                    self.hours = self.departuresList?.departures.map({ $0.dateCompenents?.hour ?? 0 }).uniqueElements ?? []
                    self.hours.sort()
                    self.loading = false
                    self.collectionView?.refreshControl?.endRefreshing()
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if loading {
            return 1
        } else {
            return self.hours.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if loading {
            return 5
        } else {
            return self.departuresList?.departures.filter({ $0.dateCompenents?.hour == self.hours[section] }).count ?? 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allDeparturesCell", for: indexPath) as?
            AllDeparturesCollectionViewCell else {
                return UICollectionViewCell()
        }

        if !loading {
            cell.departure = self.departuresList?.departures.filter({ $0.dateCompenents?.hour == self.hours[indexPath.section] })[indexPath.row]
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        if loading {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "allDeparturesHeader",
                                                                                   for: indexPath) as? AllDeparturesHeader else {
                                                                                    return UICollectionViewCell()
            }
            headerView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            headerView.title.text = ""
            return headerView
        } else {
            switch kind {
            case UICollectionElementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                       withReuseIdentifier: "allDeparturesHeader",
                                                                                       for: indexPath) as? AllDeparturesHeader else {
                                                                                        return UICollectionViewCell()
                }
                var dateComponents = DateComponents()
                let dateFormatter = DateFormatter()
                dateComponents.calendar = Calendar.current
                dateComponents.hour = self.hours[indexPath.section]
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                headerView.title.text = dateFormatter.string(from: dateComponents.date ?? Date())
                headerView.backgroundColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
                headerView.title.textColor = .white

                return headerView
            default:
                assert(false, "Unexpected element kind")
                return UICollectionReusableView()
            }
        }
    }
}

class AllDeparturesHeader: UICollectionReusableView {
    @IBOutlet weak var title: UILabel!
}
