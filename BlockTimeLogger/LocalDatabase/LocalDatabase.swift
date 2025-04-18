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
        try migrator.migrate(writer)
    }

    var reader: DatabaseReader {
        writer
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
}

// MARK: - Observe

extension LocalDatabase {
    func observeFlights() -> AnyPublisher<[Flight], Never> {
        // Create a publisher that observes the database for changes
        return ValueObservation
            .tracking { db in
                try Flight.order(Flight.Columns.outTime.desc).fetchAll(db)
            }
            .publisher(in: reader)
            .catch { error -> AnyPublisher<[Flight], Never> in
                print("LocalDatabase: Error observing flights: \(error)")
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
                try Flight.order(Flight.Columns.outTime.desc).fetchAll(db)
            }
        } catch {
            print("LocalDatabase: Error fetching flights: \(error)")
            return []
        }
    }
}
