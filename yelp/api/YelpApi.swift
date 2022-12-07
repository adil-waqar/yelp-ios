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
    case BusinessDetailDeserialzationError
    case BusinessReviewsDeserialzationError
    case BusinessAutocompleteDeserializationError
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
            let response = try decoder.decode(BusinessSearchResponse.self, from: data)
            return response.businesses
        } catch {
            print("could not deserialize businesses: \(error)")
            throw YelpError.BusinessDeserialzationError
        }
        
    }
    
    func fetchBusinessDetails(id: String) async throws -> BusinessDetailResponse {
        let url = URL(string: BASE_URL + "/v1/businesses/\(id)")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Couldn't fetch business details")
            throw YelpError.RequestFailed
        }
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(BusinessDetailResponse.self, from: data)
            return response
        } catch {
            print("could not deserialize business details: \(error)")
            throw YelpError.BusinessDetailDeserialzationError
        }
    }
    
    func fetchBusinessReviews(id: String) async throws -> [BusinessReviewResponse] {
        let url = URL(string: BASE_URL + "/v1/businesses/\(id)/reviews")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Couldn't fetch business reviews")
            throw YelpError.RequestFailed
        }
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode([BusinessReviewResponse].self, from: data)
            return response
        } catch {
            print("could not deserialize business reviews: \(error)")
            throw YelpError.BusinessReviewsDeserialzationError
        }
    }
    
    func fetchAutocomplete(keyword: String) async throws -> [Term] {
        print("hre")
        print(keyword)
        let url = URL(string: BASE_URL + "/v1/auto/\(keyword)")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Couldn't fetch autocomplete keywords")
            throw YelpError.RequestFailed
        }
        
        let decoder = JSONDecoder()
        
        do {
            let terms = try decoder.decode([Term].self, from: data)
            return terms
        } catch {
            print("could not deserialize autcomplete terms: \(error)")
            throw YelpError.BusinessReviewsDeserialzationError
        }
    }
}

struct Term: Codable, Identifiable {
    let text: String
    let id = UUID()
    
    private enum CodingKeys: String, CodingKey {
            case text
    }
}

struct BusinessSearchResponse : Codable {
    let businesses: [Business]
}

struct Business: Codable, Identifiable {
    let id: String
    let alias: String
    let image_url: String
    let name: String
    let rating: Float
    let distance: Float
}

struct BusinessDetailResponse: Codable {
    let name: String
    let location: BusinessLocation
    let display_phone: String
    let hours: [hour]?
    let categories: [Category]
    let price: String?
    let url: String
    let photos: [String]
    let coordinates: Coordinate
}

struct BusinessReviewResponse: Codable, Identifiable {
    let user: User
    let rating: Int
    let text: String
    let time_created: String
    let id: String
}

struct User: Codable {
    let name: String
}

struct Coordinate: Codable {
    let latitude: Float
    let longitude: Float
}

struct Category: Codable {
    let title: String
}

struct hour: Codable {
    let is_open_now: Bool
}

struct BusinessLocation: Codable {
    let display_address: [String]
}
