//
//  FlightDetailView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

// FlightDetailView.swift
import SwiftUI

struct FlightDetailView: View {
    @StateObject private var viewModel: FlightDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    init(flight: Flight) {
        _viewModel = StateObject(wrappedValue: FlightDetailViewModel(flight: flight))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FlightHeaderSection(flight: $viewModel.draftFlight, isEditing: viewModel.isEditing)
                FlightAircraftSection(flight: $viewModel.draftFlight, isEditing: viewModel.isEditing)
                FlightAirportSection(flight: $viewModel.draftFlight, isEditing: viewModel.isEditing, database: LocalDatabase.shared)
                FlightTimelineSection(
                    flight: $viewModel.draftFlight,
                    isEditing: viewModel.isEditing
                ) { event in
                    switch event {
                    case .out: viewModel.activePicker = .out
                    case .off: viewModel.activePicker = .off
                    case .on: viewModel.activePicker = .on
                    case .in: viewModel.activePicker = .in
                    }
                }
                .padding(.horizontal)
                FlightTimeSummarySection(flight: viewModel.draftFlight)

                if viewModel.isEditing {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Delete Flight")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.isEditing ? "Edit Flight" : "Flight Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelEditing()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        _ = viewModel.saveFlight()
                    }
                    .bold()
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.startEditing) {
                        Image(systemName: "pencil")
                            .padding(8)
                            .background(Circle().fill(Color.blue.opacity(0.1)))
                    }
                }
            }
        }
        .sheet(item: $viewModel.activePicker) { picker in
            DateTimePicker(selection: viewModel.bindingForPicker(picker))
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
        .confirmationDialog(
            "Delete Flight",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if viewModel.deleteFlight() {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this flight? This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        FlightDetailView(flight: FlightDataService.shared.generateMockFlights(count: 1).first!)
    }
}
