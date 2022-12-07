//
//  ContentView.swift
//  yelp
//
//  Created by Adil Waqar on 11/21/22.
//

import SwiftUI

struct ContentView: View {
    @State var showsAlwaysPopover = false

    var body: some View {
        NavigationView {
            BusinessSearchForm()
            .navigationTitle("Business Search")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ReservationView()
                    } label: {
                        Image(systemName: "calendar.badge.clock").font(.title3)
                    }

                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
