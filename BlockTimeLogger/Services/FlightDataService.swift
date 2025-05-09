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
        storedFlights.sort { (flight1: Flight, flight2: Flight) in flight1.date > flight2.date } // Keep sorted by date
    }
    
    func fetchFlights() -> [Flight] {
        return storedFlights
    }
    
    func generateMockFlights(count: Int) -> [Flight] {
        let newFlights = (0 ..< count).map { _ in
            // Random date within last 30 days
            let daysAgo = Int.random(in: 0...30)
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            
            // Create random times within the date
            var times: [Date] = []
            for _ in 0...3 {
                let randomMinutes = Int.random(in: 0...1439)
                let time = Calendar.current.date(bySettingHour: randomMinutes / 60, minute: randomMinutes % 60, second: 0, of: date)!
                times.append(time)
            }
            times.sort()
            
            let outTime = times[0]
            let offTime = times[1]
            let onTime = times[2]
            let inTime = times[3]
            
            // Aircraft info
            let airline = ["CPA", "SIA", "JAL", "UAL", "DAL"].randomElement()!
            let flightNum = "\(airline)\(Int.random(in: 100...999))"
            let aircraftType = ["B77W", "A350", "B738", "A320", "B789"].randomElement()!
            let regPrefix = ["B-", "N", "JA", "9V"].randomElement()!
            let aircraftReg = "\(regPrefix)\(String(format: "%03d", Int.random(in: 100...999)))"
            
            // Airports
//            let departureAirport = ["VHHH", "WSSS", "RJTT", "KLAX", "KJFK"].randomElement()!
//            let arrivalAirport = ["VHHH", "WSSS", "RJTT", "KLAX", "KJFK"].randomElement()!
            
            // Pilot name
            let firstName = firstNames.randomElement()!
            let lastName = lastNames.randomElement()!
            let pilotInCommand = "\(firstName.first!). \(lastName)"
            
            // Generate random position
            let position: Flight.Position = [.captain, .firstOfficer, .secondOfficer].randomElement()!
            
            // Generate random flight conditions
            let isPF = Bool.random()
            let isIFR = Bool.random()
            
            // Create a new flight with the updated model
            let flight = Flight(
                id: UUID(),
                flightNumber: flightNum,
                date: date,
//                aircraftRegistration: aircraftReg,
//                aircraftType: aircraftType,
                aircraftId: 0,
                departureAirportId: 1, // Using integer IDs starting from 1
                arrivalAirportId: 2,
                pilotInCommand: pilotInCommand,
                isSelf: Bool.random(),
                isPF: isPF,
                isIFR: isIFR,
                isVFR: !isIFR,
                position: position,
                operatingCapacity: [.p1, .p2, .p2x].randomElement()!,
                outTime: outTime,
                offTime: offTime,
                onTime: onTime,
                inTime: inTime,
                notes: nil,
                userId: 1
            )
            
            return flight
        }.sorted { (flight1: Flight, flight2: Flight) in flight1.date > flight2.date }
        
        storedFlights.append(contentsOf: newFlights)
        return newFlights
    }
    
    private func randomTime(on date: Date, hourRange: ClosedRange<Int>) -> Date {
        let hour = Int.random(in: hourRange)
        let minute = Int.random(in: 0...59)
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components) ?? date
    }
}
