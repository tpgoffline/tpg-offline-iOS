//
//  Stop.swift
//  tpgoffline
//
//  Created by Remy DA COSTA FARO on 09/06/2017.
//  Copyright © 2017 Remy DA COSTA FARO. All rights reserved.
//

import Foundation
import CoreLocation

struct Stop: Codable {
    /// The name of the stop
    var name: String

    /// The name that will be show if the title and the subtitle are separated
    var title: String

    /// The text that will be show beside the title
    var subTitle: String

    /// The stop code of the stop. This stop code is attributed by the tpg
    var code: String

    /// The location of the stop
    var location: CLLocation

    /// The distance of the user from the stop
    var distance: Double

    /// The id that represent the stop on the SBB API.
    var sbbId: String

    /// The id that represent the stop in the app.
    var appId: Int

    var isTAC: Bool

    var pricingZone: [Int]

    var nameTransportAPI: String

    public init(name: String,
                title: String,
                subTitle: String,
                code: String,
                location: CLLocation,
                distance: Double,
                sbbId: String,
                appId: Int,
                pricingZone: [Int],
                nameTransportAPI: String,
                isTAC: Bool) {
        self.name = name
        self.title = title
        self.subTitle = subTitle
        self.code = code
        self.location = location
        self.distance = distance
        self.sbbId = sbbId
        self.appId = appId
        self.pricingZone = pricingZone
        self.nameTransportAPI = nameTransportAPI
        self.isTAC = isTAC
    }

    enum CodingKeys: String, CodingKey {
        case name
        case title
        case subTitle
        case code
        case latitude
        case longitude
        case sbbId
        case appId
        case pricingZone
        case nameTransportAPI
        case isTAC
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        let title = try container.decode(String.self, forKey: .title)
        let subTitle = try container.decode(String.self, forKey: .subTitle)
        let code = try container.decode(String.self, forKey: .code)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let sbbId = try container.decode(String.self, forKey: .sbbId)
        let appId = try container.decode(Int.self, forKey: .appId)
        let pricingZone = try container.decode([Int].self, forKey: .pricingZone)
        let nameTransportAPI = try container.decode(String.self, forKey: .nameTransportAPI)
        let isTAC = try container.decode(Bool.self, forKey: .isTAC)

        self.init(name: name,
                  title: title,
                  subTitle: subTitle,
                  code: code,
                  location: CLLocation(latitude: latitude, longitude: longitude),
                  distance: 0,
                  sbbId: sbbId,
                  appId: appId,
                  pricingZone: pricingZone,
                  nameTransportAPI: nameTransportAPI,
                  isTAC: isTAC)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.name, forKey: .name)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.subTitle, forKey: .subTitle)
        try container.encode(self.code, forKey: .code)
        try container.encode(self.location.coordinate.latitude, forKey: .latitude)
        try container.encode(self.location.coordinate.longitude, forKey: .longitude)
        try container.encode(self.sbbId, forKey: .sbbId)
        try container.encode(self.appId, forKey: .appId)
        try container.encode(self.pricingZone, forKey: .pricingZone)
        try container.encode(self.nameTransportAPI, forKey: .nameTransportAPI)
        try container.encode(self.isTAC, forKey: .isTAC)
    }

    static func == (lhd: Stop, rhd: Stop) -> Bool {
        return lhd.appId == rhd.appId
    }
}
