//
//  GeoLocationApi.swift
//  yelp
//
//  Created by Adil Waqar on 11/26/22.
//

import Foundation

enum GeoLocationError : Error {
    case InvalidLocation
    case GeoLocationDeserializationError
}

struct GeoLocationApi {
    private let BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json"
    private let GEOCODING_API_KEY = "AIzaSyDjRSSBbNL930AYgOyIoldtwXI6abjmAM4"
    
    private var session = URLSession.shared
    
    public func fetchGeoLocation(location: String) async throws -> (String, String) {
        let urlParams = [URLQueryItem(name: "address", value: encodeLocation(location: location)),
                         URLQueryItem(name: "key", value: GEOCODING_API_KEY)]
        
        let url = URL(string: BASE_URL)!.appending(queryItems: urlParams)
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Couldn't fetch {geoLocation}")
            throw GeoLocationError.InvalidLocation
        }
        
        let decoder = JSONDecoder()
        
        do {
            let geoLocation = try decoder.decode(GeoLocationResponse.self, from: data)
            let lat = geoLocation.results[0].geometry.location.lat
            let lng = geoLocation.results[0].geometry.location.lng
            
            return (String(lat), String(lng))
        } catch {
            print("could not deserialize geolocation: \(error)")
            throw GeoLocationError.GeoLocationDeserializationError
        }
    }
    
    func encodeLocation(location: String) -> String {
        return location.replacingOccurrences(of: " ", with: "+")
    }
}

struct GeoLocationResponse : Codable {
    let results: [Result]
}

struct Result : Codable {
    let geometry: Geometry
}

struct Geometry: Codable {
    let location: Location;
}

struct Location: Codable {
    let lat: Float
    let lng: Float
}
