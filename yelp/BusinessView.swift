//
//  BusinessView.swift
//  yelp
//
//  Created by Adil Waqar on 12/4/22.
//

import SwiftUI

struct BusinessView: View {
    var businessId: String
    
    var body: some View {
        TabView {
            BusinessDetailView(businessId: businessId).tabItem {
                Label("Business Detail", systemImage: "text.bubble.fill")
            }
            
            BusinessLocationView().tabItem {
                Label("Map Location", systemImage: "location.fill")
            }
            
            BusinessReviewsView().tabItem {
                Label("Reviews", systemImage: "message.fill")
            }
        }
    }
}

struct BusinessView_Previews: PreviewProvider {
    static let businessIdMock = "gR9DTbKCvezQlqvD7_FzPw"
    
    static var previews: some View {
        BusinessView(businessId: businessIdMock)
    }
}
