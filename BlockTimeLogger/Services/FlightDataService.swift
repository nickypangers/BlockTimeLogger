//
//  FlightDataService.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import Foundation

protocol FlightDataServiceProtocol {
    func generateMockFlights(count: Int) -> [Flight]

    func saveFlight(_ flight: Flight)
    func fetchFlights() -> [Flight]
}

class FlightDataService: FlightDataServiceProtocol {
    static let shared = FlightDataService()
    private let calendar = Calendar.current
    
    private let firstNames = ["John", "Michael", "David", "Robert", "James",
                              "Sarah", "Emily", "Jessica", "Jennifer", "Lisa"]
    private let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones",
                             "Miller", "Davis", "Wilson", "Anderson", "Taylor"]
    
    private var storedFlights: [Flight] = []
    
    func saveFlight(_ flight: Flight) {
        storedFlights.append(flight)
        storedFlights.sort { $0.date > $1.date } // Keep sorted by date
    }
    
    func fetchFlights() -> [Flight] {
        return storedFlights
    }
    
    func generateMockFlights(count: Int) -> [Flight] {
        let newFlights = (0 ..< count).map { _ in
            // Random date within last 30 days
            let daysAgo = Int.random(in: 0...30)
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            
            // Base times
            let outTime = randomTime(on: date, hourRange: 5...22)
            
            // Realistic durations
            let taxiOutDuration = Int.random(in: 10...25)
            let flightDuration = Int.random(in: 30...840)
            let taxiInDuration = Int.random(in: 8...20)
            
            // Derived times
            let offTime = calendar.date(byAdding: .minute, value: taxiOutDuration, to: outTime)!
            let onTime = calendar.date(byAdding: .minute, value: flightDuration, to: offTime)!
            let inTime = calendar.date(byAdding: .minute, value: taxiInDuration, to: onTime)!
            
            // Aircraft info
            let airline = ["CPA", "SIA", "JAL", "UAL", "DAL"].randomElement()!
            let flightNum = "\(airline)\(Int.random(in: 100...999))"
            let aircraftType = ["B77W", "A350", "B738", "A320", "B789"].randomElement()!
            let regPrefix = ["B-", "N", "JA", "9V"].randomElement()!
            let aircraftReg = "\(regPrefix)\(String(format: "%03d", Int.random(in: 100...999)))"
            
            // Airports
            let airports = ["VHHH", "EDDF", "KJFK", "KSFO", "YSSY", "RJTT", "WSSS"]
            let departure = airports.randomElement()!
            let arrival = airports.filter { $0 != departure }.randomElement()!
            
            // Pilot name
            let firstName = firstNames.randomElement()!
            let lastName = lastNames.randomElement()!
            let pilotInCommand = "\(firstName.first!). \(lastName)"
            
            // Generate random position
            let position: Flight.Position = [.captain, .firstOfficer, .secondOfficer].randomElement()!
            
            // Generate random flight conditions
            let isPF = Bool.random()
            let isIFR = Bool.random()
            
            return Flight(
                flightNumber: flightNum,
                date: date,
                aircraftRegistration: aircraftReg,
                aircraftType: aircraftType,
                departureAirport: departure,
                arrivalAirport: arrival,
                pilotInCommand: pilotInCommand,
                isSelf: Bool.random(),
                isPF: isPF,
                isIFR: isIFR,
                isVFR: !isIFR, // Ensure IFR and VFR are mutually exclusive
                position: position,
                outTime: outTime,
                offTime: offTime,
                onTime: onTime,
                inTime: inTime
            )
        }.sorted { $0.date > $1.date }
        
        storedFlights.append(contentsOf: newFlights)
        return newFlights
    }
    
    private func randomTime(on date: Date, hourRange: ClosedRange<Int>) -> Date {
        let hour = Int.random(in: hourRange)
        let minute = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55].randomElement()!
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
    }
}
