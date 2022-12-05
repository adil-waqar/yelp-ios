//
//  BusinessReviewsView.swift
//  yelp
//
//  Created by Adil Waqar on 12/4/22.
//

import SwiftUI

struct BusinessReviewsView: View {
    @State private var loading: Bool = false
    @State private var businessReview: [BusinessReviewResponse]?
    
    var businessId: String
    
    var body: some View {
        List {
            if let businessReviews = self.businessReview {
                ForEach(businessReviews) { review in
                    VStack (spacing: 10.0) {
                        HStack {
                            Text(review.user.name)
                                .fontWeight(.bold)
                            Spacer()
                            Text(String(review.rating) + "/5").fontWeight(.medium)
                        }
                        Text(review.text).foregroundColor(Color.gray)
                        Text(review.time_created.components(separatedBy: " ")[0])
                    }
                }
            } else {
                if (loading) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }.task {
            await getBusinessReviews(id: businessId)
        }
    }
    
    func getBusinessReviews(id: String) async {
        do {
            let yelp = YelpApi()
            self.loading = true
            let reviews = try await yelp.fetchBusinessReviews(id: id)
            self.businessReview = reviews
        } catch {
            print("an error occurred while fetching business reviews: \(error)")
        }
        
        self.loading = false
    }
}

struct BusinessReviewsView_Previews: PreviewProvider {
    static let businessIdMock = "gR9DTbKCvezQlqvD7_FzPw"

    static var previews: some View {
        BusinessReviewsView(businessId: businessIdMock)
    }
}
