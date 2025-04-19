//
//  LocalDatabase.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Combine
import Foundation
import GRDB
import SwiftUI

struct LocalDatabase {
    private let writer: DatabaseWriter
    private let calendar = Calendar.current

    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        try LocalDatabase.migrator.migrate(writer)
    }

    var reader: DatabaseReader {
        writer
    }
    
    // MARK: - Initialization
    
    /// Call this method after initialization to load airports if needed
    func initializeAirports() async {
        await checkAndLoadAirportsIfNeeded()
    }
}

// MARK: - Write

extension LocalDatabase {
    func createFlight(_ flight: Flight) throws {
        print("LocalDatabase: Creating flight: \(flight.id)")
        try writer.write { db in
            try flight.insert(db)
        }
        print("LocalDatabase: Successfully created flight: \(flight.id)")
    }

    func createMultipleFlights(_ flights: [Flight]) throws {
        try writer.write { db in
            try flights.forEach { try $0.insert(db) }
        }

        print("LocalDatabase: Successfully created \(flights.count) flights")
    }

    func updateFlight(_ flight: Flight) throws {
        print("LocalDatabase: Updating flight: \(flight.id)")
        try writer.write { db in
            try flight.update(db)
        }
        print("LocalDatabase: Successfully updated flight: \(flight.id)")
    }

    func deleteFlight(_ flight: Flight) throws {
        print("LocalDatabase: Deleting flight: \(flight.id)")
        _ = try writer.write { db in
            try flight.delete(db)
        }
        print("LocalDatabase: Successfully deleted flight: \(flight.id)")
    }
    
    // MARK: - Airport Operations
    
    func createAirport(_ airport: Airport) throws {
        print("LocalDatabase: Creating airport: \(airport.icao)")
        try writer.write { db in
            try airport.insert(db)
        }
        print("LocalDatabase: Successfully created airport: \(airport.icao)")
    }
    
    func createMultipleAirports(_ airports: [Airport]) throws {
        try writer.write { db in
            try airports.forEach { try $0.insert(db) }
        }
        print("LocalDatabase: Successfully created \(airports.count) airports")
    }
    
    // MARK: - Initial Data Loading
    
    @MainActor
    func checkAndLoadAirportsIfNeeded() async {
        do {
            // Check if airports exist
            let airportCount = try await reader.read { db in
                try Airport.fetchCount(db)
            }
            
            if airportCount == 0 {
                print("LocalDatabase: No airports found, loading from JSON")
                await loadAirportsFromJSON()
            } else {
                print("LocalDatabase: Found \(airportCount) airports, no need to load")
            }
        } catch {
            print("LocalDatabase: Error checking airports: \(error)")
        }
    }
    
    @MainActor
    private func loadAirportsFromJSON() async {
        do {
            // Get the URL for the airports.json file in the app bundle
            guard let url = Bundle.main.url(forResource: "airports", withExtension: "json") else {
                print("LocalDatabase: airports.json not found in bundle")
                return
            }
            
            // Load the JSON data
            let data = try Data(contentsOf: url)
            
            // Parse the JSON
            let json = try JSONSerialization.jsonObject(with: data) as! [String: [String: Any]]
            
            // Convert to Airport objects and import them
            var successCount = 0
            var totalCount = 0
            
            for (_, airportData) in json {
                let name = airportData["name"] as? String ?? ""
                let icao = airportData["icao"] as? String ?? ""
                let iata = airportData["iata"] as? String ?? ""
                
                // Only process airports with valid ICAO codes and non-empty IATA codes
                if !icao.isEmpty, !iata.isEmpty {
                    totalCount += 1
                    let airport = Airport(name: name, icao: icao, iata: iata)
                    
                    do {
                        try createAirport(airport)
                        successCount += 1
                    } catch {
                        print("LocalDatabase: Skipping airport \(airport.icao) due to error: \(error)")
                        // Continue with the next airport
                    }
                }
            }
            
            print("LocalDatabase: Successfully loaded \(successCount) out of \(totalCount) airports from JSON")
        } catch {
            print("LocalDatabase: Error loading airports from JSON: \(error)")
        }
    }
}

// MARK: - Observe

extension LocalDatabase {
    func observeFlights() -> AnyPublisher<[Flight], Never> {
        // Create a publisher that observes the database for changes
        return ValueObservation
            .tracking { db in
                var flights = try Flight.order(Flight.Columns.outTime.desc).fetchAll(db)
                
                // Load airport ICAOs for each flight
                for i in 0..<flights.count {
                    let departureIcao = try String.fetchOne(db, sql: Flight.departureAirportQuery(), arguments: [flights[i].id]) ?? ""
                    let arrivalIcao = try String.fetchOne(db, sql: Flight.arrivalAirportQuery(), arguments: [flights[i].id]) ?? ""
                    
                    // Create a new flight with the loaded ICAOs
                    var flight = flights[i]
                    flight.departureAirport = departureIcao
                    flight.arrivalAirport = arrivalIcao
                    flights[i] = flight
                }
                
                return flights
            }
            .publisher(in: reader)
            .catch { error -> AnyPublisher<[Flight], Never> in
                print("LocalDatabase: Error observing flights: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func observeAirports() -> AnyPublisher<[Airport], Never> {
        // Create a publisher that observes the database for changes
        return ValueObservation
            .tracking { db in
                try Airport.order(Airport.Columns.name.asc).fetchAll(db)
            }
            .publisher(in: reader)
            .catch { error -> AnyPublisher<[Airport], Never> in
                print("LocalDatabase: Error observing airports: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Reads

extension LocalDatabase {
    func getFlights() -> [Flight] {
        do {
            return try reader.read { db in
                var flights = try Flight.order(Flight.Columns.outTime.desc).fetchAll(db)
                
                // Load airport ICAOs for each flight
                for i in 0..<flights.count {
                    let departureIcao = try String.fetchOne(db, sql: Flight.departureAirportQuery(), arguments: [flights[i].id]) ?? ""
                    let arrivalIcao = try String.fetchOne(db, sql: Flight.arrivalAirportQuery(), arguments: [flights[i].id]) ?? ""
                    
                    // Create a new flight with the loaded ICAOs
                    var flight = flights[i]
                    flight.departureAirport = departureIcao
                    flight.arrivalAirport = arrivalIcao
                    flights[i] = flight
                }
                
                return flights
            }
        } catch {
            print("LocalDatabase: Error fetching flights: \(error)")
            return []
        }
    }
    
    func getAirports() -> [Airport] {
        do {
            return try reader.read { db in
                try Airport.order(Airport.Columns.name.asc).fetchAll(db)
            }
        } catch {
            print("LocalDatabase: Error fetching airports: \(error)")
            return []
        }
    }
    
    func getAirportByICAO(_ icao: String) -> Airport? {
        do {
            return try reader.read { db in
                try Airport.filter(Airport.Columns.icao == icao).fetchOne(db)
            }
        } catch {
            print("LocalDatabase: Error fetching airport by ICAO \(icao): \(error)")
            return nil
        }
    }
    
    func searchAirports(query: String) -> [Airport] {
        do {
            return try reader.read { db in
                try Airport
                    .filter(sql: "\(Airport.Columns.name.rawValue) LIKE ? OR \(Airport.Columns.icao.rawValue) LIKE ? OR \(Airport.Columns.iata.rawValue) LIKE ?",
                            arguments: ["%\(query)%", "%\(query)%", "%\(query)%"])
                    .order(Airport.Columns.name.asc)
                    .fetchAll(db)
            }
        } catch {
            print("LocalDatabase: Error searching airports: \(error)")
            return []
        }
    }
}
