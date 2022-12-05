//
//  BusinessDetailView.swift
//  yelp
//
//  Created by Adil Waqar on 12/4/22.
//

import SwiftUI

struct BusinessDetailView: View {

    @State private var businessDetail: BusinessDetailResponse?
    @State private var error = false
    @State private var loading = false
    
    private var facebookUrl: String {
        if let businessDetail = self.businessDetail {
            let url: String = "https://twitter.com/intent/tweet?text=Check%20\(businessDetail.name)%20\(businessDetail.url)"
            return url
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
    
    var businessId: String;
    
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
                        Text(businessDetail.price)
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
                
                Button("Reserve Now") {
                    
                }
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .background(Color.red)
                .foregroundColor(/*@START_MENU_TOKEN@*/.white/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                
                HStack {
                    Text("Share on: ")
                        .fontWeight(.medium)
                    Link(destination: URL(string: "hey")!) {
                        Image("facebook")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                    }
                    Link(destination: URL(string: "hey")!) {
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
}

struct BusinessDetailView_Previews: PreviewProvider {
    static let businessIdMock = "gR9DTbKCvezQlqvD7_FzPw"
    
    static var previews: some View {
        BusinessDetailView(businessId: businessIdMock)
    }
}
