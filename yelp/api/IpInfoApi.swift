//
//  IpInfo.swift
//  yelp
//
//  Created by Adil Waqar on 11/26/22.
//

import Foundation

enum IpInfoError : Error {
    case GeolocationDetectionError
    case IpInfoDeserializationError
}

struct IpInfoApi {
    private let BASE_URL = "https://ipinfo.io"
    private let TOKEN = "8709eb9ee48dc9"
    private let session = URLSession.shared
    
    public func detectGeoLocation() async throws -> (String, String) {
        let urlParams = [URLQueryItem(name: "token", value: TOKEN)]
        
        let url = URL(string: BASE_URL)!.appending(queryItems: urlParams)
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Couldn't detect {geoLocation}")
            throw IpInfoError.GeolocationDetectionError
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(IpInfoResponse.self, from: data)
            let coordinates = response.loc.components(separatedBy: ",")
            return (coordinates[0], coordinates[1])
        } catch {
            print("could not deserialize ip info response")
            throw IpInfoError.IpInfoDeserializationError
        }
    }
}


struct IpInfoResponse : Codable {
    let loc: String
}
