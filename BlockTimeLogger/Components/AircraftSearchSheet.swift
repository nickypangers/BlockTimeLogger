import SwiftUI

struct AircraftSearchSheet: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var selectedAircraft: Aircraft?
  @State private var searchText = ""
  @State private var registration = ""
  @State private var type = ""
  @State private var showError = false
  @State private var errorMessage = ""

  private let db = LocalDatabase.shared

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        // Search field
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
          TextField("Search aircraft", text: $searchText)
            .textFieldStyle(.plain)
        }
        .padding(8)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)

        // Aircraft list
        List {
          ForEach(filteredAircraft) { aircraft in
            Button {
              selectAircraft(aircraft)
            } label: {
              HStack {
                VStack(alignment: .leading) {
                  Text("\(aircraft.registration)")
                    .font(.headline)
                  Text(aircraft.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()
                if selectedAircraft?.id == aircraft.id {
                  Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                }
              }
            }
          }
        }
        .listStyle(.plain)

        // Add new aircraft section
        VStack(alignment: .leading, spacing: 12) {
          Text("Add New Aircraft")
            .font(.headline)
            .padding(.horizontal)

          VStack(alignment: .leading, spacing: 8) {
            Text("REGISTRATION")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color(.systemGray))
            TextField("N12345", text: $registration)
              .aviationInputStyle()
              .font(.system(size: 16, weight: .medium))
              .padding(.vertical, 8)
              .padding(.horizontal, 12)
              .background(
                RoundedRectangle(cornerRadius: 6)
                  .strokeBorder(Color(.systemGray4), lineWidth: 1)
              )
          }
          .padding(.horizontal)

          VStack(alignment: .leading, spacing: 8) {
            Text("TYPE")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color(.systemGray))
            TextField("B77W", text: $type)
              .aviationInputStyle()
              .font(.system(size: 16, weight: .medium))
              .padding(.vertical, 8)
              .padding(.horizontal, 12)
              .background(
                RoundedRectangle(cornerRadius: 6)
                  .strokeBorder(Color(.systemGray4), lineWidth: 1)
              )
          }
          .padding(.horizontal)

          Button {
            createNewAircraft()
          } label: {
            Text("Add Aircraft")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.accentColor)
              .foregroundColor(.white)
              .cornerRadius(10)
          }
          .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground))
      }
      .navigationTitle("Select Aircraft")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Cancel") {
            dismiss()
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

  private var filteredAircraft: [Aircraft] {
    if searchText.isEmpty {
      return db.getAllAircraft()
    } else {
      return db.getAllAircraft().filter { aircraft in
        aircraft.registration.localizedCaseInsensitiveContains(searchText)
          || aircraft.type.localizedCaseInsensitiveContains(searchText)
      }
    }
  }

  private func selectAircraft(_ aircraft: Aircraft) {
    selectedAircraft = aircraft
    dismiss()
  }

  private func createNewAircraft() {
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

    // Check if aircraft already exists
    if db.getAircraftByRegistration(registration) != nil {
      errorMessage = "Aircraft with registration \(registration) already exists"
      showError = true
      return
    }

    // Create new aircraft
    let newAircraft = Aircraft(registration: registration, type: type)
    do {
      let createdAircraft = try db.createAircraft(newAircraft)
      selectAircraft(createdAircraft)
    } catch {
      errorMessage = "Error creating aircraft: \(error.localizedDescription)"
      showError = true
    }
  }
}

#Preview {
  AircraftSearchSheet(selectedAircraft: .constant(nil))
}
