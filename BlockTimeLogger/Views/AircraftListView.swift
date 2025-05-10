//
//  AircraftListView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 10/5/2025.
//

import SwiftUI

struct AircraftListView: View {
  @StateObject private var viewModel = AircraftListViewModel()
  @State private var showAddSheet = false

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Search bar
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
          TextField("Search aircraft", text: $viewModel.searchText)
            .textFieldStyle(.plain)
        }
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.secondarySystemBackground))
        )
        .padding()

        // Aircraft list
        List {
          ForEach(viewModel.filteredAircraft) { aircraft in
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text(aircraft.registration)
                  .font(.headline)
                Text(aircraft.type)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }

              Spacer()

              Menu {
                Button {
                  viewModel.editingAircraft = aircraft
                  viewModel.showEditSheet = true
                } label: {
                  Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                  viewModel.aircraftToDelete = aircraft
                  viewModel.showDeleteConfirmation = true
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              } label: {
                Image(systemName: "ellipsis.circle")
                  .foregroundColor(.secondary)
              }
            }
            .padding(.vertical, 4)
          }
        }
        .listStyle(.plain)
      }
      .navigationTitle("Aircrafts")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showAddSheet = true
          } label: {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showAddSheet) {
        AircraftEditSheet(aircraft: nil) { newAircraft in
          viewModel.loadAircraft()
        }
      }
      .sheet(isPresented: $viewModel.showEditSheet) {
        if let aircraft = viewModel.editingAircraft {
          AircraftEditSheet(aircraft: aircraft) { updatedAircraft in
            viewModel.updateAircraft(updatedAircraft)
          }
        }
      }
      .confirmationDialog(
        "Are you sure you want to delete this aircraft?",
        isPresented: $viewModel.showDeleteConfirmation,
        titleVisibility: .visible
      ) {
        if let aircraft = viewModel.aircraftToDelete {
          Button("Delete", role: .destructive) {
            viewModel.deleteAircraft(aircraft)
          }
        }
        Button("Cancel", role: .cancel) {}
      } message: {
        if let aircraft = viewModel.aircraftToDelete {
          Text("This will permanently delete \(aircraft.registration).")
        }
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(viewModel.errorMessage)
      }
    }
  }
}

struct AircraftEditSheet: View {
  @Environment(\.dismiss) private var dismiss
  let aircraft: Aircraft?
  let onSave: (Aircraft) -> Void

  @State private var registration: String
  @State private var type: String
  @State private var showError = false
  @State private var errorMessage = ""

  private let db = LocalDatabase.shared

  init(aircraft: Aircraft?, onSave: @escaping (Aircraft) -> Void) {
    self.aircraft = aircraft
    self.onSave = onSave
    _registration = State(initialValue: aircraft?.registration ?? "")
    _type = State(initialValue: aircraft?.type ?? "")
  }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Registration", text: $registration)
            .textInputAutocapitalization(.characters)
          TextField("Type", text: $type)
            .textInputAutocapitalization(.characters)
        }
      }
      .navigationTitle(aircraft == nil ? "Add Aircraft" : "Edit Aircraft")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            saveAircraft()
          }
        }
      }
      .alert("Error", isPresented: $showError) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
    }
  }

  private func saveAircraft() {
    guard !registration.isEmpty else {
      errorMessage = "Registration is required"
      showError = true
      return
    }

    guard !type.isEmpty else {
      errorMessage = "Type is required"
      showError = true
      return
    }

    // Check if registration already exists (for new aircraft)
    if aircraft == nil {
      if db.getAircraftByRegistration(registration) != nil {
        errorMessage = "Aircraft with registration \(registration) already exists"
        showError = true
        return
      }
    }

    do {
      if let existingAircraft = aircraft {
        // Update existing aircraft
        var updatedAircraft = existingAircraft
        updatedAircraft.registration = registration
        updatedAircraft.type = type
        try db.updateAircraft(updatedAircraft)
        onSave(updatedAircraft)
      } else {
        // Create new aircraft
        let newAircraft = Aircraft(registration: registration, type: type)
        let createdAircraft = try db.createAircraft(newAircraft)
        onSave(createdAircraft)
      }
      dismiss()
    } catch {
      errorMessage = "Error saving aircraft: \(error.localizedDescription)"
      showError = true
    }
  }
}

#Preview {
  AircraftListView()
}
