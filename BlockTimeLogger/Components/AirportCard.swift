//
//  AirportCard.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import SwiftUI

struct AirportCard: View {
    let type: String
    @Binding var icao: String
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
                if icao.isEmpty {
                    Button(action: {
                        showingAirportSearch = true
                    }) {
                        HStack {
                            Text("Select")
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
                        Text(icao)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }
            } else {
                Text(icao)
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
            AirportSearchSheet(database: database) { selectedIcao in
                icao = selectedIcao
            }
        }
    }
}
