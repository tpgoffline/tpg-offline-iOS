//
//  SearchViewController.swift
//  tpg offline beta
//
//  Created by Rémy on 07/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit

class SearchViewController: TableViewController {
  
  lazy var searchBar = UISearchBar(frame: CGRect.zero)
  
  var searchText: String! = "" {
    didSet {
      self.searchRequest?.cancel()
      self.searchRequest = DispatchWorkItem(flags: .inheritQoS) {
        var stops = App.stops.filter({
          $0.name.escaped.contains(self.searchText.escaped)
        })
        if let stopCode = App.stops.filter({
          $0.code.escaped == self.searchText.escaped
        })[safe: 0] {
          
          //stops.removeAll(where: { $0.code == stopCode.code })
          var a: [Stop] = []
          for stop in stops where stop.code != stopCode.code {
            a.append(stop)
          }
          stops = a
          stops.insert(stopCode, at: 0)
        }
        self.stopsSearched = stops
      }
      DispatchQueue.main.async(execute: self.searchRequest!)
    }
  }
  var searchRequest: DispatchWorkItem?
  var stopsSearched: [Stop] = [] {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ColorModeManager.shared.add(self)
    colorModeDidUpdated()
    
    searchBar.delegate = self
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = "Search"
    
    navigationItem.titleView = searchBar
  }
  
  deinit {
    ColorModeManager.shared.remove(self)
  }
  
  @IBAction func goBack() {
    self.navigationController?.popViewController(animated: true)
  }
}

extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchText != "" ? stopsSearched.count : App.stops.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
    let stop = searchText != "" ? stopsSearched[indexPath.row] : App.stops[indexPath.row]
    cell.textLabel?.text = stop.title
    cell.textLabel?.textColor = App.textColor
    cell.detailTextLabel?.text = stop.subTitle
    cell.detailTextLabel?.textColor = App.textColor
    cell.backgroundColor = App.cellBackgroundColor
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let vc = storyboard?.instantiateViewController(withIdentifier: "departuresVC") as! DeparturesViewController
    vc.stop = searchText != "" ? stopsSearched[indexPath.row] : App.stops[indexPath.row]
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchText = searchText
  }
}
