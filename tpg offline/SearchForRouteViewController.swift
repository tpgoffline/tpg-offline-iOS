//
//  SearchForRouteViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 27/11/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class SearchForRouteViewController: SearchViewController {
  
  var isDepartureStop = true
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if isDepartureStop {
      CurrentRouteManager.shared.departureStop = searchText != "" ? stopsSearched[indexPath.row] : App.stops[indexPath.row]
    } else {
      CurrentRouteManager.shared.arrivalStop = searchText != "" ? stopsSearched[indexPath.row] : App.stops[indexPath.row]
    }
    CurrentRouteManager.shared.checkToBuildRoute()
    self.navigationController?.popViewController(animated: true)
  }
}
