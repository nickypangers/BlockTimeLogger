//
//  AircraftListViewModel.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 10/5/2025.
//

import Foundation
import SwiftUI

final class AircraftListViewModel: ObservableObject {
  @Published var aircraft: [Aircraft] = []
  @Published var searchText = ""
  @Published var showDeleteConfirmation = false
  @Published var aircraftToDelete: Aircraft?
  @Published var showEditSheet = false
  @Published var editingAircraft: Aircraft?
  @Published var showError = false
  @Published var errorMessage = ""

  private let db = LocalDatabase.shared

  init() {
    loadAircraft()
  }

  func loadAircraft() {
    aircraft = db.getAllAircraft()
  }

  var filteredAircraft: [Aircraft] {
    if searchText.isEmpty {
      return aircraft
    } else {
      return aircraft.filter { aircraft in
        aircraft.registration.localizedCaseInsensitiveContains(searchText)
          || aircraft.type.localizedCaseInsensitiveContains(searchText)
      }
    }
  }

  func deleteAircraft(_ aircraft: Aircraft) {
    do {
      try db.deleteAircraft(aircraft)
      loadAircraft()
    } catch {
      errorMessage = "Error deleting aircraft: \(error.localizedDescription)"
      showError = true
    }
  }

  func updateAircraft(_ aircraft: Aircraft) {
    do {
      try db.updateAircraft(aircraft)
      loadAircraft()
    } catch {
      errorMessage = "Error updating aircraft: \(error.localizedDescription)"
      showError = true
    }
  }
}
