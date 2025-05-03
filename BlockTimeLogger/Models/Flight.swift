import Foundation
import GRDB
import SwiftUI

struct Flight: Identifiable, Codable {
  // MARK: - Stored Properties

  var id: UUID
  var flightNumber: String
  var date: Date
  var aircraftRegistration: String
  var aircraftType: String
  var operatingCapacity: OperatingCapacity
  var departureAirportId: Int
  var arrivalAirportId: Int
  var pilotInCommand: String
  var isSelf: Bool
  var isPF: Bool
  var isIFR: Bool
  var isVFR: Bool
  var position: Position
  private var storedOutTime: Date
  private var storedOffTime: Date
  private var storedOnTime: Date
  private var storedInTime: Date
  var notes: String?
  var userId: Int64

  // MARK: - Relationships

  var departureAirport: Airport?
  var arrivalAirport: Airport?

  // MARK: - Static Properties

  static let utcCalendar: Calendar = {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }()

  // MARK: - Enums

  enum Position: String, CaseIterable, Codable {
    case captain = "CN"
    case firstOfficer = "FO"
    case secondOfficer = "SO"
  }

  // MARK: - Computed Properties

  // Time properties with proper getters and setters
  var outTime: Date {
    get { storedOutTime }
    set { storedOutTime = newValue }
  }

  var offTime: Date {
    get { storedOffTime }
    set { storedOffTime = newValue }
  }

  var onTime: Date {
    get { storedOnTime }
    set { storedOnTime = newValue }
  }

  var inTime: Date {
    get { storedInTime }
    set { storedInTime = newValue }
  }

  //    // Backward compatibility properties
  //    var departureAirport: String {
  //        get {
  //            // This will be replaced with a join query in the database layer
  //            return ""
  //        }
  //        set { } // No-op for backward compatibility
  //    }
  //
  //    var arrivalAirport: String {
  //        get {
  //            // This will be replaced with a join query in the database layer
  //            return ""
  //        }
  //        set { } // No-op for backward compatibility
  //    }

  var sector: Int { 1 }  // Each flight counts as 1 sector

  var departureAirportICAO: String {
    departureAirport?.icao ?? ""
  }

  var arrivalAirportICAO: String {
    arrivalAirport?.icao ?? ""
  }

  // MARK: - Time Calculations

  var blockTime: TimeInterval {
    let normalized = normalizedTimes()
    return normalized.inTime.timeIntervalSince(normalized.outTime)
  }

  var flightTime: TimeInterval {
    let normalized = normalizedTimes()
    return normalized.onTime.timeIntervalSince(normalized.offTime)
  }

  var taxiOutTime: TimeInterval {
    let normalized = normalizedTimes()
    return normalized.offTime.timeIntervalSince(normalized.outTime)
  }

  var taxiInTime: TimeInterval {
    let normalized = normalizedTimes()
    return normalized.inTime.timeIntervalSince(normalized.onTime)
  }

