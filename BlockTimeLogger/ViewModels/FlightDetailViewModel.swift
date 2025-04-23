//
//  FlightDetailViewModel.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//

import SwiftUI

final class FlightDetailViewModel: ObservableObject {
    @Published var draftFlight: Flight
    @Published var isEditing = false
    @Published var activePicker: PickerType?
    @Published var showValidationAlert = false
    
    private let originalFlight: Flight
    private let flightDataService: FlightDataServiceProtocol
    private let db = LocalDatabase.shared
    
    enum PickerType: Identifiable {
        case date, out, off, on, `in`
        var id: Self { self }
    }
    
    init(flight: Flight, flightDataService: FlightDataServiceProtocol = FlightDataService.shared) {
        self.originalFlight = flight
        self.draftFlight = flight
        self.flightDataService = flightDataService
    }
    
    // MARK: - Public Methods
    
    func startEditing() {
        isEditing = true
    }
    
    func cancelEditing() {
        draftFlight = originalFlight
        isEditing = false
    }
    
    func deleteFlight() -> Bool {
        do {
            try db.deleteFlight(originalFlight)
            return true
        } catch {
            print("error deleting flight \(originalFlight.id): \(error)")
            return false
        }
    }
    
    func saveFlight() -> Bool {
        if validateTimes() && validateAirports() {
            isEditing = false
            do {
                // Update the flight in the database
                try db.updateFlight(draftFlight)
                
                // Update airport relationships
                if let departureAirport = draftFlight.departureAirport {
                    draftFlight.departureAirportId = departureAirport.id
                }
                if let arrivalAirport = draftFlight.arrivalAirport {
                    draftFlight.arrivalAirportId = arrivalAirport.id
                }
                
                return true
            } catch {
                print("Error updating flight \(draftFlight.id): \(error)")
                return false
            }
        } else {
            showValidationAlert = true
            return false
        }
    }
    
    func bindingForPicker(_ picker: PickerType) -> Binding<Date> {
        switch picker {
        case .date:
            return Binding(
                get: { self.draftFlight.date },
                set: { 
                    self.draftFlight.date = $0
                    // Normalize times after date change
                    self.draftFlight.normalizeTimes()
                }
            )
        case .out:
            return Binding(
                get: { self.draftFlight.outTime },
                set: { 
                    self.draftFlight.outTime = $0
                    // Normalize times after out time change
                    self.draftFlight.normalizeTimes()
                }
            )
        case .off:
            return Binding(
                get: { self.draftFlight.offTime },
                set: { 
                    self.draftFlight.offTime = $0
                    // Normalize times after off time change
                    self.draftFlight.normalizeTimes()
                }
            )
        case .on:
            return Binding(
                get: { self.draftFlight.onTime },
                set: { 
                    self.draftFlight.onTime = $0
                    // Normalize times after on time change
                    self.draftFlight.normalizeTimes()
                }
            )
        case .in:
            return Binding(
                get: { self.draftFlight.inTime },
                set: { 
                    self.draftFlight.inTime = $0
                    // Normalize times after in time change
                    self.draftFlight.normalizeTimes()
                }
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func validateTimes() -> Bool {
        // First normalize the times to ensure they're in the correct order
        draftFlight.normalizeTimes()
        
        // Then validate the order
        return draftFlight.outTime <= draftFlight.offTime &&
            draftFlight.offTime <= draftFlight.onTime &&
            draftFlight.onTime <= draftFlight.inTime
    }
    
    private func validateAirports() -> Bool {
        // Ensure both departure and arrival airports are set
        guard draftFlight.departureAirportId != 0,
              draftFlight.arrivalAirportId != 0 else {
            return false
        }
        
        // Ensure departure and arrival airports are different
        return draftFlight.departureAirportId != draftFlight.arrivalAirportId
    }
}
