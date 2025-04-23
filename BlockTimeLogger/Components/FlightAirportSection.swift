//
//  FlightAirportSection.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 5/4/2025.
//

import SwiftUI

struct FlightAirportSection: View {
    @Binding var flight: Flight
    var isEditing: Bool
    let database: LocalDatabase
    @State private var departureAirport: Airport?
    @State private var arrivalAirport: Airport?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AIRPORTS")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                AirportCard(
                    type: "DEPARTURE",
                    airport: Binding(
                        get: { flight.departureAirport },
                        set: { newValue in
                            if let airport = newValue {
                                flight.departureAirportId = airport.id
                                flight.departureAirport = airport
                            }
                        }
                    ),
                    time: flight.formattedOutTime,
                    isEditing: isEditing,
                    database: database
                )

                AirportCard(
                    type: "ARRIVAL",
                    airport: Binding(
                        get: { flight.arrivalAirport },
                        set: { newValue in
                            if let airport = newValue {
                                flight.arrivalAirportId = airport.id
                                flight.arrivalAirport = airport
                            }
                        }
                    ),
                    time: flight.formattedInTime,
                    isEditing: isEditing,
                    database: database
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .onAppear {
            Task {
                departureAirport = database.getAirportByICAO(flight.departureAirportICAO)
                arrivalAirport = database.getAirportByICAO(flight.arrivalAirportICAO)
            }
        }
        .onChange(of: flight.departureAirportId) { newId in
            Task {
                if let airport = database.getAirportByICAO(flight.departureAirportICAO) {
                    flight.departureAirport = airport
                }
            }
        }
        .onChange(of: flight.arrivalAirportId) { newId in
            Task {
                if let airport = database.getAirportByICAO(flight.arrivalAirportICAO) {
                    flight.arrivalAirport = airport
                }
            }
        }
    }
}

#Preview {
    FlightAirportSection(
        flight: .constant(FlightDataService().generateMockFlights(count: 1)[0]),
        isEditing: false,
        database: LocalDatabase.shared
    )
}
