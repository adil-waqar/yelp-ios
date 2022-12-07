//
//  ReservationFormView.swift
//  yelp
//
//  Created by Adil Waqar on 12/5/22.
//

import SwiftUI

struct Reservation: Codable, Identifiable {
    let businessId: String
    let businessName: String
    let date: Date
    let hour: String
    let minute: String
    let email: String
}

extension Reservation {
    var id: String {
        return businessId
    }
}

struct ReservationFormView: View {
    @AppStorage(wrappedValue: Data.init(), "reservations") var reservations: Data
    
    @State private var email: String = ""
    @State private var date = Date.now
    @State private var hour = "10"
    @State private var minute = "00"
    @State private var showAlert = false
    @State private var isReservationCompleted: Bool = false
    
    let hours = ["10", "11", "12", "13", "14", "15", "16", "17"]
    let minutes = ["00", "15", "30", "45"]
    
    @Binding var isReservationOpen: Bool
    
    var businessName: String
    var businessId: String

    var body: some View {
        if (!isReservationCompleted) {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Text("Reservation Form")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Text(businessName)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                Section {
                    HStack {
                        Text("Email: ")
                            .foregroundColor(Color.gray)
                        TextField("Required", text: $email)
                    }
                    HStack {
                        Text("Date: ")
                            .foregroundColor(Color.gray)
                        DatePicker("" ,selection: $date, in: Date.now..., displayedComponents: .date)
                            .labelsHidden()
                    }
                    HStack {
                        Text("Time: ")
                            .foregroundColor(Color.gray)
                        Picker("", selection: $hour) {
                            ForEach(hours, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        
                        Picker("", selection: $minute) {
                            ForEach(minutes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    HStack {
                        Spacer()
                        Button("Submit", action: {
                            if (isValidEmailAddr(email: email)) {
                                isReservationCompleted = true
                                storeReservation()
                            } else {
                                showAlert = true
                            }
                        })
                        .padding(.vertical, 15.0)
                        .padding(.horizontal, 25.0)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(15)
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                    }
                }
            }
            .foregroundColor(.black)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Please enter a valid email"))
            }
        } else {
            ZStack {
                VStack {
                    Spacer()
                    Text("Congratulations!").bold()
                    Text("You have successfully made a reservation at \(businessName)")
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.center)
                    Divider()
                    Spacer()
                    Button("Done", action: {
                         isReservationOpen = false
                    })
                    .padding(.vertical, 15.0)
                    .padding(.horizontal, 80.0)
                    .background(Color.white)
                    .foregroundColor(Color.green)
                    .cornerRadius(30)
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .background(Color.green)
        }
    }
    
    func storeReservation () {
        let reservation = Reservation(businessId: businessId,
                                      businessName: businessName,
                                      date: date,
                                      hour: hour,
                                      minute: minute,
                                      email: email)
        
        if (self.reservations.isEmpty) {
            if let encoded = try? JSONEncoder().encode([reservation]) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.reservations = encoded
                }
            }
        } else {
            do {
                var storedReservations = try JSONDecoder().decode([Reservation].self, from: reservations)
                storedReservations.append(reservation)
                
                if let encoded = try? JSONEncoder().encode(storedReservations) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.reservations = encoded
                    }
                }
            } catch {
                print("could not deserialize reservations: \(error)")
            }
        }
        
        self.isReservationCompleted = true
    }
    
    func isValidEmailAddr(email: String) -> Bool {
      let regex = #"^\S+@\S+\.\S+$"#

      let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
      return predicate.evaluate(with: email)
    }
}

struct ReservationFormView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationFormView(isReservationOpen: .constant(true), businessName: "Papa Johns", businessId: "13123")
    }
}
