//
//  ExtensionDelegate.swift
//  tpg offline watchOS Extension
//
//  Created by Rémy DA COSTA FARO on 05/11/2017.
//  Copyright © 2017 Remy. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate {

  func applicationDidFinishLaunching() {
    WatchSessionManager.sharedManager.startSession()
  }

  func applicationDidBecomeActive() {
  }

  func applicationWillResignActive() {
  }

  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    for task in backgroundTasks {
      switch task {
      case let backgroundTask as WKApplicationRefreshBackgroundTask:
        backgroundTask.setTaskCompletedWithSnapshot(false)
      case let snapshotTask as WKSnapshotRefreshBackgroundTask:
        snapshotTask
          .setTaskCompleted(restoredDefaultState: true,
                            estimatedSnapshotExpiration: Date.distantFuture,
                            userInfo: nil)
      case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
        connectivityTask.setTaskCompletedWithSnapshot(false)
      case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
        urlSessionTask.setTaskCompletedWithSnapshot(false)
      default:
        task.setTaskCompletedWithSnapshot(false)
      }
    }
  }

}
