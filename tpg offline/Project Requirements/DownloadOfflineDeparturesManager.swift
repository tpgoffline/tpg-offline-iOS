//
//  DownloadOfflineDeparturesManager.swift
//  tpg offline
//
//  Created by Rémy on 11/06/2018.
//  Copyright © 2018 Remy. All rights reserved.
//

import UIKit
import Reachability
import Alamofire

class DownloadOfflineDeparturesManager: NSObject {
    fileprivate override init() {
        super.init()
    }
    
    func checkUpdate(viewController: UIViewController) {
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json.md5").responseString { (response) in
            if let updatedMD5 = response.result.value, updatedMD5 != UserDefaults.standard.string(forKey: "departures.json.md5") {
                if App.automaticDeparturesDownload && Reachability()!.connection == .wifi {
                    DownloadOfflineDeparturesManager.shared.download()
                }
                else if UserDefaults.standard.bool(forKey: "remindUpdate") == false {
                    UserDefaults.standard.set(true, forKey: "offlineDeparturesUpdateAvailable")
                    UserDefaults.standard.set(true, forKey: "remindUpdate")
                    let alertController = UIAlertController(title: "New offline departures available".localized, message: "You can download them in Settings".localized, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                    viewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func download() {
        DownloadOfflineDeparturesManager.shared.status = .downloading
        Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json.md5").responseString { (response) in
            if let updatedMD5 = response.result.value {
                Alamofire.request("https://raw.githubusercontent.com/RemyDCF/tpg-offline/master/JSON/departures.json").responseJSON { (response) in
                    if let data = response.result.value as? [String: String] {
                        DownloadOfflineDeparturesManager.shared.status = .processing
                        var index: UInt = 0
                        
                        let source = DispatchSource.makeUserDataAddSource(queue: .main)
                        source.setEventHandler {
                            index += source.data
                            if index == data.count {
                                DownloadOfflineDeparturesManager.shared.status = .notDownloading
                                UserDefaults.standard.set(updatedMD5, forKey: "departures.json.md5")
                                UserDefaults.standard.set(false, forKey: "offlineDeparturesUpdateAvailable")
                                UserDefaults.standard.set(false, forKey: "remindUpdate")
                            }
                        }
                        source.resume()
                        for (key, value) in data {
                            DispatchQueue.global(qos: .utility).async {
                                var fileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0])
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
                        DownloadOfflineDeparturesManager.shared.status = .error
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
    
    static let shared = DownloadOfflineDeparturesManager()
    var status: OfflineDeparturesStatus = .notDownloading {
        didSet {
            DownloadOfflineDeparturesManager.shared.updateDownloadStatus()
        }
    }
    
    private var downloadOfflineDeparturesDelegates = [DownloadOfflineDeparturesDelegate]()
    
    func addDownloadOfflineDeparturesDelegate<T>(_ delegate: T) where T: DownloadOfflineDeparturesDelegate, T: Equatable {
        downloadOfflineDeparturesDelegates.append(delegate)
    }
    
    func removeDownloadOfflineDeparturesDelegate<T>(_ delegate: T) where T: DownloadOfflineDeparturesDelegate, T: Equatable {
        for (index, downloadOfflineDeparturesDelegate) in downloadOfflineDeparturesDelegates.enumerated() {
            if let downloadOfflineDeparturesDelegate = downloadOfflineDeparturesDelegate as? T, downloadOfflineDeparturesDelegate == delegate {
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
}

protocol DownloadOfflineDeparturesDelegate: class {
    func updateDownloadStatus()
}
