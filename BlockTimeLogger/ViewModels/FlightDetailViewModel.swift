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
  @Published var showValidationAlert = false
  @Published var validationError: ValidationError?

  // Time entry fields (HHmm format)
  @Published var enteredOutTime: String = ""
  @Published var enteredOffTime: String = ""
  @Published var enteredOnTime: String = ""
  @Published var enteredInTime: String = ""

  private let originalFlight: Flight
  private let flightDataService: FlightDataServiceProtocol
  private let db = LocalDatabase.shared

  enum ValidationError: LocalizedError {
    case missingFlightNumber
    case missingAircraftRegistration
    case missingAircraftType
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

  init(flight: Flight, flightDataService: FlightDataServiceProtocol = FlightDataService.shared) {
    self.originalFlight = flight
    self.draftFlight = flight
    self.flightDataService = flightDataService

    // Initialize entered times with formatted times from the flight
    self.enteredOutTime = draftFlight.formattedOutTime
    self.enteredOffTime = draftFlight.formattedOffTime
    self.enteredOnTime = draftFlight.formattedOnTime
    self.enteredInTime = draftFlight.formattedInTime
  }

  // MARK: - Public Methods

  func startEditing() {
    print("FDVM startEditing: initializing times")
    print("FDVM startEditing: original outTime = \(draftFlight.formattedOutTime)")
    print("FDVM startEditing: original offTime = \(draftFlight.formattedOffTime)")
    print("FDVM startEditing: original onTime = \(draftFlight.formattedOnTime)")
    print("FDVM startEditing: original inTime = \(draftFlight.formattedInTime)")

    // Initialize entered times with formatted times from the flight
    enteredOutTime = draftFlight.formattedOutTime
    enteredOffTime = draftFlight.formattedOffTime
    enteredOnTime = draftFlight.formattedOnTime
    enteredInTime = draftFlight.formattedInTime

    print("FDVM startEditing: initialized enteredOutTime = \(enteredOutTime)")
    print("FDVM startEditing: initialized enteredOffTime = \(enteredOffTime)")
    print("FDVM startEditing: initialized enteredOnTime = \(enteredOnTime)")
    print("FDVM startEditing: initialized enteredInTime = \(enteredInTime)")

    isEditing = true
  }

  func updateTime(_ time: Date, for eventType: FlightTimelineSection.FlightEventType) {
    print("FDVM updateTime: updating \(eventType) to \(time)")
    switch eventType {
    case .out:
      draftFlight.outTime = time
      enteredOutTime = draftFlight.formattedOutTime
    case .off:
      draftFlight.offTime = time
      enteredOffTime = draftFlight.formattedOffTime
    case .on:
      draftFlight.onTime = time
      enteredOnTime = draftFlight.formattedOnTime
    case .in:
      draftFlight.inTime = time
      enteredInTime = draftFlight.formattedInTime
    }
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
    // Convert entered times to UTC dates
    convertEnteredTimesToDates()

    if let error = validateFlight() {
      validationError = error
      showValidationAlert = true
      return false
    }

    print("FDVM saveFlight: \(draftFlight)")

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

      isEditing = false
      return true
    } catch {
      print("Error updating flight \(draftFlight.id): \(error)")
      return false
    }
  }

  // MARK: - Private Methods

  private func convertEnteredTimesToDates() {
    let utc = TimeZone(identifier: "UTC")
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc!
    let flightDate = calendar.startOfDay(for: draftFlight.date)

    print("FDVM convertEnteredTimesToDates: enteredOutTime = \(enteredOutTime)")
    print("FDVM convertEnteredTimesToDates: enteredOffTime = \(enteredOffTime)")
    print("FDVM convertEnteredTimesToDates: enteredOnTime = \(enteredOnTime)")
    print("FDVM convertEnteredTimesToDates: enteredInTime = \(enteredInTime)")

    // OUT Time (always same day)
    if let outTime = parseZuluTime(enteredOutTime) {
      print("FDVM convertEnteredTimesToDates: parsed outTime = \(outTime)")
      draftFlight.outTime =
        calendar.date(
          bySettingHour: outTime.hour,
          minute: outTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      print("FDVM convertEnteredTimesToDates: set outTime = \(draftFlight.outTime)")
    }

    // OFF Time
    if let offTime = parseZuluTime(enteredOffTime) {
      print("FDVM convertEnteredTimesToDates: parsed offTime = \(offTime)")
      let offDate =
        calendar.date(
          bySettingHour: offTime.hour,
          minute: offTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      draftFlight.offTime =
        offDate < draftFlight.outTime
        ? calendar.date(byAdding: .day, value: 1, to: offDate)! : offDate
      print("FDVM convertEnteredTimesToDates: set offTime = \(draftFlight.offTime)")
    }

    // ON Time
    if let onTime = parseZuluTime(enteredOnTime) {
      print("FDVM convertEnteredTimesToDates: parsed onTime = \(onTime)")
      let onDate =
        calendar.date(
          bySettingHour: onTime.hour,
          minute: onTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      draftFlight.onTime =
        onDate < draftFlight.offTime ? calendar.date(byAdding: .day, value: 1, to: onDate)! : onDate
      print("FDVM convertEnteredTimesToDates: set onTime = \(draftFlight.onTime)")
    }

    // IN Time
    if let inTime = parseZuluTime(enteredInTime) {
      print("FDVM convertEnteredTimesToDates: parsed inTime = \(inTime)")
      let inDate =
        calendar.date(
          bySettingHour: inTime.hour,
          minute: inTime.minute,
          second: 0,
          of: flightDate) ?? flightDate
      draftFlight.inTime =
        inDate < draftFlight.onTime ? calendar.date(byAdding: .day, value: 1, to: inDate)! : inDate
      print("FDVM convertEnteredTimesToDates: set inTime = \(draftFlight.inTime)")
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

  private func validateFlight() -> ValidationError? {
    // Required fields validation
    if draftFlight.flightNumber.isEmpty {
      return .missingFlightNumber
    }
    if draftFlight.aircraftRegistration.isEmpty {
      return .missingAircraftRegistration
    }
    if draftFlight.aircraftType.isEmpty {
      return .missingAircraftType
    }
    if draftFlight.departureAirportId == 0 {
      return .missingDepartureAirport
    }
    if draftFlight.arrivalAirportId == 0 {
      return .missingArrivalAirport
    }
    if !draftFlight.isSelf && draftFlight.pilotInCommand.isEmpty {
      return .missingPilotInCommand
    }

    // Time format validation
    if !isValidTimeFormat(enteredOutTime) || !isValidTimeFormat(enteredOffTime)
      || !isValidTimeFormat(enteredOnTime) || !isValidTimeFormat(enteredInTime)
    {
      return .invalidTimeFormat
    }

    // Time sequence validation
    let normalized = draftFlight.normalizedTimes()
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
