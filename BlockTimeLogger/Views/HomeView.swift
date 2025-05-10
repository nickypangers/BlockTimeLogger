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
  @State private var showClearConfirmation = false

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
              ImportLogbookView(homeViewModel: viewModel)
            } label: {
              Label("Import", systemImage: "square.and.arrow.down")
            }
            // NavigationLink {
            //     ExportLogbookView()
            // } label: {
            //     Label("Export", systemImage: "square.and.arrow.up")
            // }
            NavigationLink {
              SettingsView()
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
      .confirmationDialog(
        "Are you sure you want to clear all flights?",
        isPresented: $showClearConfirmation,
        titleVisibility: .visible
      ) {
        Button("Clear All", role: .destructive) {
          for flight in viewModel.flights {
            do {
              try LocalDatabase.shared.deleteFlight(flight)
            } catch {
              print("error: \(error)")
              break
            }
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("This action cannot be undone.")
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
      AddEntryView(homeViewModel: viewModel)
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
