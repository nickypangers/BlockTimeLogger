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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AIRPORTS")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(flight)")

            HStack(spacing: 16) {
                AirportCard(
                    type: "DEPARTURE",
                    icao: $flight.departureAirport,
                    time: flight.formattedOutTime,
                    isEditing: isEditing
                )

                AirportCard(
                    type: "ARRIVAL",
                    icao: $flight.arrivalAirport,
                    time: flight.formattedInTime,
                    isEditing: isEditing
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

#Preview {
    FlightAirportSection(flight: .constant(FlightDataService().generateMockFlights(count: 1)[0]), isEditing: false)
}
