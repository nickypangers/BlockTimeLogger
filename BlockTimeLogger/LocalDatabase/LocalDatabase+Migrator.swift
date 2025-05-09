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

    migrator.registerMigration("v2") { db in

      // Create airport table
      try db.create(table: Airport.databaseTableName) { t in
        t.column("id", .integer).primaryKey()
        t.column("icao", .text).notNull().unique()
        t.column("name", .text).notNull()
        t.column("iata", .text).notNull()
      }

      // Create flight table
      try db.create(table: Flight.databaseTableName) { t in
        t.column("id", .text).primaryKey()
        t.column("flightNumber", .text).notNull()
        t.column("date", .datetime).notNull()
        t.column("aircraftRegistration", .text).notNull()
        t.column("aircraftType", .text).notNull()
        t.column("departureAirportId", .integer).notNull()
        t.column("arrivalAirportId", .integer).notNull()
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

        // Add foreign key constraints
        t.foreignKey(["departureAirportId"], references: Airport.databaseTableName, columns: ["id"])
        t.foreignKey(["arrivalAirportId"], references: Airport.databaseTableName, columns: ["id"])
      }
    }

    migrator.registerMigration("v3") { db in
      try db.create(table: Aircraft.databaseTableName) { t in
        t.column("id", .integer).primaryKey()
        t.column("registration", .text).notNull().unique()
        t.column("type", .text).notNull().unique()
      }

      try db.drop(table: Flight.databaseTableName)

      try db.create(table: Flight.databaseTableName) { t in
        t.column("id", .text).primaryKey()
        t.column("flightNumber", .text).notNull()
        t.column("date", .datetime).notNull()
        t.column("aircraftId", .integer).notNull()
        t.column("departureAirportId", .integer).notNull()
        t.column("arrivalAirportId", .integer).notNull()
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

        // Add foreign key constraints
        t.foreignKey(["aircraftId"], references: Aircraft.databaseTableName, columns: ["id"])
        t.foreignKey(["departureAirportId"], references: Airport.databaseTableName, columns: ["id"])
        t.foreignKey(["arrivalAirportId"], references: Airport.databaseTableName, columns: ["id"])
      }
    }

    migrator.registerMigration("v4") { db in
      // Drop and recreate the aircraft table with correct constraints
      try db.drop(table: Aircraft.databaseTableName)

      try db.create(table: Aircraft.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("registration", .text).notNull().unique()
        t.column("type", .text).notNull()  // Removed unique constraint
      }
    }
    return migrator
  }
}
