//
//  ContentView.swift
//  yelp
//
//  Created by Adil Waqar on 11/21/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            BusinessSearchForm()
            .navigationTitle("Business Search")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
