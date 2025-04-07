//
//  MetricGroup.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 8/4/2025.
//

struct MetricGroup {
    let blockHours: String
    let flights: String
    let landings: String
    let nightHours: String
    let picHours: String
    let crossCountryHours: String

    static var sampleMonthly: MetricGroup {
        MetricGroup(
            blockHours: "42.5",
            flights: "18",
            landings: "12",
            nightHours: "6",
            picHours: "32.0",
            crossCountryHours: "8"
        )
    }

    static var sampleAllTime: MetricGroup {
        MetricGroup(
            blockHours: "1250.5",
            flights: "480",
            landings: "350",
            nightHours: "210",
            picHours: "980.0",
            crossCountryHours: "320"
        )
    }
}
