//
//  FlightHeaderSection.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 5/4/2025.
//
import SwiftUI

struct FlightHeaderSection: View {
    @Binding var flight: Flight
    var isEditing: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isEditing {
                TextField("Flight Number", text: $flight.flightNumber)
                    .aviationInputStyle()
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                DatePicker("Flight Date",
                           selection: $flight.date,
                           displayedComponents: .date)
                    .labelsHidden()
            } else {
                Text(flight.flightNumber)
                    .font(.largeTitle.bold())
                
                Text(flight.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}
