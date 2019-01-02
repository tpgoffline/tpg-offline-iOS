//
//  DataUpdateManager.swift
//  tpg offline beta
//
//  Created by Rémy on 14/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//

import UIKit
import Reachability
import Alamofire
import Mapbox

class DataUpdateManager: NSObject {
  
  enum DownloadingMapTheme {
    case current
    case other
    case none
  }
  
  var downloadingMapTheme: DownloadingMapTheme = .none
  
  let reachability = Reachability()!
  static let shared = DataUpdateManager()
  
  func checkUpdate(viewController: UIViewController) {
    // Update maps
    if (self.reachability.connection == .wifi || App.allowDownloadWithMobileData),
      App.downloadMaps {
      downloadingMapTheme = .current
      //self.downloadMap()
    }
    
    // Check update for departures
    Alamofire.request(URL.offlineDeparturesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5") {
        if App.automaticDeparturesDownload,
          (self.reachability.connection == .wifi ||
            App.allowDownloadWithMobileData) {
          DataUpdateManager.shared.downloadOfflineDepartures()
        } else if UserDefaults.standard.bool(forKey: "remindUpdate") == false {
          UserDefaults.standard.set(true, forKey: "offlineDeparturesUpdateAvailable")
          UserDefaults.standard.set(true, forKey: "remindUpdate")
          let alertController =
            UIAlertController(title: Text.newOfflineDepartures,
                              message: Text.newOfflineDeparturesSubtitle,
                              preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: Text.ok,
                                                  style: .default,
                                                  handler: nil))
          viewController.present(alertController, animated: true, completion: nil)
          if App.automaticDeparturesDownload {
            let selector = #selector(self.reachabilityChanged(note:))
            NotificationCenter.default.addObserver(self,
                                                   selector: selector,
                                                   name: .reachabilityChanged,
                                                   object: self.reachability)
            do {
              try self.reachability.startNotifier()
            } catch {
              print("could not start reachability notifier")
            }
          }
        }
      }
    }
    
    Alamofire.request(URL.stopsMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "stops.json.md5") {
        self.getNewStops(updatedMD5)
      }
    }
    
    Alamofire.request(URL.linesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "lines.json.md5") {
        self.getNewLines(updatedMD5)
      }
    }
    
    Alamofire.request(URL.imagesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "images.json.md5") {
        self.getNewImages(updatedMD5)
      }
    }
  }
  
  @objc func reachabilityChanged(note: Notification) {
    guard let reachability = note.object as? Reachability else { return }
    Alamofire.request(URL.offlineDeparturesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5") {
        if App.automaticDeparturesDownload,
          (reachability.connection == .wifi || App.allowDownloadWithMobileData) {
          DataUpdateManager.shared.downloadOfflineDepartures()
        }
      }
    }
  }
  
  func getNewStops(_ updatedMD5: String) {
    Alamofire.request(URL.stops).responseData { (response) in
      if let stopsData = response.result.value {
        UserDefaults.standard.set(stopsData, forKey: "stops.json")
        UserDefaults.standard.set(updatedMD5, forKey: "stops.json.md5")
      }
    }
  }
  
  func getNewLines(_ updatedMD5: String) {
    Alamofire.request(URL.lines).responseData { (response) in
      if let stopsData = response.result.value {
        UserDefaults.standard.set(stopsData, forKey: "lines.json")
        UserDefaults.standard.set(updatedMD5, forKey: "lines.json.md5")
      }
    }
  }
  
  func getNewImages(_ updatedMD5: String) {
    App.log("Downloading stops satellite images")
    Alamofire.request(URL.images).responseJSON { (response) in
      if let stopsData = response.result.value as? [String: String] {
        var index: UInt = 0
        
        let source = DispatchSource.makeUserDataAddSource(queue: .main)
        source.setEventHandler {
          index += source.data
          if index == stopsData.count {
            UserDefaults.standard.set(updatedMD5, forKey: "images.json.md5")
          }
        }
        source.resume()
        
        for (key, image) in stopsData {
          DispatchQueue.global(qos: .utility).async {
            guard let data = Data(base64Encoded: image) else {
              return
            }
            let image = UIImage(data: data)
            let imageData = image?.jpegData(compressionQuality: 1.0)
            var fileURL = URL(fileURLWithPath:
              NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                  .allDomainsMask,
                                                  true)[0])
            fileURL.appendPathComponent("image\(key).jpeg")
            do {
              try imageData?.write(to: fileURL)
            } catch let error {
              print(error)
            }
            source.add(data: 1)
          }
        }
      }
    }
  }
  
  func downloadMap() {
    print("🔻 Downloading maps")
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(offlinePackProgressDidChange),
                   name: NSNotification.Name.MGLOfflinePackProgressChanged,
                   object: nil)
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(offlinePackDidReceiveError),
                   name: NSNotification.Name.MGLOfflinePackError,
                   object: nil)
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(offlinePackDidReceiveMaximumAllowedTiles),
                   name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached,
                   object: nil)
    
    let sw = CLLocationCoordinate2D(latitude: 46.10381, longitude: 5.94847)
    let ne = CLLocationCoordinate2D(latitude: 46.31884, longitude: 6.33044)
    
    let region: MGLTilePyramidOfflineRegion
    let context: Data
    
    if downloadingMapTheme == .current {
      if App.darkMode {
        region = MGLTilePyramidOfflineRegion(styleURL: URL.mapDark,
                                             bounds: MGLCoordinateBounds(sw: sw,
                                                                         ne: ne),
                                             fromZoomLevel: 10,
                                             toZoomLevel: 15)
        
        let userInfo = ["name": "Geneva Offline Dark"]
        context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
      } else {
        region = MGLTilePyramidOfflineRegion(styleURL: URL.mapLight,
                                             bounds: MGLCoordinateBounds(sw: sw,
                                                                         ne: ne),
                                             fromZoomLevel: 10,
                                             toZoomLevel: 15)
        
        let userInfo = ["name": "Geneva Offline Light"]
        context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
      }
    } else {
      if App.darkMode {
        region = MGLTilePyramidOfflineRegion(styleURL: URL.mapLight,
                                             bounds: MGLCoordinateBounds(sw: sw,
                                                                         ne: ne),
                                             fromZoomLevel: 10,
                                             toZoomLevel: 15)
        
        let userInfo = ["name": "Geneva Offline Light"]
        context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
      } else {
        region = MGLTilePyramidOfflineRegion(styleURL: URL.mapDark,
                                             bounds: MGLCoordinateBounds(sw: sw,
                                                                         ne: ne),
                                             fromZoomLevel: 10,
                                             toZoomLevel: 15)
        
        let userInfo = ["name": "Geneva Offline Dark"]
        context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
      }
    }
    
    MGLOfflineStorage.shared.addPack(for: region,
                                     withContext: context) { (pack, error) in
                                      guard error == nil else {
                                        // The pack couldn’t be created for some reason.
                                        print("Error: \(error?.localizedDescription ?? "unknown error")")
                                        return
                                      }
                                      
                                      // Start downloading.
                                      pack!.resume()
    }
  }
  
  func downloadOfflineDepartures() {
    DataUpdateManager.shared.status = .downloading
    Alamofire.request(URL.offlineDeparturesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value {
        Alamofire.request(URL.offlineDepartures).responseJSON { (response) in
          if let data = response.result.value as? [String: String] {
            DataUpdateManager.shared.status = .processing
            var index: UInt = 0
            
            let source = DispatchSource.makeUserDataAddSource(queue: .main)
            source.setEventHandler {
              index += source.data
              if index == data.count {
                DataUpdateManager.shared.status = .notDownloading
                UserDefaults.standard.set(updatedMD5, forKey: "departures.json.md5")
                UserDefaults.standard.set(false,
                                          forKey: "offlineDeparturesUpdateAvailable")
                UserDefaults.standard.set(false, forKey: "remindUpdate")
              }
            }
            source.resume()
            for (key, value) in data {
              DispatchQueue.global(qos: .utility).async {
                var fileURL = URL(fileURLWithPath:
                  NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                      .allDomainsMask,
                                                      true)[0])
                fileURL.appendPathComponent(key)
                do {
                  try value.write(to: fileURL, atomically: true, encoding: .utf8)
                } catch let error {
                  print(error)
                }
                source.add(data: 1)
              }
            }
          } else {
            DataUpdateManager.shared.status = .error
          }
        }
      }
    }
  }
  
  enum OfflineDeparturesStatus {
    case notDownloading
    case downloading
    case processing
    case error
  }
  
  var status: OfflineDeparturesStatus = .notDownloading {
    didSet {
      DataUpdateManager.shared.updateDownloadStatus()
    }
  }
  
  private var dataUpdateDelegates =
    [DataUpdateDelegate]()
  
  func addDownloadOfflineDeparturesDelegate<T>(_ delegate: T) where
    T: DataUpdateDelegate, T: Equatable {
      dataUpdateDelegates.append(delegate)
  }
  
  func removeDownloadOfflineDeparturesDelegate<T>(_ delegate: T) where
    T: DataUpdateDelegate, T: Equatable {
      for (index, dataUpdateDelegate) in
        dataUpdateDelegates.enumerated() {
          if let dataUpdateDelegate =
            dataUpdateDelegate as? T,
            dataUpdateDelegate == delegate {
            dataUpdateDelegates.remove(at: index)
            break
          }
      }
  }
  
  func updateDownloadStatus() {
    DispatchQueue.main.async {
      self.dataUpdateDelegates.forEach { $0.updateDownloadStatus() }
    }
  }
  
  /// Load departures from specified SBB Id
  ///
  /// - Parameter sbbId: SBB Id of stop
  /// - Returns: (departuresGroup, requestStatus, filteredLines)
