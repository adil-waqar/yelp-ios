//
//  BusinessDetailView.swift
//  yelp
//
//  Created by Adil Waqar on 12/4/22.
//

import SwiftUI

struct BusinessDetailView: View {
    @AppStorage("reservations") var reservations = Data.init()

    @State private var businessDetail: BusinessDetailResponse?
    @State private var error = false
    @State private var loading = false
    @State private var isReservationOpen = false
    
    var businessId: String;
    
    private var isReserved: Bool {
        if (reservations.isEmpty) {
            return false
        }
        
        do {
            let reservations = try JSONDecoder().decode([Reservation].self, from: reservations)
            for reservation in reservations {
                if reservation.businessId == businessId {
                    return true
                }
            }
            return false
        } catch {
            print("could not deserialize reservation in isReserved")
            return false
        }
    }
    
    private var twitterUrl: String {
        if let businessDetail = self.businessDetail {
            let businessNameEncoded = businessDetail.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let url: String = "https://twitter.com/intent/tweet?text=Check+\(businessNameEncoded)+\(businessDetail.url)"
            return url
        } else {
            return ""
        }
    }
    
    private var facebookUrl: String {
        if let businessDetail = self.businessDetail {
            let url: String = "https://www.facebook.com/sharer/sharer.php?u=\(businessDetail.url)&amp;src=sdkpreparse"
            return url
        } else {
            return ""
        }
    }
    
    private var unwrappedPrice: String {
        if let businessDetail = self.businessDetail {
            if let price = businessDetail.price {
                return price
            } else {
                return "not available"
            }
        } else {
            return ""
        }
    }

    private var isOpen: Bool {
        if let businessDetail = self.businessDetail {
            if let hours = businessDetail.hours {
                if (hours[0].is_open_now) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
        
    var body: some View {
        VStack (spacing: 15) {
            if let businessDetail = self.businessDetail {
                Text(businessDetail.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                HStack {
                    VStack (alignment: .leading) {
                        Text("Address")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                        Text(businessDetail.location.display_address.joined(separator: " "))
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                    VStack (alignment: .trailing) {
                        Text("Category")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                        Text(businessDetail.categories.map({ category in
                            category.title
                            
                        })
                            .joined(separator: " | "))
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                            .foregroundColor(Color.gray)
                    }
                }
                
                HStack {
                    VStack (alignment: .leading) {
                        Text("Phone")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                        Text(businessDetail.display_phone)
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                    VStack (alignment: .trailing) {
                        Text("Price Range")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                        Text(unwrappedPrice)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                            .foregroundColor(Color.gray)
                    }
                }
                
                HStack {
                    VStack (alignment: .leading) {
                        Text("Status")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                        Text(self.isOpen ? "Open" : "Closed")
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .foregroundColor(isOpen ? Color.green : Color.red)
                    }
                    Spacer()
                    VStack (alignment: .trailing) {
                        Text("Visit Yelp for more")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                        Link("Business Link", destination: URL(string: businessDetail.url)!)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing)
                            .foregroundColor(Color.blue)
                    }
                }
                
                if (!isReserved) {
                    Button("Reserve Now") {
                        isReservationOpen.toggle()
                    }
                    .sheet(isPresented: $isReservationOpen, content: {
                        ReservationFormView(isReservationOpen: $isReservationOpen, businessName: businessDetail.name, businessId: businessId)
                   })
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    .background(Color.red)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                    .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                } else {
                    Button("Cancel Reservation") {
                        cancelReservation()
                    }
                    .padding(.all)
                    .background(Color.blue)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                    .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                }
                
                HStack {
                    Text("Share on: ")
                        .fontWeight(.medium)
                    Link(destination: URL(string: facebookUrl)!) {
                        Image("facebook")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                    }
                    Link(destination: URL(string: twitterUrl)!) {
                        Image("twitter")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                }
                
      
                ImageSliderView(images: businessDetail.photos)
                   .frame(height: 300)
                   .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
  
                
                Spacer()
            } else {
                if (loading) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                
                if (error) {
                    Text("Couldn't fetch business details")
                }
            }
        }
        .task {
            await getBusinessDetails(id: businessId)
        }
    }
    
    func getBusinessDetails(id: String) async {
        do {
            let yelp = YelpApi()
            self.loading = true
            let businessDetail = try await yelp.fetchBusinessDetails(id: businessId)
            self.businessDetail = businessDetail
            self.error = false
        } catch {
            self.error = true
            print("an error occurred while fetching businessDetails. \(error)")
        }
        
        self.loading = false
    }
    
    func cancelReservation() {
        do {
            let reservations = try JSONDecoder().decode([Reservation].self, from: reservations)
            let filteredReservation = reservations.filter { reservation in
                return reservation.businessId != businessId
            }
            
            if let encoded = try? JSONEncoder().encode(filteredReservation) {
                self.reservations = encoded
            }
        } catch {
            print("could not deserialize reservation in isReserved")
        }
    }
}

struct BusinessDetailView_Previews: PreviewProvider {
    static let businessIdMock = "gR9DTbKCvezQlqvD7_FzPw"
    
    static var previews: some View {
        BusinessDetailView(businessId: businessIdMock)
    }
}
