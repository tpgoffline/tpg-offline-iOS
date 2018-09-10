//
//  DownloadOfflineDeparturesManager.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 11/06/2018.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import UIKit
import Reachability
import Alamofire
import Mapbox

class OfflineDeparturesManager: NSObject {
  fileprivate override init() {
    super.init()
  }

  enum DownloadingMapTheme {
    case current
    case other
    case none
  }

  var downloadingMapTheme: DownloadingMapTheme = .none

  let reachability = Reachability()!

  func checkUpdate(viewController: UIViewController) {
    if (self.reachability.connection == .wifi || App.allowDownloadWithMobileData),
      App.downloadMaps {
      downloadingMapTheme = .current
      self.downloadMap()
    }

    Alamofire.request(URL.offlineDeparturesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5") {
        if App.automaticDeparturesDownload,
          (self.reachability.connection == .wifi ||
            App.allowDownloadWithMobileData) {
          OfflineDeparturesManager.shared.download()
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
  }

  @objc func reachabilityChanged(note: Notification) {
    guard let reachability = note.object as? Reachability else { return }
    Alamofire.request(URL.offlineDeparturesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value,
        updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5") {
        if App.automaticDeparturesDownload,
          (reachability.connection == .wifi || App.allowDownloadWithMobileData) {
          OfflineDeparturesManager.shared.download()
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

  func download() {
    OfflineDeparturesManager.shared.status = .downloading
    Alamofire.request(URL.offlineDeparturesMD5).responseString { (response) in
      if let updatedMD5 = response.result.value {
        Alamofire.request(URL.offlineDepartures).responseJSON { (response) in
          if let data = response.result.value as? [String: String] {
            OfflineDeparturesManager.shared.status = .processing
            var index: UInt = 0

            let source = DispatchSource.makeUserDataAddSource(queue: .main)
            source.setEventHandler {
              index += source.data
              if index == data.count {
                OfflineDeparturesManager.shared.status = .notDownloading
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
            OfflineDeparturesManager.shared.status = .error
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

  static let shared = OfflineDeparturesManager()
  var status: OfflineDeparturesStatus = .notDownloading {
    didSet {
      OfflineDeparturesManager.shared.updateDownloadStatus()
    }
  }

  private var downloadOfflineDeparturesDelegates =
    [DownloadOfflineDeparturesDelegate]()

  func addDownloadOfflineDeparturesDelegate<T>(_ delegate: T) where
    T: DownloadOfflineDeparturesDelegate, T: Equatable {
    downloadOfflineDeparturesDelegates.append(delegate)
  }

  func removeDownloadOfflineDeparturesDelegate<T>(_ delegate: T) where
    T: DownloadOfflineDeparturesDelegate, T: Equatable {
    for (index, downloadOfflineDeparturesDelegate) in
      downloadOfflineDeparturesDelegates.enumerated() {
      if let downloadOfflineDeparturesDelegate =
        downloadOfflineDeparturesDelegate as? T,
        downloadOfflineDeparturesDelegate == delegate {
        downloadOfflineDeparturesDelegates.remove(at: index)
        break
      }
    }
  }

  func updateDownloadStatus() {
    DispatchQueue.main.async {
      self.downloadOfflineDeparturesDelegates.forEach { $0.updateDownloadStatus() }
    }
  }

  /// Load departures from specified SBB Id
  ///
  /// - Parameter sbbId: SBB Id of stop
  /// - Returns: (departuresGroup, requestStatus, filteredLines)
  func loadDepartures(_ sbbId: String) -> (DeparturesGroup?,
                                           RequestStatus,
                                           [String]) {
    let day = Calendar.current.dateComponents([.weekday], from: Date())
    var path: URL

    guard let dirString = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                              .allDomainsMask,
                                                              true).first else {
      return (nil, .error, [])
    }
    let dir = URL(fileURLWithPath: dirString)
    switch day.weekday! {
    case 6:
      path = dir.appendingPathComponent("VEN\(sbbId).json")
    case 7:
      path = dir.appendingPathComponent("SAM\(sbbId).json")
    case 1:
      path = dir.appendingPathComponent("DIM\(sbbId).json")
    default:
      path = dir.appendingPathComponent("LUN\(sbbId).json")
    }

    do {
      let data = try Data(contentsOf: path)
      var options = DeparturesOptions()
      options.networkStatus = .offline
      let jsonDecoder = JSONDecoder()
      jsonDecoder.userInfo = [ DeparturesOptions.key: options ]
      var departures = try jsonDecoder.decode(DeparturesGroup.self, from: data)
      departures.departures.sort(by: { (departure1, departure2) -> Bool in
        let leftTime1: Int = Int(departure1.leftTime)!
        let leftTime2: Int = Int(departure2.leftTime)!
        return leftTime1 < leftTime2
      })
      let filteredLines = departures.lines.filter({
        App.favoritesLines.contains($0)
      })
      if departures.lines.isEmpty {
        return (nil, .noResults, [])
      }
      return (departures, .ok, filteredLines)
    } catch {
      return (nil, .error, [])
    }
  }

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

protocol DownloadOfflineDeparturesDelegate: class {
  func updateDownloadStatus()
}
