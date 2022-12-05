//
//  ImageSliderView.swift
//  yelp
//
//  Created by Adil Waqar on 12/4/22.
//

import SwiftUI

struct ImageSliderView: View {
    var images: [String]
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { item in
                AsyncImage(url: URL(string: item)) { image in
                    image
                        .resizable()
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                .frame(width: 300, height: 280)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(images: ["https://s3-media1.fl.yelpcdn.com/bphoto/3MPORmI4jJR_uiwO-o9QRg/o.jpg"])
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
