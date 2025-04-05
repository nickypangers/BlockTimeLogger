//
//  FlightTimeSummarySection.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 6/4/2025.
//

import SwiftUI

struct FlightTimeSummarySection: View {
    var flight: Flight

    var body: some View {
        VStack(spacing: 16) {
            Text("TIME SUMMARY")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 16) {
                TimeCard(
                    title: "BLOCK TIME",
                    value: flight.formattedBlockTime,
                    icon: "clock",
                    color: .blue
                )
                TimeCard(
                    title: "FLIGHT TIME",
                    value: flight.formattedFlightTime,
                    icon: "airplane",
                    color: .green
                )
            }

            HStack(spacing: 16) {
                TimeCard(
                    title: "TAXI OUT",
                    value: flight.formattedTaxiOutTime,
                    icon: "arrow.up",
                    color: .orange
                )
                TimeCard(
                    title: "TAXI IN",
                    value: flight.formattedTaxiInTime,
                    icon: "arrow.down",
                    color: .purple
                )
            }
        }
        .padding(.horizontal)
    }
}

struct TimeCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(color)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

#Preview {
    FlightTimeSummarySection(flight: FlightDataService().generateMockFlights(count: 1)[0])
}
