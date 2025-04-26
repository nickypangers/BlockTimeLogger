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
    @Published var columnMapping: ImportColumnMapping
    @Published var sampleRow: [String] = []
    @Published var showColumnMapping = false
    @Published var importError: String?
    
    init() {
        self.columnMapping = ImportColumnMappingManager.shared.loadMapping()
    }
    
    var isMappingValid: Bool {
        columnMapping.isValid()
    }
    
    private let importService = ImportService.shared
    private let db = LocalDatabase.shared
    
    func parseAndMatchFlights() -> Bool {
        isImporting = true
        
        // Parse flights using ImportService
        flights = importService.importFlights(from: logText, columnMapping: columnMapping)
        
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
        columnMapping = ImportColumnMappingManager.shared.loadMapping()
        sampleRow = []
        showColumnMapping = false
    }
    
    func extractSampleRow() {
        let lines = logText.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .filter { !$0.contains("Sector") }
            .filter { !$0.contains("----") }
            .filter { !$0.contains("Report Date") }
            .filter { !$0.contains("Log Book record") }
        
        guard let firstLine = lines.first else { return }
        
        sampleRow = firstLine.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
    }
    
    func parseSampleRow(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        guard let firstLine = lines.first else { return }
        
        // Split the line by tabs or commas
        let components = firstLine.components(separatedBy: CharacterSet(charactersIn: "\t,"))
        sampleRow = components.map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Try to auto-detect column mapping
        autoDetectColumnMapping()
    }
    
    func autoDetectColumnMapping() {
        for (index, value) in sampleRow.enumerated() {
            let lowercasedValue = value.lowercased()
            
            // Try to match column names
            if lowercasedValue.contains("date") {
                columnMapping.setColumnIndex(for: .date, index: index)
            } else if lowercasedValue.contains("flight") {
                columnMapping.setColumnIndex(for: .flightNumber, index: index)
            } else if lowercasedValue.contains("dep") || lowercasedValue.contains("from") {
                columnMapping.setColumnIndex(for: .departureAirport, index: index)
            } else if lowercasedValue.contains("arr") || lowercasedValue.contains("to") {
                columnMapping.setColumnIndex(for: .arrivalAirport, index: index)
            } else if lowercasedValue.contains("reg") || lowercasedValue.contains("tail") {
                columnMapping.setColumnIndex(for: .aircraftRegistration, index: index)
            } else if lowercasedValue.contains("out") {
                columnMapping.setColumnIndex(for: .outTime, index: index)
            } else if lowercasedValue.contains("off") {
                columnMapping.setColumnIndex(for: .offTime, index: index)
            } else if lowercasedValue.contains("on") {
                columnMapping.setColumnIndex(for: .onTime, index: index)
            } else if lowercasedValue.contains("in") {
                columnMapping.setColumnIndex(for: .inTime, index: index)
            } else if lowercasedValue.contains("pic") || lowercasedValue.contains("captain") {
                columnMapping.setColumnIndex(for: .pic, index: index)
            }
        }
    }
    
    func importFlights(_ text: String) async {
        isImporting = true
        importError = nil
        
        do {
            let flights = importService.importFlights(from: text, columnMapping: columnMapping)
            try LocalDatabase.shared.createMultipleFlights(flights)
        } catch {
            importError = error.localizedDescription
        }
        
        isImporting = false
    }
    
    func updateColumnMapping(_ newMapping: ImportColumnMapping) {
        columnMapping = newMapping
        ImportColumnMappingManager.shared.saveMapping(newMapping)
    }
    
    func resetColumnMapping() {
        columnMapping = ImportColumnMapping()
        ImportColumnMappingManager.shared.resetToDefault()
    }
}
