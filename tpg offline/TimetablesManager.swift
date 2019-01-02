//
//  TimetablesManager.swift
//  tpg offline beta
//
//  Created by Rémy on 18/10/2018.
//  Copyright © 2018 Rémy. All rights reserved.
//
//  Inspired by the csa-challenge project, by Trainline
//  Modified by Rémy Da Costa Faro
//

import Foundation

class TimetablesManager {
  let maxStations = 8600000
  let timetable: Timetable
  let csa: CSA = CSA()
  
  static let shared = TimetablesManager()
  
  init() {
    timetable = Timetable()
    timetable.load()
  }
  
  struct Connection {
    let departureStation: Int
    let arrivalStation: Int
    let departureSeconds: Int
    let arrivalSeconds: Int
    let line: String
    let destinationStation: Int
    let tripId: Int
    
    init(string: String) {
      let items = string.components(separatedBy: .whitespaces)
      departureStation = Int(items[0]) ?? 0
      arrivalStation = Int(items[1]) ?? 0
      departureSeconds = Int(items[2]) ?? 0
      arrivalSeconds = Int(items[3]) ?? 0
      line = String(items[4])
      destinationStation = Int(items[5]) ?? 0
      tripId = Int(items[6]) ?? 0
    }
    
    static func == (lhs: Connection, rhs: Connection) -> Bool {
      return (lhs.departureStation == rhs.departureStation &&
        lhs.arrivalStation == rhs.arrivalStation &&
        lhs.departureSeconds == rhs.departureSeconds &&
        lhs.arrivalSeconds == rhs.arrivalSeconds &&
        lhs.line == rhs.line &&
        lhs.destinationStation == rhs.destinationStation &&
        lhs.tripId == rhs.tripId)
    }
  }
  
  class Timetable {
    var connections: Array<TimetablesManager.Connection> = []
    var status: Status = .notLoaded
    
    enum Status {
      case loaded
      case notLoaded
    }
    
    func load() {
      status = .notLoaded
      connections.removeAll()
      let start = DispatchTime.now()
      DispatchQueue.global(qos: .userInitiated).async {
        let day = Calendar.current.dateComponents([.weekday], from: Date())
        let dayString: String
        switch day.weekday! {
        case 6:
          dayString = "Friday"
        case 7:
          dayString = "Saturday"
        case 1:
          dayString = "Sunday"
        default:
          dayString = "Monday"
        }
        guard let path = Bundle.main.url(forResource: dayString, withExtension: "timetables") else { return }
        do {
          let fileContent = try String(contentsOf: path)
          let seperatedFileContent = fileContent.components(separatedBy: .newlines)
          self.connections.reserveCapacity(seperatedFileContent.count)
          self.connections = seperatedFileContent.map({ TimetablesManager.Connection(string: String($0)) })
          self.status = .loaded
          
          App.log("Timetables loaded")
          let end = DispatchTime.now()
          let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
          let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
          App.log("Time to evaluate problem: \(timeInterval) seconds")
        } catch {
          App.log("Can't load departures")
        }
      }
    }
  }
  
  class CSA {
    struct EarliestArrival {
      var time: Int
      var line: String
    }
    
    var inConnections: [Int] = []
    var earliestArrival: [EarliestArrival] = []
    let numberOfRoutes = 6
    var breakProcess = false
    var progress = 0.0
    
    func loop(arrivalStation: Int) {
      var earliest = Int.max
      
      while TimetablesManager.shared.timetable.status == .notLoaded {}
      
      for (index, connection) in TimetablesManager.shared.timetable.connections.enumerated() {
        var minimumConnectionDuration = 120
        if self.earliestArrival[connection.departureStation].line.isEmpty {
          minimumConnectionDuration = 0
        } else if connection.line == self.earliestArrival[connection.departureStation].line {
          minimumConnectionDuration = 0
        }
        if connection.departureSeconds >= (self.earliestArrival[connection.departureStation].time + minimumConnectionDuration),
          connection.arrivalSeconds < self.earliestArrival[connection.arrivalStation].time {
          self.earliestArrival[connection.arrivalStation].time = connection.arrivalSeconds
          self.earliestArrival[connection.arrivalStation].line = connection.line
          self.inConnections[connection.arrivalStation] = index
          
          if connection.arrivalStation == arrivalStation {
            earliest = min(earliest, connection.arrivalSeconds)
          }
        } else if connection.arrivalSeconds > earliest {
          return
        }
      }
    }
    
