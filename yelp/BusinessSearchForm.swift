//
//  BusinessSearchForm.swift
//  yelp
//
//  Created by Adil Waqar on 12/3/22.
//

import SwiftUI

struct BusinessSearchForm: View {
    @State private var keyword = ""
    @State private var distance = "10"
    @State private var category = "Default"
    @State private var location = ""
    @State private var autoDetect = false
    @State private var loading = false
        
    @State private var businesses: [Business] = []
    @State private var terms: [Term] = []
    @State private var loadingAutocomplete = false
    @FocusState private var keywordIsFocused: Bool
        
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
                            .onChange(of: keyword, perform: { _ in
                                Task {
                                    try await getAutocomplete()
                                }
                            })
                            .focused($keywordIsFocused)
                            .alwaysPopover(isPresented: .constant(keywordIsFocused)) {
                                Section {
                                    if (!self.loadingAutocomplete) {
                                        ForEach(terms) { term in
                                            Button {
                                                print(term.text)
                                                self.keyword = term.text
                                            } label: {
                                                Text(term.text)
                                            }
                                        }
                                    } else {
                                        ProgressView().progressViewStyle(.circular)
                                    }
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundColor(Color.gray)
                                .padding(.all)
                        }
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
                        .background((autoDetect || self.location.count > 0) ? Color.red : Color.gray)
                        .foregroundColor(Color.white)
                        .cornerRadius(6)
                        .buttonStyle(BorderlessButtonStyle())
                    
                        Spacer()
                        Button("Clear", action: {
                            clear()
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
                    if (!loading) {
                        ForEach(businesses.indices, id: \.self) { index in
                            NavigationLink(destination: BusinessView(businessId: businesses[index].id)) {
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
                    } else {
                        ProgressView().progressViewStyle(.circular)
                    }
                }
            }
        }
    }
    
    func getAutocomplete() async throws {
        self.loadingAutocomplete = true
        let yelp = YelpApi()
        let encodedKeyword = self.keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let terms = try await yelp.fetchAutocomplete(keyword: encodedKeyword)
        self.terms = terms
        self.loadingAutocomplete = false
    }
    
    func searchBusinesses() async throws {
        self.loading = true
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
        self.loading = false
    }
    
    func clear() {
        self.keyword = ""
        self.distance = "10"
        self.category = "Default"
        self.location = ""
        self.autoDetect = false
        self.businesses = []
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
