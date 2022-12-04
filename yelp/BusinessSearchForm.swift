//
//  BusinessSearchForm.swift
//  yelp
//
//  Created by Adil Waqar on 12/3/22.
//

import SwiftUI

struct BusinessSearchForm: View {
    @State private var keyword = ""
    @State private var distance = "0"
    @State private var category = "Default"
    @State private var location = ""
    @State private var autoDetect = false
    
    @State private var businesses: [Business] = []
        
    private let categories = [
        "Default": "all",
        "Arts and Entertainment": "arts, All",
        "Health and Medical": "health, All",
        "Hotels and Travels": "hotelstravel, All",
        "Food": "food, All",
        "Professional Services": "professional, All"
    ]
    
    var body: some View {
        Form {
            Section {
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
                    if !autoDetect {
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
            
            Section {
                List {
                    Text("Results")
                        .font(.title)
                        .fontWeight(.medium)
                    ForEach(businesses.indices, id: \.self) { index in
                        NavigationLink(destination: Text("Second View")) {
                            HStack {
                                Text(String(index + 1))
                                Spacer()
                                AsyncImage(url: URL(string: businesses[index].image_url)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(5)
                                Spacer()
                                Text(businesses[index].name)
                                    .frame(width: 100)
                                    .foregroundColor(Color.gray)
                                Spacer()
                                Text(String(businesses[index].rating))
                                    .fontWeight(.bold)
                                Spacer()
                                Text(String(toMiles(meters: businesses[index].distance))).fontWeight(.bold)
                                }
                        }
                    }
                }
            }
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
        
        self.businesses = businesses
        
        print("fetched businesses: \(self.businesses)")
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
    
    func toMiles(meters: Float) -> Int {
        let miles = meters / 1609.344
        return Int(round(miles))
    }

}

struct BusinessSearchForm_Previews: PreviewProvider {
    static var previews: some View {
        BusinessSearchForm()
    }
}
