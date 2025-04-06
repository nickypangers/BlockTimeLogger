//
//  LocalDatabase.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Combine
import Foundation
import GRDB

struct LocalDatabase {
    private let writer: DatabaseWriter

    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        try migrator.migrate(writer)
    }

    var reader: DatabaseReader {
        writer
    }
}

// MARK: - Writes

extension LocalDatabase {
    func createFlight(_ flight: Flight) async throws {
        try await writer.write { db in
            try flight.insert(db)
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
        return publisher.eraseToAnyPublisher()
    }
}

// MARK: - Reads

extension LocalDatabase {
    func getFlights() async throws -> [Flight] {
        try await reader.read { db in
            try Flight.fetchAll(db)
        }
    }
}
