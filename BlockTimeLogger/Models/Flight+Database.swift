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
        case date = "storedDate"
        case aircraftRegistration
        case aircraftType
        case departureAirport
        case arrivalAirport
        case pilotInCommand
        case isSelf
        case isPF
        case isIFR
        case isVFR
        case position
        case operatingCapacity
        case outTime = "storedOutTime"
        case offTime = "storedOffTime"
        case onTime = "storedOnTime"
        case inTime = "storedInTime"
        case notes
        case userId
    }
    
    static let databaseTableName = "flight"
    
    // Join query to get departure airport ICAO
    static func departureAirportQuery() -> String {
        """
        SELECT a.icao
        FROM \(databaseTableName) f
        JOIN \(Airport.databaseTableName) a ON a.id = f.\(Columns.departureAirport)
        WHERE f.id = ?
        """
    }
    
    // Join query to get arrival airport ICAO
    static func arrivalAirportQuery() -> String {
        """
        SELECT a.icao
        FROM \(databaseTableName) f
        JOIN \(Airport.databaseTableName) a ON a.id = f.\(Columns.arrivalAirport)
        WHERE f.id = ?
        """
    }
}