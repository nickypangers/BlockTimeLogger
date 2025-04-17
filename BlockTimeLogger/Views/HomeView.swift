//
//  HomeView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/3/2025.
//
import SwiftUI

// MARK: - View

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        TimeSummary(
                            monthlyMetrics: viewModel.monthlyMetrics,
                            allTimeMetrics: viewModel.allTimeMetrics
                        )
                        
                        recentFlightsSection()
                    }
                    .padding(.vertical)
                }
                
                // Add Flight Button
                addFlightButton()
            }
            .navigationTitle("Summary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
   
                    Menu {
                                          NavigationLink {
                        ExportLogbookView()
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        NavigationLink {
//                            SeeAllFlightsView(flights: viewModel.flights)
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(Color("SkyBlue"))
                    }
                }
            }
        }
    }
    
    // MARK: Subviews

    private func recentFlightsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Flights")
                    .font(.title2.bold())
                
                Spacer()
                
                NavigationLink("See All") {
                    FlightListView(flights: viewModel.flights)
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
            
            // Ensure flights are ordered by outTime in descending order
            ForEach(viewModel.flights.sorted(by: { $0.outTime > $1.outTime }).prefix(5)) { flight in
                NavigationLink {
                    FlightDetailView(flight: flight)
                } label: {
                    FlightLogOverview(flight: flight)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
    }
    
    private func addFlightButton() -> some View {
        NavigationLink {
            NewFlightView(homeViewModel: viewModel)
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color("SkyBlue")))
                .shadow(radius: 4)
        }
        .padding()
    }
}

// Preview

#Preview {
    HomeView()
}
