//
//  Aircraft.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/5/2025.
//

import Foundation
import GRDB

struct Aircraft: Identifiable, Codable, Equatable {
  var id: Int
  var registration: String
  var type: String

  init(id: Int = 0, registration: String, type: String) {
    self.id = id
    self.registration = registration
    self.type = type
  }
}

extension Aircraft: EncodableRecord, FetchableRecord {}

extension Aircraft: TableRecord {}

extension Aircraft: PersistableRecord {
  func encode(to container: inout PersistenceContainer) throws {
    // Only encode id if it's not 0 (new record)
    if id != 0 {
      container[Columns.id] = id
    }
    container[Columns.registration] = registration
    container[Columns.type] = type
  }

  init(row: Row) {
    id = row[Columns.id]
    registration = row[Columns.registration]
    type = row[Columns.type]
  }
}
