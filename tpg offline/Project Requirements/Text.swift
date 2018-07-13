//
//  Text.swift
//  tpg offline
//
//  Created by Remy on 11/07/2018.
//  Copyright © 2018 Remy. All rights reserved.
//
// Please, do not edit the line below, this file must be excluded from line_length
// limit
// swiftlint:disable line_length

import Foundation

struct Text {
  static func accessibleTime(hours: Int, minutes: Int) -> String {
    return String(format: "%@ hours %@".localized, "\(hours)", minutes < 10 ? "0\(minutes)" : "\(minutes)")
  }
  static let activated = "Activated".localized
  static let address = "Address".localized
  static let alamofireDescription = "Elegant HTTP Networking in Swift - https://github.com/Alamofire/Alamofire".localized
  static let apnsError = "We need your devices's unique identifier to send you notifications, even if the app is closed (except if the device is off). Check if notifications and background app refresh are allowed.".localized
  static let application = "Application".localized
  static let alreadySheduled = "We already sheduled a reminder with these parameters.".localized
  static let areYouConnected = "Are you connected to internet?".localized
  static let arrivalAt = "Arrival at".localized
  static let arrivalMissing = "Arrival stop is missing".localized
  static let atDepartureTime = "At departure time".localized
  static let atCoreOfProject = "At the core of the project".localized
  static let automatic = "Automatic".localized
  static let busIsComming = "Bus is comming".localized
  static let busIsCommingNow = "The bus is comming now!".localized
  static let busStop = "Bus Stop".localized
  static let cancel = "Cancel".localized
  static let cantAddSmartReminder = "Sorry, but we were not able to add your smart notification. Do you want to try again?".localized
  static let cantLoadSmartReminders = "Can't load Smart Reminders".localized
  static let cantSetATimer = "You can't set a timer for this bus, but you should run to take it.".localized
  static let cedric = "Cédric Da Costa Faro".localized
  static let confirmation = "Confirmation".localized
  static let connectionsMap = "Connections map".localized
  static let connectWifi = "Connect to tpg-freeWiFi".localized
  static let `continue` = "Continue".localized
  static let credits = "Credits".localized
  static let darkMode = "Dark mode".localized
  static let dataProviders = "Data providers".localized
  static let days = "Days".localized
  static let deactivateSmartRemindersMessage = "Deactivating Smart Reminders does not remove existing Smart Reminders. Use the Pending notifications section to remove them.".localized
  static let defaultTab = "Default tab".localized
  static let defaultTabOnStartup = "Default tab on startup".localized
  static let delete = "Delete".localized
  static let designAndDevelopement = "Design and developement".localized
  static let departures = "Departures".localized
  static let departureAt = "Departure at".localized
  static let departureAndArrivalMissing = "Departure and arrival stops are missing".localized
  static func departuresFor(line: String) -> String {
    return String(format: "Departures for the line %@".localized, line)
  }
  static let departureMissing = "Departure stop is missing"
  static func directionDeparture(to: String?, at: String?) -> String {
    return String(format: "Direction %@, departure at %@".localized,
           to ?? "",
           at ?? "")
  }