  // MARK: - Formatted Display

  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "dd MMM yyyy"
    return formatter.string(from: date)
  }

  var formattedOutTime: String { formatZuluTime(outTime) }
  var formattedOffTime: String { formatZuluTime(offTime, reference: outTime) }
  var formattedOnTime: String { formatZuluTime(onTime, reference: outTime) }
  var formattedInTime: String { formatZuluTime(inTime, reference: outTime) }

  var formattedBlockTime: String { formatHoursMinutes(blockTime) }
  var formattedFlightTime: String { formatHoursMinutes(flightTime) }
  var formattedTaxiOutTime: String { formatHoursMinutes(taxiOutTime) }
  var formattedTaxiInTime: String { formatHoursMinutes(taxiInTime) }

  // MARK: - Tags

  var tags: [FlightTag] {
    var tags: [FlightTag] = [.pic]

    if isPF { tags.append(.pf) }
    if isIFR { tags.append(.ifr) }
    if isVFR { tags.append(.vfr) }

    switch position {
    case .captain: tags.append(.captain)
    case .firstOfficer: tags.append(.firstOfficer)
    case .secondOfficer: tags.append(.secondOfficer)
    }

    return tags
  }

  // MARK: - Initialization

  init(
    id: UUID,
    flightNumber: String,
    date: Date,
    aircraftRegistration: String,
    aircraftType: String,
    departureAirportId: Int,
    arrivalAirportId: Int,
    pilotInCommand: String,
    isSelf: Bool,
    isPF: Bool,
    isIFR: Bool,
    isVFR: Bool,
    position: Position,
    operatingCapacity: OperatingCapacity,
    outTime: Date,
    offTime: Date,
    onTime: Date,
    inTime: Date,
    notes: String?,
    userId: Int64
  ) {
    self.id = id
    self.flightNumber = flightNumber
    self.date = date
    self.aircraftRegistration = aircraftRegistration
    self.aircraftType = aircraftType
    self.departureAirportId = departureAirportId
    self.arrivalAirportId = arrivalAirportId
    self.pilotInCommand = pilotInCommand
    self.isSelf = isSelf
    self.isPF = isPF
    self.isIFR = isIFR
    self.isVFR = isVFR
    self.position = position
    self.operatingCapacity = operatingCapacity
    self.storedOutTime = outTime
    self.storedOffTime = offTime
    self.storedOnTime = onTime
    self.storedInTime = inTime
    self.notes = notes
    self.userId = userId
  }

  // MARK: - Helper Methods

  private func formatZuluTime(_ time: Date, reference: Date? = nil) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "HHmm"
    let timeString = formatter.string(from: time) + "z"

    if let reference = reference, time < reference {
      return timeString + " (+1)"
    }
    return timeString
  }

  private func formatHoursMinutes(_ interval: TimeInterval) -> String {
    let hours = Int(interval) / 3600
    let minutes = (Int(interval) % 3600) / 60
    return String(format: "%d:%02d", hours, minutes)
  }

  private func adjustedTime(_ time: Date, reference: Date) -> Date {
    time < reference ? time.addingTimeInterval(24 * 3600) : time
  }

  // MARK: - Time Normalization

  mutating func normalizeTimes() {
    let normalized = normalizedTimes()
    outTime = normalized.outTime
    offTime = normalized.offTime
    onTime = normalized.onTime
    inTime = normalized.inTime
  }

  func normalizedTimes() -> (outTime: Date, offTime: Date, onTime: Date, inTime: Date) {
    let calendar = Self.utcCalendar
    let flightDate = calendar.startOfDay(for: date)

    // Normalize outTime (always same day)
    let normalizedOut = combine(date: flightDate, time: outTime)

    // Normalize offTime relative to outTime
    let normalizedOff = normalizeSingleTime(offTime, referenceDate: normalizedOut)

    // Normalize onTime relative to offTime
    let normalizedOn = normalizeSingleTime(onTime, referenceDate: normalizedOff)

    // Normalize inTime relative to onTime
    let normalizedIn = normalizeSingleTime(inTime, referenceDate: normalizedOn)

    return (normalizedOut, normalizedOff, normalizedOn, normalizedIn)
  }

  private func normalizeSingleTime(_ time: Date, referenceDate: Date) -> Date {
    let calendar = Self.utcCalendar
    let components = calendar.dateComponents([.hour, .minute], from: time)

    // Get the flight date from the reference date
    let flightDate = calendar.startOfDay(for: referenceDate)

    // Create the normalized time on the flight date
    var normalizedTime = calendar.date(
      bySettingHour: components.hour ?? 0,
      minute: components.minute ?? 0,
      second: 0,
      of: flightDate)!

    // If the normalized time is before the reference time, add one day
    if normalizedTime < referenceDate {
      normalizedTime = calendar.date(byAdding: .day, value: 1, to: normalizedTime)!
    }

    return normalizedTime
  }

  private func combine(date: Date, time: Date) -> Date {
    let calendar = Self.utcCalendar
    let components = calendar.dateComponents([.hour, .minute], from: time)
    return calendar.date(
      bySettingHour: components.hour ?? 0,
      minute: components.minute ?? 0,
      second: 0,
      of: date) ?? date
  }

  // MARK: - Validation

  func validateTimes() -> Bool {
    let normalized = normalizedTimes()

    // Check chronological order in UTC
    guard normalized.outTime <= normalized.offTime,
      normalized.offTime <= normalized.onTime,
      normalized.onTime <= normalized.inTime
    else {
      return false
    }

    // Check minimum durations
    let blockDuration = normalized.inTime.timeIntervalSince(normalized.outTime)
    let flightDuration = normalized.onTime.timeIntervalSince(normalized.offTime)
    let taxiOutDuration = normalized.offTime.timeIntervalSince(normalized.outTime)
    let taxiInDuration = normalized.inTime.timeIntervalSince(normalized.onTime)

    return blockDuration >= 60 && flightDuration >= 60 && taxiOutDuration >= 0
      && taxiInDuration >= 0
  }

  // MARK: - Factory Methods

  static func emptyFlight() -> Flight {
    let now = Date()
    return Flight(
      id: UUID(),
      flightNumber: "",
      date: Self.utcCalendar.startOfDay(for: now),
      aircraftRegistration: "",
      aircraftType: "",
      departureAirportId: 0,
      arrivalAirportId: 0,
      pilotInCommand: "",
      isSelf: true,
      isPF: false,
      isIFR: false,
      isVFR: false,
      position: .firstOfficer,
      operatingCapacity: .p1,
      outTime: now,
      offTime: now.addingTimeInterval(30 * 60),
      onTime: now.addingTimeInterval(2 * 60 * 60),
      inTime: now.addingTimeInterval(2.5 * 60 * 60),
      notes: nil,
      userId: 1
    )
  }
}

