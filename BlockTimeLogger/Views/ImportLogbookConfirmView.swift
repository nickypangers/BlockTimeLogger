//
//  ImportLogbookConfirmView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 25/4/2025.
//

import SwiftUI

struct ImportLogbookConfirmView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var homeViewModel: HomeViewModel
    @ObservedObject var importViewModel: ImportViewModel

    init(flights: [Flight], homeViewModel: HomeViewModel, importViewModel: ImportViewModel) {
        _homeViewModel = StateObject(wrappedValue: homeViewModel)
        _importViewModel = ObservedObject(wrappedValue: importViewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(importViewModel.flights.sorted { $0.date > $1.date }) { flight in
                    FlightLogOverview(flight: flight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            importViewModel.selectedFlight = flight
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .background(Color.clear)
            .navigationTitle("Confirm Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        importViewModel.showImportConfirmation = true
                    }
                    .disabled(importViewModel.flights.isEmpty)
                }
            }
            .sheet(item: $importViewModel.selectedFlight) { flight in
                NavigationStack {
                    FlightDetailView(flight: flight)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    importViewModel.updateFlight(flight)
                                    importViewModel.selectedFlight = nil
                                }
                            }
                        }
                }
            }
            .alert("Import Flights", isPresented: $importViewModel.showImportConfirmation) {
                Button("Import", role: .destructive) {
                    importFlights()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to import \(importViewModel.flights.count) flights?")
            }
            .alert("Import Error", isPresented: $importViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importViewModel.errorMessage)
            }
        }
        .onAppear {
            print(importViewModel.flights)
        }
    }

    private func importFlights() {
        if importViewModel.importFlights(homeViewModel: homeViewModel) {
            dismiss()
        }
    }
}

#Preview {
    ImportLogbookConfirmView(
        flights: FlightDataService.shared.generateMockFlights(count: 3),
        homeViewModel: HomeViewModel(),
        importViewModel: ImportViewModel()
    )
}
