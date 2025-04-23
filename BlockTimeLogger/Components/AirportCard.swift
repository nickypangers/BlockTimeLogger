//
//  AirportCard.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import SwiftUI

struct AirportCard: View {
    let type: String
    @Binding var airport: Airport?
    let time: String
    let isEditing: Bool
    let database: LocalDatabase
    @State private var showingAirportSearch = false

    var body: some View {
        VStack(spacing: 8) {
            Text(type)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)

            if isEditing {
                if airport == nil {
                    Button(action: {
                        showingAirportSearch = true
                    }) {
                        HStack {
                            Text("-")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Button(action: {
                        showingAirportSearch = true
                    }) {
                        Text(airport == nil ? "Airport not found" : airport!.icao)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }
            } else {
                Text(airport == nil ? "Airport not found" : airport!.icao)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }

            Text(time)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .sheet(isPresented: $showingAirportSearch) {
            AirportSearchSheet(database: database) { selectedAirport in
                airport = selectedAirport
            }
        }
    }
}
