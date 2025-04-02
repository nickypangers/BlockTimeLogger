//
//  FlightDashboardView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import SwiftUI

struct FlightDashboardView: View {
    // Move all your existing HomeView content here
    @State private var showFlightSheet = false
    @State private var sheetHeight: CGFloat = 200
    @State private var fullHeight: CGFloat = 600
    @State private var isExpanded = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Flights")
                                .font(.title2)
                                .bold()

                            Text(Date(), style: .date)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        // Current flight card (static preview)
                        FlightLogOverview(
                            flightNumber: "CPA 123",
                            date: "20 MAR 2025",
                            aircraft: "B-KPM • B77W",
                            departure: "EDDF",
                            arrival: "VHHH",
                            duration: "11:06"
                        )
                        .padding()
                        .onTapGesture {
                            showFlightSheet = true
                        }

                        // Statistics section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Monthly Summary")
                                .font(.headline)

                            HStack {
                                StatisticCard(value: "42.5", label: "Block Hours", systemImage: "clock")
                                StatisticCard(value: "18", label: "Flights", systemImage: "airplane")
                            }

                            HStack {
                                StatisticCard(value: "12", label: "Landings", systemImage: "airplane.arrival")
                                StatisticCard(value: "6", label: "Night Hours", systemImage: "moon.stars")
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    }
                    .padding(.vertical)
                }

                // Bottom sheet overlay
                if showFlightSheet {
                    FlightLogSheet(
                        sheetHeight: $sheetHeight,
                        fullHeight: $fullHeight,
                        isExpanded: $isExpanded,
                        showFlightSheet: $showFlightSheet
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }

                // Add Flight Button (positioned above the sheet)
                if !showFlightSheet {
                    Button(action: { /* Add flight action */ }) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .shadow(radius: 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .navigationTitle("Flight Logger")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

// Move this outside HomeView, before the Preview
struct StatisticCard: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: systemImage)
                Text(value)
                    .font(.title3.bold())
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
    }
}

#Preview {
    FlightDashboardView()
}
