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

        // migrator.registerMigration("v2") { db in
        //     // Update all existing records to have P2X as operatingCapacity
        //     try db.execute(sql: """
        //         UPDATE \(Flight.databaseTableName)
        //         SET \(Flight.Columns.operatingCapacity.rawValue) = 'P2X'
        //         WHERE \(Flight.Columns.operatingCapacity.rawValue) IS NULL
        //         """)
        // }

        return migrator
    }

    private func createFlightTable(_ db: GRDB.Database) throws {
        try db.create(table: Flight.databaseTableName) { t in
            t.column(Flight.Columns.id.rawValue, .text).primaryKey()
            t.column(Flight.Columns.flightNumber.rawValue, .text).notNull()
            t.column(Flight.Columns.date.rawValue, .datetime).notNull()
            t.column(Flight.Columns.aircraftRegistration.rawValue, .text).notNull()
            t.column(Flight.Columns.aircraftType.rawValue, .text).notNull()
            t.column(Flight.Columns.operatingCapacity.rawValue, .text).notNull()
            t.column(Flight.Columns.departureAirport.rawValue, .text).notNull()
            t.column(Flight.Columns.arrivalAirport.rawValue, .text).notNull()
            t.column(Flight.Columns.pilotInCommand.rawValue, .text).notNull()
            t.column(Flight.Columns.isSelf.rawValue, .boolean).notNull()
            t.column(Flight.Columns.isPF.rawValue, .boolean).notNull()
            t.column(Flight.Columns.isIFR.rawValue, .boolean).notNull()
            t.column(Flight.Columns.isVFR.rawValue, .boolean).notNull()
            t.column(Flight.Columns.position.rawValue, .text).notNull()
            t.column(Flight.Columns.outTime.rawValue, .datetime).notNull()
            t.column(Flight.Columns.offTime.rawValue, .datetime).notNull()
            t.column(Flight.Columns.onTime.rawValue, .datetime).notNull()
            t.column(Flight.Columns.inTime.rawValue, .datetime).notNull()
            t.column(Flight.Columns.notes.rawValue, .text)
            t.column(Flight.Columns.userId.rawValue, .integer).notNull()
        }
    }
}
