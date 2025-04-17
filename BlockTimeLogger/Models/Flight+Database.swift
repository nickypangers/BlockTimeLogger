//
//  Flight+Database.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Foundation
import GRDB

extension Flight {
    // Define database table name
    static let databaseTableName = "flight"

    // Define database columns
    enum Columns: String, ColumnExpression {
        case id, flightNumber, date, aircraftRegistration, aircraftType
        case departureAirport, arrivalAirport, pilotInCommand, isSelf
        case isPF, isIFR, isVFR, position, outTime, offTime, onTime, inTime, notes
        case userId
    }
}