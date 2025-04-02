//
//  FlightDataService.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import Foundation

class FlightDataService {
    static let shared = FlightDataService()
    private init() {}
    
    // Sample pilot names
    private let firstNames = ["John", "Michael", "David", "Robert", "James",
                              "Sarah", "Emily", "Jessica", "Jennifer", "Lisa"]
    private let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones",
                             "Miller", "Davis", "Wilson", "Anderson", "Taylor"]
    
    func generateMockFlights(count: Int) -> [Flight] {
        let aircraftTypes = ["B77W", "A350", "B738", "A320", "B789"]
        let airlines = ["CPA", "SIA", "JAL", "UAL", "DAL"]
        let airports = ["VHHH", "EDDF", "KJFK", "KSFO", "YSSY", "RJTT", "WSSS"]
        let calendar = Calendar.current
        let now = Date()
            
        return (0 ..< count).map { _ in
            let daysAgo = Int.random(in: 0...30)
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
                
            // Base times
            let outTime = calendar.date(
                bySettingHour: Int.random(in: 5...22),
                minute: Int.random(in: 0...59),
                second: 0,
                of: date
            )!
                
            // Derived times with realistic intervals
            let offTime = calendar.date(byAdding: .minute, value: Int.random(in: 15...45), to: outTime)!
            let flightDurationMinutes = Int.random(in: 30...840) // 0.5-14 hours
            let onTime = calendar.date(byAdding: .minute, value: flightDurationMinutes, to: offTime)!
            let inTime = calendar.date(byAdding: .minute, value: Int.random(in: 10...30), to: onTime)!
                
            let airline = airlines.randomElement()!
            let flightNum = "\(airline) \(Int.random(in: 100...999))"
            let aircraftType = aircraftTypes.randomElement()!
            let regPrefix = ["B-", "N", "JA", "9V"].randomElement()!
            let aircraftReg = "\(regPrefix)\(String(format: "%03d", Int.random(in: 100...999)))"
                
            let departure = airports.randomElement()!
            let arrival = airports.filter { $0 != departure }.randomElement()!
            
            // Generate random pilot name
            let pilotInCommand = "\(firstNames.randomElement()!.prefix(1)). \(lastNames.randomElement()!)"
            let isSelf = Bool.random()
                
            return Flight(
                flightNumber: flightNum,
                date: date,
                aircraftRegistration: aircraftReg,
                aircraftType: aircraftType,
                departureAirport: departure,
                arrivalAirport: arrival,
                pilotInCommand: pilotInCommand,
                isSelf: isSelf,
                outTime: outTime,
                offTime: offTime,
                onTime: onTime,
                inTime: inTime
            )
        }.sorted { $0.date > $1.date }
    }
}
