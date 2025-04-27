import Foundation
import GRDB
import SwiftUI

struct Sim: Identifiable, Codable {
    // MARK: - Stored Properties

    var id: Int64?
    var date: Date
    var aircraftType: String
    var registration: String
    var pic: String
    var operatingCapacity: OperatingCapacity
    var instrumentTime: Double
    var simulatorTime: Double
    var notes: String?

    // MARK: - Computed Properties

    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    var formattedInstrumentTime: String {
        let hours = Int(instrumentTime)
        let minutes = Int((instrumentTime - Double(hours)) * 60)
        return String(format: "%d:%02d", hours, minutes)
    }

    var formattedSimulatorTime: String {
        let hours = Int(simulatorTime)
        let minutes = Int((simulatorTime - Double(hours)) * 60)
        return String(format: "%d:%02d", hours, minutes)
    }

    // MARK: - Initialization

    init(
        id: Int64? = nil,
        date: Date = Date(),
        aircraftType: String = "",
        registration: String = "",
        pic: String = "",
        operatingCapacity: OperatingCapacity = OperatingCapacity.simOptions[0],
        instrumentTime: Double = 0,
        simulatorTime: Double = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.aircraftType = aircraftType
        self.registration = registration
        self.pic = pic
        self.operatingCapacity = operatingCapacity
        self.instrumentTime = instrumentTime
        self.simulatorTime = simulatorTime
        self.notes = notes
    }

    static func emptySim() -> Sim {
        Sim()
    }
}

extension Sim: EncodableRecord, TableRecord {}

extension Sim: PersistableRecord {
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.date] = date
        container[Columns.aircraftType] = aircraftType
        container[Columns.registration] = registration
        container[Columns.pic] = pic
        container[Columns.operatingCapacity] = operatingCapacity.rawValue
        container[Columns.instrumentTime] = instrumentTime
        container[Columns.simulatorTime] = simulatorTime
        container[Columns.notes] = notes
    }

    init(row: Row) {
        self.id = row[Columns.id]
        self.date = row[Columns.date]
        self.aircraftType = row[Columns.aircraftType]
        self.registration = row[Columns.registration]
        self.pic = row[Columns.pic]
        self.operatingCapacity = OperatingCapacity(rawValue: row[Columns.operatingCapacity]) ?? .put
        self.instrumentTime = row[Columns.instrumentTime]
        self.simulatorTime = row[Columns.simulatorTime]
        self.notes = row[Columns.notes]
    }
}