    func compute(departureStation: Int, arrivalStation: Int, departureTime: Int, completion: @escaping ([Connection]) -> ()) {
      breakProcess = false
      self.progress = 0
      let start = DispatchTime.now()
      DispatchQueue.global(qos: .userInitiated).async {
        var departureTimestamp = departureTime
        var routes: [[Connection]] = []
        var lastRoute: [Connection] = []
        var i = 0
        while routes.count < 6 && !self.breakProcess {
          i += 1
          if (i >= 50) {
            break
          }
          self.inConnections = Array<Int>(repeating: Int.max, count: TimetablesManager.shared.maxStations)
          self.earliestArrival = Array<EarliestArrival>(repeating: EarliestArrival(time: Int.max, line: ""), count: TimetablesManager.shared.maxStations)
          self.earliestArrival[departureStation].time = departureTimestamp
          
          if departureStation <= TimetablesManager.shared.maxStations, arrivalStation <= TimetablesManager.shared.maxStations {
            self.loop(arrivalStation: arrivalStation)
          }
          
          // Return results
          if self.inConnections[arrivalStation] == Int.max {
            App.log("No solution")
            routes.append(lastRoute)
            self.progress = 1
            completion(lastRoute)
            break
          } else {
            var route: [Connection] = []
            var lastConnectionIndex = self.inConnections[arrivalStation]
            
            while lastConnectionIndex != Int.max {
              let connection = TimetablesManager.shared.timetable.connections[lastConnectionIndex]
              route.append(connection)
              lastConnectionIndex = self.inConnections[connection.departureStation]
            }
            
            route.reverse()
            if lastRoute.isEmpty {
              lastRoute = route
            } else if lastRoute.last?.arrivalSeconds == route.last?.arrivalSeconds, (route.first?.departureSeconds ?? 0) > (lastRoute.first?.departureSeconds ?? 0) {
              lastRoute = route
            } else if lastRoute.last?.arrivalSeconds != route.last?.arrivalSeconds {
              routes.append(lastRoute)
              self.progress += (1 / 6)
              completion(route)
              lastRoute = route
              i = 0
            }
            departureTimestamp = route[0].departureSeconds + 1
          }
        }
        self.progress = 1
        self.breakProcess = false
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
        App.log("Time to evaluate problem: \(timeInterval) seconds")
      }
    }
  }
  
  func offlineDepartures(sbbId: Int) -> DeparturesGroup {
    guard timetable.status == .loaded else { return DeparturesGroup(departures: []) }
    let dateSinceMidnight = Date.sinceMidnight
    let departures = Array(timetable.connections)
      .filter { (connection) -> Bool in
        Int(connection.departureStation) == Int(sbbId)
      }
      .filter { connection -> Bool in
        connection.departureSeconds >= dateSinceMidnight && connection.departureSeconds <= (dateSinceMidnight + 3600)
      }
      .map { connection -> Departure in
        let leftTime = "\((connection.departureSeconds - dateSinceMidnight) / 60)"
        let destination = App.stops.first(where: { $0.sbbId == String(connection.destinationStation) })?.name ?? ""
        return Departure.init(line: Departure.Line(code: connection.line, destination: destination, destinationCode: ""), code: -1, leftTime: leftTime, timestamp: "", dateCompenents: nil, wifi: false, reliability: .reliable, reducedMobilityAccessibility: .accessible, platform: nil, vehiculeNo: connection.tripId, offline: true)
    }
    return DeparturesGroup(departures: departures)
  }
  
  func offlineDepartures(tripId: Int) -> [Departure] {
    guard timetable.status == .loaded else { return [] }
    let dateSinceMidnight = Date.sinceMidnight
    let departures = Array(timetable.connections)
      .filter { (connection) -> Bool in
        connection.tripId == tripId
      }
      .sorted(by: { (connection1, connection2) -> Bool in
        connection1.departureSeconds < connection2.departureSeconds &&
        connection1.arrivalSeconds < connection2.arrivalSeconds
      })
      .map { connection -> Departure in
        let leftTime = "\((connection.departureSeconds - dateSinceMidnight) / 60)"
        let destination = App.stops.first(where: { $0.sbbId == String(connection.destinationStation) })?.name ?? ""
        return Departure.init(line: Departure.Line(code: connection.line, destination: destination, destinationCode: ""), code: -1, leftTime: leftTime, timestamp: String(connection.departureSeconds), dateCompenents: nil, wifi: false, reliability: .reliable, reducedMobilityAccessibility: .accessible, platform: nil, vehiculeNo: connection.tripId, offline: true, stop: connection.departureStation)
    }
    return departures
  }
}
