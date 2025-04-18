//
//  Airport+Database.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 19/4/2025.
//

import Foundation
import GRDB

extension Airport {
    static let databaseTableName = "airport"

    enum Columns: String, ColumnExpression {
        case id, name, iata, icao
    }
}
