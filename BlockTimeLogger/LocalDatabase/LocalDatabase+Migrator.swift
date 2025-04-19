//
//  LocalDatabase+Migrator.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Foundation
import GRDB

extension LocalDatabase {
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1") { db in
            // Create flight table
            try db.create(table: "flight") { t in
                t.column("id", .text).primaryKey()
                t.column("flightNumber", .text).notNull()
                t.column("date", .datetime).notNull()
                t.column("aircraftRegistration", .text).notNull()
                t.column("aircraftType", .text).notNull()
                t.column("departureAirport", .text).notNull()
                t.column("arrivalAirport", .text).notNull()
                t.column("pilotInCommand", .text).notNull()
                t.column("isSelf", .boolean).notNull()
                t.column("isPF", .boolean).notNull()
                t.column("isIFR", .boolean).notNull()
                t.column("isVFR", .boolean).notNull()
                t.column("position", .text).notNull()
                t.column("operatingCapacity", .text).notNull()
                t.column("outTime", .datetime).notNull()
                t.column("offTime", .datetime).notNull()
                t.column("onTime", .datetime).notNull()
                t.column("inTime", .datetime).notNull()
                t.column("notes", .text)
                t.column("userId", .integer).notNull()
            }
            
            // Create airport table
            try db.create(table: "airport") { t in
                t.column("id", .text).primaryKey()
                t.column("icao", .text).notNull().unique()
                t.column("name", .text).notNull()
            }
        }
        
        return migrator
    }
}
