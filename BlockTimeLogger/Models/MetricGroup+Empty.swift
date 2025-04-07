//
//  MetricGroup+Empty.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 8/4/2025.
//

import Foundation

extension MetricGroup {
    static var empty: MetricGroup {
        MetricGroup(
            blockHours: "0.0",
            flights: "0",
            landings: "0",
            nightHours: "0.0",
            picHours: "0.0",
            crossCountryHours: "0.0"
        )
    }
}
