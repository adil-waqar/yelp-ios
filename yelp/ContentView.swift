//
//  ContentView.swift
//  yelp
//
//  Created by Adil Waqar on 11/21/22.
//

import SwiftUI

struct ContentView: View {
    @State private var keyword = ""
    @State private var distance = "0"
    @State private var category = "Default"
    @State private var location = ""
    @State private var autoDetect = false
    
    private let BASE_URL = "http://localhost:8080/v1"
    
    private let categories = [
        "Default": "all",
        "Arts and Entertainment": "arts, All",
        "Health and Medical": "health, All",
        "Hotels and Travels": "hotelstravel, All",
        "Food": "food, All",
        "Professional Services": "professional, All"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Keyword: ")
                        .foregroundColor(Color.gray)
                    TextField("Required", text: $keyword)
                }
                HStack {
                    Text("Distance: ")
                        .foregroundColor(Color.gray)
                    TextField("Required", text: $distance)
                        .keyboardType(.numberPad)
                }
                HStack {
                    Picker("Category: ", selection: $category) {
                        ForEach(Array(categories.keys), id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(Color.gray)
                }
                if (!autoDetect) {
                    HStack {
                        Text("Location: ")
                            .foregroundColor(Color.gray)
                        TextField("Required", text: $location)
                    }
                }
                HStack {
                    Toggle("Auto-detect my location", isOn: $autoDetect).foregroundColor(Color.gray)
                }
                
                HStack {
                    Spacer()
                    Button("Submit", action: {
                        Task {
                            try await searchBusinesses()
                        }
                    })
                    .padding(.vertical, 15.0)
                    .padding(.horizontal, 25.0)
                    .background(!autoDetect ? Color.gray : Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(6)
                    .buttonStyle(BorderlessButtonStyle())
                
                    Spacer()
                    Button("Clear", action: {
                        print("clear")
                    })
                    .padding(.vertical, 15.0)
                    .padding(.horizontal, 25.0)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(6)
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Spacer()
                }
                
            }
            .navigationTitle("Business Search")
        }
    }
    
    func searchBusinesses() async throws {
        var coordinates: (String, String)
        
        if (autoDetect) {
            let ipInfo = IpInfoApi()
            coordinates = try await ipInfo.detectGeoLocation()
        } else {
            let geolocation = GeoLocationApi()
            coordinates = try await geolocation.fetchGeoLocation(location: location)
        }
    
        let (lat, lng) = coordinates
        
        let yelp = YelpApi()

        let businesses = try await yelp.fetchBusinesses(term: keyword, radius: toMeters(miles: distance), categories: categories[category]!, latitude: lat, longitude: lng)
        
        print(businesses)
    }
    
    func toMeters(miles: String) -> String {
        if let milesFloat = Float(miles) {
            let meters = milesFloat * 1609.344
            return String(Int(round(meters)))
        } else {
            print("couldn't convert string to float in {toMeters()}")
            return ""
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
