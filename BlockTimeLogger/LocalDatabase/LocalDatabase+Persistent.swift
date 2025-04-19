//
//  LocalDatabase+Persistent.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Foundation
import GRDB

extension LocalDatabase {
    static let shared = makeShared()

    static func makeShared() -> LocalDatabase {
        do {
            let fileManager = FileManager()

            let folder = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)

            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)

            let databaseUrl = folder.appendingPathComponent("db.sqlite")

            let writer = try DatabaseQueue(path: databaseUrl.path)

            let database = try LocalDatabase(writer)

            // Initialize airports in a background task
            Task {
                await database.initializeAirports()
            }

            return database
        } catch {
            fatalError("ERROR: \(error)")
        }
    }
}
