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
        case operatingCapacity = "Operating Capacity"
        
        var isRequired: Bool {
            switch self {
            case .date, .flightNumber, .departureAirport, .arrivalAirport, .aircraftRegistration,
                 .outTime, .offTime, .onTime, .inTime, .pic:
                return true
            case .takeoff, .landings, .autoland, .blockTime, .operatingCapacity:
                return false
            }
        }
        
        var allowsMultipleMappings: Bool {
            self == .pic
        }
        
        var allowsPrefix: Bool {
            self == .flightNumber
        }
    }
    
    var mappings: [ColumnType: [Int]]
    var flightNumberPrefix: String
    var defaultOperatingCapacity: OperatingCapacity
    
    init() {
        mappings = [:]
        flightNumberPrefix = ""
        defaultOperatingCapacity = .p1
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

class ImportColumnMappingManager {
    static let shared = ImportColumnMappingManager()
    private let userDefaults = UserDefaults.standard
    private let mappingKey = "importColumnMapping"
    
    private init() {}
    
    func saveMapping(_ mapping: ImportColumnMapping) {
        if let encoded = try? JSONEncoder().encode(mapping) {
            userDefaults.set(encoded, forKey: mappingKey)
        }
    }
    
    func loadMapping() -> ImportColumnMapping {
        if let data = userDefaults.data(forKey: mappingKey),
           let mapping = try? JSONDecoder().decode(ImportColumnMapping.self, from: data)
        {
            return mapping
        }
        return ImportColumnMapping()
    }
    
    func resetToDefault() {
        saveMapping(ImportColumnMapping())
    }
}
