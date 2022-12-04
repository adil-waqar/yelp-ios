//
//  YelpApi.swift
//  yelp
//
//  Created by Adil Waqar on 11/26/22.
//

import Foundation

enum YelpError : Error {
    case RequestFailed
    case BusinessDeserialzationError
}

struct YelpApi {
    private let BASE_URL = "http://localhost:8080"
    private var session = URLSession.shared
    
    func fetchBusinesses(term: String, radius: String, categories: String, latitude: String, longitude: String) async throws -> [Business] {
        let urlParams = [URLQueryItem(name: "term", value: term),
                         URLQueryItem(name: "radius", value: radius),
                         URLQueryItem(name: "categories", value: categories),
                         URLQueryItem(name: "latitude", value: latitude),
                         URLQueryItem(name: "longitude", value: longitude)]
        
        let url = URL(string: BASE_URL + "/v1/businesses/search")!.appending(queryItems: urlParams)
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Couldn't fetch businesses")
            throw YelpError.RequestFailed
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(YelpResponse.self, from: data)
            return response.businesses
        } catch {
            print("could not deserialize businesses")
            throw YelpError.BusinessDeserialzationError
        }
        
    }
}

struct YelpResponse : Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let alias: String
    let image_url: String
    let name: String
    let rating: Float
    let distance: Float
}