//  func loadDepartures(_ sbbId: String) -> (DeparturesGroup?,
//    RequestStatus,
//    [String]) {
//      let day = Calendar.current.dateComponents([.weekday], from: Date())
//      var path: URL
//      
//      guard let dirString = NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                                .allDomainsMask,
//                                                                true).first else {
//                                                                  return (nil, .error, [])
//      }
//      let dir = URL(fileURLWithPath: dirString)
//      switch day.weekday! {
//      case 6:
//        path = dir.appendingPathComponent("VEN\(sbbId).json")
//      case 7:
//        path = dir.appendingPathComponent("SAM\(sbbId).json")
//      case 1:
//        path = dir.appendingPathComponent("DIM\(sbbId).json")
//      default:
//        path = dir.appendingPathComponent("LUN\(sbbId).json")
//      }
//      
//      do {
//        let data = try Data(contentsOf: path)
//        String(contentsOfFile: path)
//        var options = DeparturesOptions()
//        options.networkStatus = .offline
//        let jsonDecoder = JSONDecoder()
//        jsonDecoder.userInfo = [ DeparturesOptions.key: options ]
//        var departures = try jsonDecoder.decode(DeparturesGroup.self, from: data)
//        departures.departures.sort(by: { (departure1, departure2) -> Bool in
//          let leftTime1: Int = Int(departure1.leftTime)!
//          let leftTime2: Int = Int(departure2.leftTime)!
//          return leftTime1 < leftTime2
//        })
//        let filteredLines = departures.lines.filter({
//          App.favoritesLines.contains($0)
//        })
//        if departures.lines.isEmpty {
//          return (nil, .noResults, [])
//        }
//        return (departures, .ok, filteredLines)
//      } catch {
//        return (nil, .error, [])
//      }
//  }
  
  // MARK: - MGLOfflinePack notification handlers
  
  @objc func offlinePackProgressDidChange(notification: NSNotification) {
    if let pack = notification.object as? MGLOfflinePack,
      let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context)
        as? [String: String] {
      let progress = pack.progress
      let completedResources = progress.countOfResourcesCompleted
      let expectedResources = progress.countOfResourcesExpected
      
      // Calculate current progress percentage.
      let progressPercentage = Float(completedResources) / Float(expectedResources)
      
      // If this pack has finished, print its size and resource count.
      if completedResources == expectedResources {
        let bytesCompleted = pack.progress.countOfBytesCompleted
        let byteCount =
          ByteCountFormatter.string(fromByteCount: Int64(bytesCompleted),
                                    countStyle: ByteCountFormatter.CountStyle.memory)
        print("🔻 Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources") // swiftlint:disable:this line_length
        if downloadingMapTheme == .current {
          downloadingMapTheme = .other
          downloadMap()
        } else {
          downloadingMapTheme = .none
        }
      } else {
        // Otherwise, print download/verification progress.
        print("🔻  Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.") // swiftlint:disable:this line_length
      }
    }
  }
  
  @objc func offlinePackDidReceiveError(notification: NSNotification) {
    if let pack = notification.object as? MGLOfflinePack,
      let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context)
        as? [String: String],
      let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error]
        as? NSError {
      print("🔻  Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")") // swiftlint:disable:this line_length
    }
  }
  
  @objc func offlinePackDidReceiveMaximumAllowedTiles(notification: NSNotification) {
    let key = MGLOfflinePackUserInfoKey.maximumCount
    if let pack = notification.object as? MGLOfflinePack,
      let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context)
        as? [String: String],
      let maximumCount = (notification.userInfo?[key] as AnyObject).uint64Value {
      print("🔻  Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.") // swiftlint:disable:this line_length
    }
  }
}

protocol DataUpdateDelegate: class {
  func updateDownloadStatus()
}
