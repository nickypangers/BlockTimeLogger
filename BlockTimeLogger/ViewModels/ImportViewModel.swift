import Foundation
import SwiftUI

final class ImportViewModel: ObservableObject {
    @Published var isImporting = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var logText: String = ""
    @Published var importedCount = 0
    @Published var flights: [Flight] = []
    @Published var selectedFlight: Flight?
    @Published var showImportConfirmation = false
    
    private let importService = ImportService.shared
    private let db = LocalDatabase.shared
    
    func parseAndMatchFlights() -> Bool {
        isImporting = true
        
        // Parse flights using ImportService
        flights = importService.importFlights(from: logText)
        
        if flights.isEmpty {
            errorMessage = "No valid flights found in the provided data"
            showError = true
            isImporting = false
            return false
        }
        
        // Match airport IDs for each flight
        do {
            for i in 0 ..< flights.count {
                // Get departure airport
                if let departureAirport = try LocalDatabase.shared.getAirportByCode(flights[i].departureAirportICAO) {
                    flights[i].departureAirport = departureAirport
                    flights[i].departureAirportId = departureAirport.id
                }
                
                // Get arrival airport
                if let arrivalAirport = try LocalDatabase.shared.getAirportByCode(flights[i].arrivalAirportICAO) {
                    flights[i].arrivalAirport = arrivalAirport
                    flights[i].arrivalAirportId = arrivalAirport.id
                }
            }
            isImporting = false
            return true
        } catch {
            errorMessage = "Error matching airports: \(error.localizedDescription)"
            showError = true
            isImporting = false
            return false
        }
    }
    
    func importFlights(homeViewModel: HomeViewModel) -> Bool {
        isImporting = true
        
        do {
            for flight in flights {
                try db.createFlight(flight)
                importedCount += 1
            }
            homeViewModel.loadFlights()
            isImporting = false
            return true
        } catch {
            errorMessage = "Error importing flights: \(error.localizedDescription)"
            showError = true
            isImporting = false
            return false
        }
    }
    
    func updateFlight(_ flight: Flight) {
        if let index = flights.firstIndex(where: { $0.id == flight.id }) {
            flights[index] = flight
        }
    }
    
    func reset() {
        logText = ""
        flights = []
        selectedFlight = nil
        importedCount = 0
        isImporting = false
        showError = false
        errorMessage = ""
        showImportConfirmation = false
    }
}
