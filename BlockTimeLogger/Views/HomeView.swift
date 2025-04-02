//
//  HomeView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/3/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var sheetHeight: CGFloat = 200 // Height for single flight
    @State private var isExpanded = false

    // Sample flights data (sorted by date, newest first)
    @State private var flights: [Flight] = []

    private var latestFlight: Flight {
        flights.first ?? FlightDataService.shared.generateMockFlights(count: 10).first!
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        MonthlySummary()

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent Flights")
                                    .font(.title2)
                                    .bold()

                                Spacer()

                                Button("See All") {
                                    // Navigation to full flights list
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal)

                            // Flight Cards
                            ForEach(flights) { flight in
                                NavigationLink {
                                    FlightDetailView(flight: flight)
                                } label: {
                                    FlightLogOverview(flight: flight)
                                        .padding(.horizontal)
                                }.buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }

                // Always visible flight sheet
//                FlightLogSheet(
//                    flights: flights,
//                    sheetHeight: $sheetHeight,
//                    isExpanded: $isExpanded,
//                    initialHeight: 200 // Height for single flight display
//                )
//                .zIndex(1)

                // Add Flight Button
                Button(action: { /* Add flight action */ }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.blue))
                        .shadow(radius: 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
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
        .onAppear {
            flights = FlightDataService.shared.generateMockFlights(count: 5)
        }
    }
}

// Preview

#Preview {
    HomeView()
}
