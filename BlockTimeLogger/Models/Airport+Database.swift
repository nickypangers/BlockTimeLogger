//
//  Airport+Database.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 19/4/2025.
//

import Foundation
import GRDB

extension Airport {
    enum Columns: String, ColumnExpression {
        case id, name, icao, iata
    }
    
    static let databaseTableName = "airports"
}
