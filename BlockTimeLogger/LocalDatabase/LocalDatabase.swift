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
        try writer.write { db in
            try flight.insert(db)
        }
    }

    func updateFlight(_ flight: Flight) throws {
        try writer.write { db in
            try flight.update(db)
        }
    }

    func deleteFlight(_ flight: Flight) throws {
        _ = try writer.write { db in
            try flight.delete(db)
        }
    }
}

// MARK: - Observe

extension LocalDatabase {
    func observeFlights() -> AnyPublisher<[Flight], Error> {
        let observation = ValueObservation.tracking { db in
            try Flight.fetchAll(db)
        }
        let publisher = observation.publisher(in: reader)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        return publisher
    }
}

// MARK: - Reads

extension LocalDatabase {
    func getFlights() throws -> [Flight] {
        try reader.read { db in
            let flights = try Flight.fetchAll(db).sorted { $0.date > $1.date }

            return flights
        }
    }
}
