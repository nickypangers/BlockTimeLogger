import Foundation

struct ImportColumnMapping: Codable {
    enum ColumnType: String, CaseIterable, Codable {
        case date = "Date"
        case flightNumber = "Flight Number"
        case departureAirport = "Departure Airport"
        case arrivalAirport = "Arrival Airport"
        case aircraftRegistration = "Aircraft Registration"
        case outTime = "Out Time"
        case offTime = "Off Time"
        case onTime = "On Time"
        case inTime = "In Time"
        case pic = "PIC"
        case takeoff = "Takeoff"
        case landings = "Landings"
        case autoland = "Autoland"
        case blockTime = "Block Time"
        
        var isRequired: Bool {
            switch self {
            case .date, .flightNumber, .departureAirport, .arrivalAirport, .aircraftRegistration,
                 .outTime, .offTime, .onTime, .inTime, .pic:
                return true
            case .takeoff, .landings, .autoland, .blockTime:
                return false
            }
        }
        
        var allowsMultipleMappings: Bool {
            self == .pic
        }
    }
    
    var mappings: [ColumnType: [Int]]
    
    init() {
        mappings = [:]
    }
    
    func getColumnIndex(for type: ColumnType) -> Int? {
        return mappings[type]?.first
    }
    
    func getColumnIndices(for type: ColumnType) -> [Int] {
        return mappings[type] ?? []
    }
    
    mutating func setColumnIndex(for type: ColumnType, index: Int) {
        if type.allowsMultipleMappings {
            var currentIndices = mappings[type] ?? []
            if currentIndices.contains(index) {
                currentIndices.removeAll { $0 == index }
            } else {
                currentIndices.append(index)
            }
            mappings[type] = currentIndices
        } else {
            mappings[type] = [index]
        }
    }
    
    func isValid() -> Bool {
        // Check if all required columns are mapped
        let requiredColumns = ColumnType.allCases.filter { $0.isRequired }
        return requiredColumns.allSatisfy { mappings[$0]?.isEmpty == false }
    }
}