extension Flight: EncodableRecord, FetchableRecord {}

extension Flight: TableRecord {
  static let departureAirport = belongsTo(
    Airport.self, key: "departureAirport", using: ForeignKey(["departureAirportId"]))
  static let arrivalAirport = belongsTo(
    Airport.self, key: "arrivalAirport", using: ForeignKey(["arrivalAirportId"]))
}

extension Flight: PersistableRecord {
  // MARK: - PersistableRecord conformance

  func encode(to container: inout PersistenceContainer) {
    container[Columns.id] = id
    container[Columns.flightNumber] = flightNumber
    container[Columns.date] = date
    container[Columns.aircraftRegistration] = aircraftRegistration
    container[Columns.aircraftType] = aircraftType
    container[Columns.departureAirportId] = departureAirportId
    container[Columns.arrivalAirportId] = arrivalAirportId
    container[Columns.pilotInCommand] = pilotInCommand
    container[Columns.isSelf] = isSelf
    container[Columns.isPF] = isPF
    container[Columns.isIFR] = isIFR
    container[Columns.isVFR] = isVFR
    container[Columns.position] = position.rawValue
    container[Columns.operatingCapacity] = operatingCapacity.rawValue
    container[Columns.outTime] = outTime
    container[Columns.offTime] = offTime
    container[Columns.onTime] = onTime
    container[Columns.inTime] = inTime
    container[Columns.notes] = notes
    container[Columns.userId] = userId
  }

  // MARK: - Row Decoding

  init(row: Row) {
    // Initialize all stored properties first
    self.id = row[Columns.id]
    self.flightNumber = row[Columns.flightNumber]
    self.date = row[Columns.date]
    self.aircraftRegistration = row[Columns.aircraftRegistration]
    self.aircraftType = row[Columns.aircraftType]
    self.departureAirportId = row[Columns.departureAirportId]
    self.arrivalAirportId = row[Columns.arrivalAirportId]
    self.pilotInCommand = row[Columns.pilotInCommand]
    self.isSelf = row[Columns.isSelf]
    self.isPF = row[Columns.isPF]
    self.isIFR = row[Columns.isIFR]
    self.isVFR = row[Columns.isVFR]
    self.position = Position(rawValue: row[Columns.position]) ?? .firstOfficer
    self.operatingCapacity = OperatingCapacity(rawValue: row[Columns.operatingCapacity]) ?? .p2
    self.storedOutTime = row[Columns.outTime]
    self.storedOffTime = row[Columns.offTime]
    self.storedOnTime = row[Columns.onTime]
    self.storedInTime = row[Columns.inTime]
    self.notes = row[Columns.notes]
    self.userId = row[Columns.userId]

    // Initialize relationships
    self.departureAirport = row["departureAirport"]
    self.arrivalAirport = row["arrivalAirport"]
  }
}
