//
//  ReservationView.swift
//  yelp
//
//  Created by Adil Waqar on 12/6/22.
//

import SwiftUI

struct ReservationView: View {
    @AppStorage("reservations") private var reservations = Data.init()
    
    private var res: [Reservation] {
        if (reservations.isEmpty) {
            return []
        }
        do {
            return try JSONDecoder().decode([Reservation].self, from: reservations)
        } catch {
            print("could not deserialize reservations \(error)")
            return []
        }
    }

    var body: some View {
        NavigationStack {
            if (!res.isEmpty) {
                List {
                    ForEach(res) { re in
                        HStack(spacing: 20) {
                            Text(re.businessName)
                            Text(re.date.formatted(date: .numeric, time: .omitted))
                            Text(re.hour + ":" + re.minute)
                            Text(re.email)
                        }
                        .font(.system(size: 15))
                    }
                    .onDelete(perform: delete)
                }
                    .navigationTitle("Your Reservations")
            } else {
                Text("No bookings founds").foregroundColor(Color.red)
                    .navigationTitle("Your Reservations")
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        var reserv = res
        reserv.remove(atOffsets: offsets)
        
        if let encoded = try? JSONEncoder().encode(reserv) {
            self.reservations = encoded
        }
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView()
    }
}
