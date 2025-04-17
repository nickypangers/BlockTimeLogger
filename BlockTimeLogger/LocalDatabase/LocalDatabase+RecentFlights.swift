//
//  LocalDatabase+RecentFlights.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 7/4/2025.
//

import Combine
import Foundation
import GRDB

extension LocalDatabase {
    func observeRecentFlights() -> AnyPublisher<[Flight], Never> {
        return ValueObservation
            .tracking { db in
                try Flight.order(Flight.Columns.outTime.desc).limit(5).fetchAll(db)
            }
            .publisher(in: reader)
            .catch { error -> AnyPublisher<[Flight], Never> in
                print("LocalDatabase: Error observing recent flights: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
} 