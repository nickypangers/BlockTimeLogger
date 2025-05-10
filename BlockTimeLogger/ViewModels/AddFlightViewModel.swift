//
//  AddFlightViewModel.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import Foundation
import SwiftUI

final class AddFlightViewModel: ObservableObject {
  @Published var flight: Flight
  @Published var showValidationAlert = false
  @Published var validationError: ValidationError?
  @Published var aircraftRegistration: String = ""
  @Published var aircraftType: String = ""
  @Published var showAircraftError = false
  @Published var aircraftErrorMessage = ""

  // Time entry fields (HHmm format)
  @Published var enteredOutTime: String = ""
  @Published var enteredOffTime: String = ""
  @Published var enteredOnTime: String = ""
  @Published var enteredInTime: String = ""

  private let db = LocalDatabase.shared

  enum ValidationError: LocalizedError {
    case missingFlightNumber
    case missingAircraftRegistration
    case missingAircraftType
    case missingAircraft
    case missingDepartureAirport
    case missingArrivalAirport
    case missingPilotInCommand
    case invalidTimeSequence
    case invalidTimeFormat
    case invalidBlockTime
    case invalidFlightTime
    case invalidTaxiTime

    var errorDescription: String? {
      switch self {
      case .missingFlightNumber:
        return "Flight number is required"
      case .missingAircraftRegistration:
        return "Aircraft registration is required"
      case .missingAircraftType:
        return "Aircraft type is required"
      case .missingAircraft:
        return "Aircraft is required"
      case .missingDepartureAirport:
        return "Departure airport is required"
      case .missingArrivalAirport:
        return "Arrival airport is required"
      case .missingPilotInCommand:
        return "Pilot in Command name is required when not self"
      case .invalidTimeSequence:
        return "Times must follow: OUT → OFF → ON → IN"
      case .invalidTimeFormat:
        return "Time must be in HHmm format (e.g., 1230z)"
      case .invalidBlockTime:
        return "Block time must be at least 1 minute"
      case .invalidFlightTime:
        return "Flight time must be at least 1 minute"
      case .invalidTaxiTime:
        return "Taxi times cannot be negative"
      }
    }
  }

  private let flightDataService: FlightDataServiceProtocol

  init(flightDataService: FlightDataServiceProtocol = FlightDataService.shared) {
    self.flightDataService = flightDataService
    self.flight = Flight.emptyFlight()

    // Initialize entered times with formatted times from the flight
    self.enteredOutTime = flight.formattedOutTime
    self.enteredOffTime = flight.formattedOffTime
    self.enteredOnTime = flight.formattedOnTime
    self.enteredInTime = flight.formattedInTime
  }

  func updateTime(_ time: Date, for eventType: FlightTimelineSection.FlightEventType) {
    print("AFVM updateTime: updating \(eventType) to \(time)")
    switch eventType {
    case .out:
      flight.outTime = time
      enteredOutTime = flight.formattedOutTime
    case .off:
      flight.offTime = time
      enteredOffTime = flight.formattedOffTime
    case .on:
      flight.onTime = time
      enteredOnTime = flight.formattedOnTime
    case .in:
      flight.inTime = time
      enteredInTime = flight.formattedInTime
    }
  }

