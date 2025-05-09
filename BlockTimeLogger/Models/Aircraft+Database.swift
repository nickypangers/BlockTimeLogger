//
//  Aircraft+Database.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/5/2025.
//

import Foundation
import GRDB

extension Aircraft {
    enum Columns: String, ColumnExpression {
        case id, registration, type
    }

    static let databaseTableName = "aircraft"
}
