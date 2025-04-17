//
//  NewFlightViewModel.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import Foundation
import SwiftUI

final class NewFlightViewModel: ObservableObject {
    @Published var flight: Flight
    @Published var showValidationAlert = false
    @Published var activePicker: PickerType?
    
    // Time entry fields (HHmm format)
    @Published var enteredOutTime: String = ""
    @Published var enteredOffTime: String = ""
    @Published var enteredOnTime: String = ""
    @Published var enteredInTime: String = ""
    
    private let db = LocalDatabase.shared
    
    enum PickerType: Identifiable {
        case date, out, off, on, `in`
        var id: Self { self }
    }
    
    private let flightDataService: FlightDataServiceProtocol
    
    init(flightDataService: FlightDataServiceProtocol = FlightDataService.shared) {
        self.flightDataService = flightDataService
        self.flight = Flight.emptyFlight()
    }
    
    func saveFlight() -> Bool {
        print("NewFlightViewModel: Starting to save flight")
        
        // Convert entered times to UTC dates
        convertEnteredTimesToDates()
        print("NewFlightViewModel: Converted times to dates")
        
        // Normalize the times
        flight.normalizeTimes()
        print("NewFlightViewModel: Normalized times")
        
        print("NewFlightViewModel: Flight before saving: \(flight)")
        
        guard validateFlight() else {
            print("NewFlightViewModel: Flight validation failed")
            showValidationAlert = true
            return false
        }
        
        print("NewFlightViewModel: Flight validation passed, saving to database")
        
        do {
            try db.createFlight(flight)
            print("NewFlightViewModel: Successfully created flight in database: \(flight)")
            return true
        } catch {
            print("NewFlightViewModel: Error saving flight: \(error)")
            return false
        }
    }
    
    private func convertEnteredTimesToDates() {
        let utc = TimeZone(identifier: "UTC")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc!
        let flightDate = calendar.startOfDay(for: flight.date)
            
        // OUT Time (always same day)
        if let outTime = parseZuluTime(enteredOutTime) {
            flight.outTime = calendar.date(bySettingHour: outTime.hour,
                                           minute: outTime.minute,
                                           second: 0,
                                           of: flightDate) ?? flightDate
        }
            
        // OFF Time (check for +1)
        if let offTime = parseZuluTime(enteredOffTime) {
            let offDate = enteredOffTime.contains("+1") ?
                calendar.date(byAdding: .day, value: 1, to: flightDate)! :
                flightDate
            flight.offTime = calendar.date(bySettingHour: offTime.hour,
                                           minute: offTime.minute,
                                           second: 0,
                                           of: offDate) ?? offDate
        }
            
        // ON Time (check for +1)
        if let onTime = parseZuluTime(enteredOnTime) {
            let onDate = enteredOnTime.contains("+1") ?
                calendar.date(byAdding: .day, value: 1, to: flightDate)! :
                flightDate
            flight.onTime = calendar.date(bySettingHour: onTime.hour,
                                          minute: onTime.minute,
                                          second: 0,
                                          of: onDate) ?? onDate
        }
            
        // IN Time (check for +1)
        if let inTime = parseZuluTime(enteredInTime) {
            let inDate = enteredInTime.contains("+1") ?
                calendar.date(byAdding: .day, value: 1, to: flightDate)! :
                flightDate
            flight.inTime = calendar.date(bySettingHour: inTime.hour,
                                          minute: inTime.minute,
                                          second: 0,
                                          of: inDate) ?? inDate
        }
    }
    
    private func parseZuluTime(_ timeString: String) -> (hour: Int, minute: Int)? {
        let cleaned = timeString.replacingOccurrences(of: "z", with: "")
            .replacingOccurrences(of: "(+1)", with: "")
            .trimmingCharacters(in: .whitespaces)

        guard cleaned.count == 4,
              let hour = Int(cleaned.prefix(2)),
              let minute = Int(cleaned.suffix(2)),
              hour >= 0 && hour <= 23,
              minute >= 0 && minute <= 59
        else {
            return nil
        }
        return (hour, minute)
    }
    
    private func validateFlight() -> Bool {
        // Required fields
        guard !flight.flightNumber.isEmpty,
              !flight.aircraftRegistration.isEmpty,
              !flight.aircraftType.isEmpty,
              !flight.departureAirport.isEmpty,
              !flight.arrivalAirport.isEmpty
        else {
            return false
        }
        
        // PIC validation
        if !flight.isSelf && flight.pilotInCommand.isEmpty {
            return false
        }
        
        // Time validation
        return flight.validateTimes()
    }
    
    var activePickerBinding: Binding<Date>? {
        guard let picker = activePicker else { return nil }
        return Binding<Date>(
            get: {
                switch picker {
                case .date: return self.flight.date
                case .out: return self.flight.outTime
                case .off: return self.flight.offTime
                case .on: return self.flight.onTime
                case .in: return self.flight.inTime
                }
            },
            set: { newValue in
                switch picker {
                case .date: self.flight.date = newValue
                case .out: self.flight.outTime = newValue
                case .off: self.flight.offTime = newValue
                case .on: self.flight.onTime = newValue
                case .in: self.flight.inTime = newValue
                }
            }
        )
    }
}
