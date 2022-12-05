//
//  BusinessLocationView.swift
//  yelp
//
//  Created by Adil Waqar on 12/4/22.
//

import SwiftUI
import MapKit

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}

struct BusinessLocationView: View {
    @State private var loading: Bool = false
    @State private var businessDetail: BusinessDetailResponse?
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.787789124691, longitude: -122.399305736113), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
    let markers = [Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 37.787789124691, longitude: -122.399305736113), tint: .red))]
    
    var businessId: String

    var body: some View {
        VStack {
            if let businessDetail = self.businessDetail {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: markers) { marker in
                            marker.location
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                if (loading) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }.task {
           await getBusinessDetails(id: businessId)
        }
        
    }
    
    func getBusinessDetails(id: String) async {
        do {
            let yelp = YelpApi()
            self.loading = true
            let businessDetail = try await yelp.fetchBusinessDetails(id: businessId)
            self.businessDetail = businessDetail
            
            let latitude = businessDetail.coordinates.latitude
            let longitude = businessDetail.coordinates.longitude
            
            print(latitude)
            print(longitude)
            
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        } catch {
            print("an error occurred while fetching businessDetails. \(error)")
        }
        
        self.loading = false
    }
}

struct BusinessLocationView_Previews: PreviewProvider {
    static let businessIdMock = "gR9DTbKCvezQlqvD7_FzPw"
    
    static var previews: some View {
        BusinessLocationView(businessId: businessIdMock)
    }
}
