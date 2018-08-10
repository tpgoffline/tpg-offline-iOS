//
//  GoogleMapsGeocoding.swift
//  tpg offline
//
//  Created by Rémy Da Costa Faro on 04/12/2017.
//  Copyright © 2018 Rémy Da Costa Faro. All rights reserved.
//

import Foundation
import CoreLocation

struct GoogleMapsGeocoding: Decodable {
  struct Address: Decodable {
    struct Geometry: Decodable {
      struct Location: Decodable {
        var location: CLLocation

        public init(latitude: Double, longitude: Double) {
          self.location = CLLocation(latitude: latitude, longitude: longitude)
        }

        enum CodingKeys: String, CodingKey {
          case latitude = "lat"
          case longitude = "lng"
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)

          let latitude = try container.decode(Double.self, forKey: .latitude)
          let longitude = try container.decode(Double.self, forKey: .longitude)
          self.init(latitude: latitude, longitude: longitude)
        }
      }
      var location: Location
    }

    var geometry: Geometry
    var formattedAddress: String

    public init(geometry: Geometry, formattedAddress: String) {
      self.geometry = geometry
      self.formattedAddress = formattedAddress
    }

    enum CodingKeys: String, CodingKey {
      case geometry = "geometry"
      case formattedAddress = "formatted_address"
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let geometry = try container.decode(Geometry.self, forKey: .geometry)
      let formattedAddress =
        try container.decode(String.self, forKey: .formattedAddress)
      self.init(geometry: geometry, formattedAddress: formattedAddress)
    }
  }

  var results: [Address]
}
