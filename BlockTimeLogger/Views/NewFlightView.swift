//
//  NewFlightView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//

import SwiftUI

struct NewFlightView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NewFlightViewModel()
    @StateObject var homeViewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    FlightHeaderSection(flight: $viewModel.flight, isEditing: true)
                    FlightAircraftSection(flight: $viewModel.flight, isEditing: true)
                    FlightAirportSection(flight: $viewModel.flight, isEditing: true, database: LocalDatabase.shared)
                    FlightTimelineSection(flight: $viewModel.flight, isEditing: true) { event in
                        handleTimelineEvent(event)
                    }
                    FlightTimeSummarySection(flight: viewModel.flight)
                    FlightNotesSection(flight: $viewModel.flight)
                }
                .padding(.vertical)
                .padding(.bottom, 50)
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("New Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems() }
            .sheet(item: $viewModel.activePicker) { _ in
                if let binding = viewModel.activePickerBinding {
                    DateTimePicker(selection: binding)
                }
            }
            .alert("Validation Error",
                   isPresented: $viewModel.showValidationAlert)
            {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.validationError {
                    Text(error.localizedDescription)
                } else {
                    Text("Please check all required fields are completed and times are in the correct sequence (OUT → OFF → ON → IN).")
                }
            }
        }
    }

    private func handleTimelineEvent(_ event: FlightTimelineSection.FlightEventType) {
        switch event {
        case .out: viewModel.activePicker = .out
        case .off: viewModel.activePicker = .off
        case .on: viewModel.activePicker = .on
        case .in: viewModel.activePicker = .in
        }
    }

    private func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if viewModel.saveFlight() {
                        homeViewModel.loadFlights()
                        dismiss()
                    }
                }
                .bold()
            }
        }
    }
}

#Preview {
    NewFlightView(homeViewModel: HomeViewModel())
}
