import Foundation
import GRDB

extension Sim {
    enum Columns: String, ColumnExpression {
        case id
        case date
        case aircraftType
        case registration
        case pic
        case operatingCapacity
        case instrumentTime
        case simulatorTime
        case notes
    }

    static let databaseTableName = "sim"
}