  static func directionDeparture(to: String?, inMinutes: String?) -> String {
    return String(format: "Direction %@, departure in %@".localized,
                  to ?? "",
                  inMinutes ?? "")
  }
  static let disruptions = "Disruptions".localized
  static let disruptionsMonitoring = "Disruptions monitoring".localized
  static let disruptionsMonitoringSubtitle = "Here, you can choose when you want to monitor the lines you want. If a disruption occured during the monitoring period, we will send you a notification.".localized
  static func distance(meters: Double, minutes: Int) -> String {
    if minutes == 0 {
      return String(format: "%@m".localized,
                    "\(Int(meters))")
    } else {
      return String(format: "%@m (~%@ minutes)".localized,
                    "\(Int(meters))", "\(minutes)")
    }
  }
  static func directionErrorLoading(to: String?) -> String {
    return String(format: "Direction %@, error while loading the remaining time".localized,
                  to ?? "")
  }
  static func directionLeaving(to: String?) -> String {
    return String(format: "Direction %@, leaving now".localized, to ?? "")
  }
  static func directionNoMore(to: String?) -> String {
    return String(format: "Direction %@, no more bus".localized, to ?? "")
  }
  static let downloadMap = "Download map".localized
  static func doYouMean(_ stopName: String) -> String {
    return String(format: "Do you mean %@?".localized, stopName)
  }
  static let duplicateReminder = "Duplicate reminder".localized
  static let error = "Error".localized
  static let errorNoInternet = "Sorry, there is an error. Are you sure your are connected to internet ?".localized
  static let externalProject = "External libraries, used in this project".localized
  static let fabricDescription = "Crash Reporting and Analytics".localized
  static let favorites = "Favorites".localized
  static let fiveMinutesBefore = "5 minutes before".localized
  static let friday = "Friday".localized
  static let from = "From".localized
  static let fromWithDots = "From...".localized
  static let fromSunsetSunrise = "From Sunset to Sunrise".localized
  static let general = "General".localized
  static let giveFeedback = "Give your feedback !".localized
  static let githubWebpage = "Github webpage".localized
  static let goMode = "Go! Mode".localized
  static let goModeActivated = "Go! Mode activated".localized
  static let goModeActivatedSubtitle = "You will receive notifications when you will soon need to leave the bus".localized
  static let goModeHelp = "This mode sends you notifications to guide you on your route, like \"Take the bus\" and \"Leave the bus soon\" reminders."
  static let goNextStop = "(Go!) You're leaving the bus at the next stop!".localized
  static let invalidRoute = "Invalid route".localized
  static let lastFeatures = "Last features".localized
  static let letsTakeTheBus = "Let's take the bus!".localized
  static func line(_ line: String?) -> String {
    return String(format: "Line %@".localized,
                  "\(line ?? "?#!".localized)")
  }
  static func line(_ line: String?, destination: String) -> String {
    return String(format: "Line %@ - %@".localized, line ?? "#?!".localized, destination)
  }
  static let linesHistory = "Lines history and moral and material support".localized
  static let loading = "Loading...".localized
  static let loadingSmartReminders = "Loading Smart Reminders".localized
  static let lookingForAStop = "Are you looking for a stop ?".localized
  static let manual = "Manual".localized
  static let map = "Map".localized
  static func minutesLeft(_ minutes: Int) -> String {
    return String(format: "%@ minutes left!".localized, "\(minutes)")
  }
  static let missingErrorMessage = "I dont know... The error message is missing.".localized
  static let monday = "Monday".localized
  static let monitoring = "Monitoring".localized
  static let nearestStops = "Nearest stops".localized
  static let nearestStopsFrom = "Nearest stops from".localized
  static let newOfflineDepartures = "New offline departures available".localized
  static var newOfflineDeparturesSubtitle: String {
    return App.automaticDeparturesDownload ? "You can download them in Settings or you can activate Wi-Fi to automatically download them." : "You can download them in Settings".localized
  }
  static let nextStops = "Next Stops".localized
  static let noBusWillCome = "No more bus will come to this stop today.".localized
  static func noctambus(_ line: String) -> String {
    return "Noctambus \(line.last ?? Character(""))"
  }
  static let noctambusRegionalMap = "Noctambus regional map".localized
  static let noctambusUrbanMap = "Noctambus urban map".localized
  static let noDeparturesInstalled = "No offline departures installed".localized
  static let noDisruptions = "No disruptions".localized
  static let noDisruptionsSubtitle = "Fortunately, there is no disruptions at this time.".localized
  static let noInternetMonitoredLines = "Sorry, you need to be connected to internet to manage monitored lines.".localized
  static let noInternetMonitoredLinesSubtitle = "Monitoring a line will allow you to receive a notification in case of disruptions on your favorite lines.".localized
  static let noLinesMonitored = "No lines monitored".localized
  static let noLinesMonitoredSubtitle = "It's seems you are not not monitoring any line.\nMonitoring a line will allow you to receive a notification in case of disruptions on your favorite lines. Why not to try with pushing the + button, at the top-right angle of your device ?".localized
  static let noResults = "No results".localized
  static let noResultsFound = "Sorry, but no results was found. Please try with other parameters.".localized
  static let notifications = "Notifications".localized
  static func notificationWillBeSend(minutes: Int) -> String {
    return String(format: "A notification will be send %@".localized, (minutes == 0 ? "at the time of departure.".localized : String(format: "%@ minutes before.".localized, "\(minutes)")))
  }
  static let no = "No".localized
  static let now = "Now".localized
  static let numberMinutesBeforeDepartures = "Number of minutes before departure".localized
  static let offlineDepartures = "Offline departures".localized
  static let offlineDeparturesNotDownloaded =
    "You didn't downloaded offline departures, and you're not connected to internet".localized
  static let offlineDeparturesOnWifi = "Offline departures will be downloaded with a Wi-Fi connection".localized
  static var offlineDeparturesVersion: String {
    return String(format: "Offline departures version: %@".localized, UserDefaults.standard.string(forKey: "departures.json.md5")!)
  }
  static let offlineMode = "Offline mode".localized
  static let ok = "OK".localized
  static let oops = "Oops, an error occurred.".localized
  static let optional = "Optional".localized
  static let orientation = "Orientation".localized
  static let other = "Other".localized
  static let passedStops = "Passed Stops".localized
  static func path(index: Int) -> String {
    return String(format: "Path %@".localized, "\(index + 1)")
  }
  static let pendingNotifications = "Pending notifications".localized
  static func platform(_ number: String) -> String {
    return String(format: "Platform %@".localized, number)
  }
  static let privacy = "Privacy".localized
  static let project = "The project".localized
  static let reinitAlphabeticalOrder = "Do you want to reinit the stops list to the alphabetical order?".localized
  static let regionalMap = "Regional map".localized
  static let regionalRoute = "Regional route".localized
  static let reload = "Reload".localized
  static let reloadDepartures = "Reload departures".localized
  static let reloadMap = "Reload map".localized
  static func rememberLeaveDestination(stop: String) -> String {
    return String(format: "Remember you have to leave at %@, your destination".localized, stop)
  }
  static func rememberLeaveLine(stop: String, line: String?) -> String {
    return String(format: "Remember you have to leave at %@ to take the line %@".localized, stop, line ?? "#@?")
  }
  static let reminder = "Reminder".localized
  static func reminderMessage(stopName: String, leftTime: String) -> String {
    return String(format: "At %@ - In %@ minutes\nWhen do you want to be reminded?".localized, stopName, leftTime)
  }
  static let remy = "Rémy Da Costa Faro".localized
  static let reorderStops = "Reorder stops view".localized
  static let reversed = "Reversed".localized
  static let routeCrossZones = "This route crosses several areas. Therefore, you must have a regional ticket/pass corresponding to these zones:\n".localized
  static let routes = "Routes".localized
  static let sameDepartureAndArrival = "The departure and the arrival stops are the same.".localized
  static let saturday = "Saturday".localized
  static let sbb = "SBB".localized
  static let sbbDescription = "Offline departures and TAC timetables".localized
  static func sbb(line: String?) -> String {
    return String(format: "SBB %@".localized, "\(line ?? "#?!".localized)")
  }
  static func sbb(line: String?, destination: String) -> String {
    return String(format: "SBB %@ - %@".localized, "\(line ?? "#?!".localized)", destination)
  }
  static let search = "Search".localized
  static let sendMail = "Send email".localized
  static let smartReminder = "Smart Reminder".localized
  static let smartReminders = "Smart Reminders".localized
  static let smartRemindersDescription = "Smart reminders are departures reminders that, unlike standard reminders, take into account traffic variations and bus delays.\rThis feature requires an Internet connection to work, so it will not be offered in offline mode, and you can disabled it if you want in online mode.".localized
  static let snotpg = "SNOTPG".localized
  static let sorry = "Sorry".localized
  static let sorryError = "Sorry for that. Can you try again, or send an email to us if the problem persist?".localized
  static let specialThanks = "Special thanks".localized
  static let specific = "Specific".localized
  static let stopNotFound = "Stop not found"
  static let stopNotFoundSubtitle = "We did not found the stop. Please try with another name."
  static let sunday = "Sunday".localized
  static func take(line: String?, to destination: String) -> String {
    return String(format: "Take the line %@ to %@".localized, line ?? "?#!".localized, destination)
  }
  static func take(line: String?, to destination: String, in minutes: Int) -> String {
    return String(format: "Take the line %@ to %@ in %@".localized,
                  line ?? "?#!".localized, destination, "\(minutes)")
  }
  static func takeNow(line: String?, to destination: String) -> String {
    return String(format: "Take the line %@ to %@ now".localized,
                  line ?? "?#!".localized, destination)
  }
  static let tacNetwork = "TAC Network - Approximate timetable".localized
  static let tenMinutesBefore = "10 minutes before".localized
  static let testing = "Testing".localized
  static let thatsAllForToday = "That's all for today".localized
  static let thursday = "Thursday".localized
  static let timetablesDepartures =
    "You are using timetables departures. So departures are subjects to change.".localized
  static let to = "To".localized
  static let toWithDots = "To...".localized
  static let tpgoffline = "tpg offline".localized
  static var tpgofflineVersion: String {
    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
      as? String else { return "" }
    return
      String(format: "tpg offline, version %@".localized, version)
  }
  static let tpgOpenData = "Open data of Geneva public transport".localized
  static let tpgOpenDataDescription = "Departures, Disruptions and Maps".localized
  static let transportApi = "Open data of Transport API".localized
  static let tryAgain = "Try again".localized
  static let tryAgainWithoutSmartRemiders = "Try again without Smart Reminders".localized
  static let tuesday = "Tuesday".localized
  static let unknow = "Unknow".localized
  static let unknowContent = "Unknow content".localized
  static let updateAvailable = "An update is available".localized
  static let updateDepartures = "Update departures".localized
  static let urbanMap = "Urban map".localized
  static let via = "Via".localized
  static func via(number: Int) -> String {
    return String(format: "Via %@".localized, "\(number + 1)")
  }
  static func via(list: [String]) -> String {
    return String(format: "Via: %@".localized, list.joined(separator: ", "))
  }
  static let viaWithDots = "Via...".localized
  static let waitAMinute = "Wait a minute...".localized
  static let warning = "Warning!".localized
  static let weekdays = "Weekdays".localized
  static let weekend = "Weekend".localized
  static let wednesday = "Wednesday".localized
  static let wifi = "Wi-Fi".localized
  static let whenReminder = "When do you want to be reminded".localized
  static let wholeTpgNetwork = "Whole tpg network".localized
  static let yes = "Yes".localized
  static let youForgotToAddDays = "You forgot to add some days...".localized
  static let youWillBeReminded = "You will be reminded".localized
}
