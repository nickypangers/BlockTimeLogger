import Foundation
import GRDB

struct Flight: Identifiable, Codable {
    var id: UUID
    var flightNumber: String
    var date: Date
    var aircraftRegistration: String
    var aircraftType: String
    var departureAirport: String
    var arrivalAirport: String
    
    var pilotInCommand: String
    var isSelf: Bool
    
    var isPF: Bool = false
    var isIFR: Bool = false
    var isVFR: Bool = false
    var position: Position = .firstOfficer
    
    // Timing fields (all in UTC)
    var outTime: Date // Wheels off chocks
    var offTime: Date // Wheels up (takeoff)
    var onTime: Date // Wheels down (landing)
    var inTime: Date // Wheels on chocks
    
    var notes: String = ""
    var sector: Int { 1 } // Each flight counts as 1 sector
    
    var userId: Int
    
    // MARK: - Initializer with default values

    init(
        id: UUID,
        flightNumber: String,
        date: Date,
        aircraftRegistration: String,
        aircraftType: String,
        departureAirport: String,
        arrivalAirport: String,
        pilotInCommand: String,
        isSelf: Bool,
        isPF: Bool = false,
        isIFR: Bool = false,
        isVFR: Bool = false,
        position: Position = .firstOfficer,
        outTime: Date,
        offTime: Date,
        onTime: Date,
        inTime: Date,
        notes: String = "",
        userId: Int
    ) {
        self.id = id
        self.flightNumber = flightNumber
        self.date = date
        self.aircraftRegistration = aircraftRegistration
        self.aircraftType = aircraftType
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.pilotInCommand = pilotInCommand
        self.isSelf = isSelf
        self.isPF = isPF
        self.isIFR = isIFR
        self.isVFR = isVFR
        self.position = position
        self.outTime = outTime
        self.offTime = offTime
        self.onTime = onTime
        self.inTime = inTime
        self.notes = notes
        self.userId = userId
    }
    
    enum Position: String, CaseIterable, Codable {
        case captain = "CN"
        case firstOfficer = "FO"
        case secondOfficer = "SO"
    }
    
    // UTC Calendar setup
    static var utcCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
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
    
//    var blockTime: TimeInterval {
//        adjustedTime(inTime, reference: outTime).timeIntervalSince(outTime)
//    }
//
//    var flightTime: TimeInterval {
//        adjustedTime(onTime, reference: offTime).timeIntervalSince(offTime)
//    }
//
//    var taxiOutTime: TimeInterval {
//        adjustedTime(offTime, reference: outTime).timeIntervalSince(outTime)
//    }
//
//    var taxiInTime: TimeInterval {
//        adjustedTime(inTime, reference: onTime).timeIntervalSince(onTime)
//    }
    
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
            
        // Find the date that makes this time occur after the reference
        var candidateDate = calendar.date(bySettingHour: components.hour ?? 0,
                                          minute: components.minute ?? 0,
                                          second: 0,
                                          of: referenceDate)!
            
        // If candidate is before reference, add days until it's after
        while candidateDate < referenceDate {
            candidateDate = calendar.date(byAdding: .day, value: 1, to: candidateDate)!
        }
            
        return candidateDate
    }
    
    private func combine(date: Date, time: Date) -> Date {
        let calendar = Self.utcCalendar
        let components = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: components.hour ?? 0,
                             minute: components.minute ?? 0,
                             second: 0,
                             of: date) ?? date
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
        
        return blockDuration >= 60 &&
            flightDuration >= 60 &&
            taxiOutDuration >= 0 &&
            taxiInDuration >= 0
    }
    
    static func emptyFlight() -> Flight {
        let now = Date()
        return Flight(
            id: UUID(),
            flightNumber: "",
            date: Self.utcCalendar.startOfDay(for: now),
            aircraftRegistration: "",
            aircraftType: "",
            departureAirport: "",
            arrivalAirport: "",
            pilotInCommand: "",
            isSelf: true,
            isPF: false,
            isIFR: false,
            isVFR: false,
            position: .firstOfficer,
            outTime: now,
            offTime: now.addingTimeInterval(30 * 60),
            onTime: now.addingTimeInterval(2 * 60 * 60),
            inTime: now.addingTimeInterval(2.5 * 60 * 60),
            notes: "",
            userId: 1
        )
    }
    
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
}

extension Flight: EncodableRecord, FetchableRecord {}

extension Flight: TableRecord {}

extension Flight: PersistableRecord {
    // MARK: - PersistableRecord conformance

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.flightNumber] = flightNumber
        container[Columns.date] = date
        container[Columns.aircraftRegistration] = aircraftRegistration
        container[Columns.aircraftType] = aircraftType
        container[Columns.departureAirport] = departureAirport
        container[Columns.arrivalAirport] = arrivalAirport
        container[Columns.pilotInCommand] = pilotInCommand
        container[Columns.isSelf] = isSelf
        container[Columns.isPF] = isPF
        container[Columns.isIFR] = isIFR
        container[Columns.isVFR] = isVFR
        container[Columns.position] = position.rawValue
        container[Columns.outTime] = outTime
        container[Columns.offTime] = offTime
        container[Columns.onTime] = onTime
        container[Columns.inTime] = inTime
        container[Columns.notes] = notes
        container[Columns.userId] = userId
    }
}
