//
//  LocalDatabase+Migrator.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Foundation
import GRDB

extension LocalDatabase {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v1") { db in
            try createFlightTable(db)
        }

        return migrator
    }

    private func createFlightTable(_ db: GRDB.Database) throws {
        try db.create(table: "flight") { table in
            // Primary key
            table.column("id", .text).primaryKey()

            // Basic flight info
            table.column("flightNumber", .text).notNull()
            table.column("date", .datetime).notNull()
            table.column("aircraftRegistration", .text).notNull()
            table.column("aircraftType", .text).notNull()
            table.column("departureAirport", .text).notNull()
            table.column("arrivalAirport", .text).notNull()

            // Crew info
            table.column("pilotInCommand", .text).notNull()
            table.column("isSelf", .boolean).notNull()
            table.column("isPF", .boolean).notNull()
            table.column("isIFR", .boolean).notNull()
            table.column("isVFR", .boolean).notNull()
            table.column("position", .text).notNull()

            // Timing fields
            table.column("outTime", .datetime).notNull()
            table.column("offTime", .datetime).notNull()
            table.column("onTime", .datetime).notNull()
            table.column("inTime", .datetime).notNull()

            // Other
            table.column("notes", .text).notNull()
        }
    }
}