  func saveFlight() -> Bool {
    print("AddFlightViewModel: Starting to save flight")

    // Convert entered times to UTC dates
    convertEnteredTimesToDates()
    print("AddFlightViewModel: Converted times to dates")

    print("AddFlightViewModel: Flight before saving: \(flight)")

    if let error = validateFlight() {
      print("AddFlightViewModel: Flight validation failed: \(error.localizedDescription)")
      validationError = error
      showValidationAlert = true
      return false
    }

    print("AddFlightViewModel: Flight validation passed, saving to database")

    do {
      try db.createFlight(flight)
      print("AddFlightViewModel: Successfully created flight in database: \(flight)")
      return true
    } catch {
      print("AddFlightViewModel: Error saving flight: \(error)")
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
      flight.outTime =
        calendar.date(
          bySettingHour: outTime.hour,
          minute: outTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
    }

    // OFF Time
    if let offTime = parseZuluTime(enteredOffTime) {
      let offDate =
        calendar.date(
          bySettingHour: offTime.hour,
          minute: offTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      flight.offTime =
        offDate < flight.outTime ? calendar.date(byAdding: .day, value: 1, to: offDate)! : offDate
    }

    // ON Time
    if let onTime = parseZuluTime(enteredOnTime) {
      let onDate =
        calendar.date(
          bySettingHour: onTime.hour,
          minute: onTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      flight.onTime =
        onDate < flight.offTime ? calendar.date(byAdding: .day, value: 1, to: onDate)! : onDate
    }

    // IN Time
    if let inTime = parseZuluTime(enteredInTime) {
      let inDate =
        calendar.date(
          bySettingHour: inTime.hour,
          minute: inTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      flight.inTime =
        inDate < flight.onTime ? calendar.date(byAdding: .day, value: 1, to: inDate)! : inDate
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

  func handleAircraftChange() {
    // Check if aircraft exists in database
    if let existingAircraft = db.getAircraftByRegistration(aircraftRegistration) {
      // If type matches, use existing aircraft
      if existingAircraft.type == aircraftType {
        flight.aircraft = existingAircraft
        flight.aircraftId = existingAircraft.id
        showAircraftError = false
      } else {
        // Type doesn't match, show error
        aircraftErrorMessage = "Aircraft registration exists with different type"
        showAircraftError = true
        flight.aircraft = nil
        flight.aircraftId = -1
      }
    } else {
      // Create new aircraft
      let newAircraft = Aircraft(registration: aircraftRegistration, type: aircraftType)
      do {
        let createdAircraft = try db.createAircraft(newAircraft)
        flight.aircraft = createdAircraft
        flight.aircraftId = createdAircraft.id
        showAircraftError = false
      } catch {
        aircraftErrorMessage = "Error creating aircraft: \(error.localizedDescription)"
        showAircraftError = true
        flight.aircraft = nil
        flight.aircraftId = -1
      }
    }
  }

  private func validateFlight() -> ValidationError? {
    // Required fields validation
    if flight.flightNumber.isEmpty {
      return .missingFlightNumber
    }

    // Aircraft validation
    if flight.aircraftId <= 0 || flight.aircraft == nil {
      return .missingAircraft
    }

    // Airport validation
    if flight.departureAirportId <= 0 {
      return .missingDepartureAirport
    }
    if flight.arrivalAirportId <= 0 {
      return .missingArrivalAirport
    }

    // PIC validation
    if !flight.isSelf && flight.pilotInCommand.isEmpty {
      return .missingPilotInCommand
    }

    // Time format validation
    if !isValidTimeFormat(enteredOutTime) || !isValidTimeFormat(enteredOffTime)
      || !isValidTimeFormat(enteredOnTime) || !isValidTimeFormat(enteredInTime)
    {
      return .invalidTimeFormat
    }

    // Time sequence validation
    let normalized = flight.normalizedTimes()
    if normalized.outTime > normalized.offTime || normalized.offTime > normalized.onTime
      || normalized.onTime > normalized.inTime
    {
      return .invalidTimeSequence
    }

    // Duration validation
    let blockDuration = normalized.inTime.timeIntervalSince(normalized.outTime)
    let flightDuration = normalized.onTime.timeIntervalSince(normalized.offTime)
    let taxiOutDuration = normalized.offTime.timeIntervalSince(normalized.outTime)
    let taxiInDuration = normalized.inTime.timeIntervalSince(normalized.onTime)

    if blockDuration < 60 {
      return .invalidBlockTime
    }
    if flightDuration < 60 {
      return .invalidFlightTime
    }
    if taxiOutDuration < 0 || taxiInDuration < 0 {
      return .invalidTaxiTime
    }

    return nil
  }

  private func isValidTimeFormat(_ timeString: String) -> Bool {
    // Remove z suffix and (+1) notation
    let cleaned = timeString.replacingOccurrences(of: "z", with: "")
      .replacingOccurrences(of: "(+1)", with: "")
      .trimmingCharacters(in: .whitespaces)

    // Check if we have exactly 4 digits
    guard cleaned.count == 4 else {
      return false
    }

    // Check if all characters are digits
    guard cleaned.allSatisfy({ $0.isNumber }) else {
      return false
    }

    // Parse hours and minutes
    guard let hour = Int(cleaned.prefix(2)),
      let minute = Int(cleaned.suffix(2)),
      hour >= 0 && hour <= 23,
      minute >= 0 && minute <= 59
    else {
      return false
    }

    return true
  }
}
