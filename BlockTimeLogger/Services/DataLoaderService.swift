import Foundation
import GRDB
import Combine

class DataLoaderService {
    static let shared = DataLoaderService()
    
    private init() {}
    
    // MARK: - Airport Loading
    
    /// Loads airports from the airports.json file in the app bundle
    /// - Returns: An array of Airport objects
    func loadAirports() throws -> [Airport] {
        // Get the URL for the airports.json file in the app bundle
        guard let url = Bundle.main.url(forResource: "airports", withExtension: "json") else {
            throw DataLoaderError.fileNotFound("airports.json not found in bundle")
        }
        
        // Load the JSON data
        let data = try Data(contentsOf: url)
        
        // Parse the JSON
        let json = try JSONSerialization.jsonObject(with: data) as! [String: [String: Any]]
        
        // Convert to Airport objects
        var airports: [Airport] = []
        
        for (_, airportData) in json {
            let name = airportData["name"] as? String ?? ""
            let icao = airportData["icao"] as? String ?? ""
            let iata = airportData["iata"] as? String ?? ""
            
            // Only add airports with valid ICAO codes
            if !icao.isEmpty {
                let airport = Airport(name: name, icao: icao, iata: iata)
                airports.append(airport)
            }
        }
        
        return airports
    }
    
    /// Imports airports into the database with progress reporting
    /// - Parameters:
    ///   - dbQueue: The database queue to use
    ///   - clearExisting: Whether to clear existing airports before importing
    ///   - progressHandler: A closure to report progress
    /// - Returns: A publisher that emits the result of the import
    func importAirportsToDatabase(
        dbQueue: DatabaseQueue,
        clearExisting: Bool = false,
        progressHandler: @escaping (Double) -> Void
    ) -> AnyPublisher<ImportResult, Error> {
        return Future<ImportResult, Error> { promise in
            do {
                // Load airports from JSON
                let airports = try self.loadAirports()
                let totalCount = airports.count
                
                // Import to database
                try dbQueue.write { db in
                    // Clear existing airports if needed
                    if clearExisting {
                        try Airport.deleteAll(db)
                    }
                    
                    // Insert new airports with progress reporting
                    for (index, airport) in airports.enumerated() {
                        try airport.insert(db)
                        
                        // Report progress
                        let progress = Double(index + 1) / Double(totalCount)
                        DispatchQueue.main.async {
                            progressHandler(progress)
                        }
                    }
                }
                
                // Return success
                let result = ImportResult(
                    importedCount: totalCount,
                    message: "Successfully imported \(totalCount) airports"
                )
                promise(.success(result))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Imports airports into the database asynchronously
    /// - Parameters:
    ///   - dbQueue: The database queue to use
    ///   - clearExisting: Whether to clear existing airports before importing
    ///   - progressHandler: A closure to report progress
    ///   - completion: A closure called when the import completes
    func importAirportsToDatabaseAsync(
        dbQueue: DatabaseQueue,
        clearExisting: Bool = false,
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<ImportResult, Error>) -> Void
    ) {
        importAirportsToDatabase(
            dbQueue: dbQueue,
            clearExisting: clearExisting,
            progressHandler: progressHandler
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            },
            receiveValue: { importResult in
                completion(.success(importResult))
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Supporting Types

struct ImportResult {
    let importedCount: Int
    let message: String
}

enum DataLoaderError: LocalizedError {
    case fileNotFound(String)
    case parsingError(String)
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let message):
            return "File not found: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}
