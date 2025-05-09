//
//  Flight+Database.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Foundation
import GRDB

extension Flight {
    enum Columns: String, ColumnExpression {
        case id
        case flightNumber
        case date
//        case aircraftRegistration
//        case aircraftType
        case aircraftId
        case departureAirportId
        case arrivalAirportId
        case pilotInCommand
        case isSelf
        case isPF
        case isIFR
        case isVFR
        case position
        case operatingCapacity
        case outTime
        case offTime
        case onTime
        case inTime
        case notes
        case userId
    }

    static let databaseTableName = "flight"

    // Join query to get departure airport ICAO
    static func departureAirportQuery() -> String {
        """
        SELECT a.icao
        FROM \(databaseTableName) f
        JOIN \(Airport.databaseTableName) a ON a.id = f.\(Columns.departureAirportId)
        WHERE f.id = ?
        """
    }

    // Join query to get arrival airport ICAO
    static func arrivalAirportQuery() -> String {
        """
        SELECT a.icao
        FROM \(databaseTableName) f
        JOIN \(Airport.databaseTableName) a ON a.id = f.\(Columns.arrivalAirportId)
        WHERE f.id = ?
        """
    }

    static func aircraftQuery() -> String {
        """
        SELECT a.aircraftId
        FROM \(databaseTableName) f
        JOIN \(Aircraft.databaseTableName) a ON a.id = f.\(Columns.aircraftId)
        WHERE f.id = ?
        """
    }
}
