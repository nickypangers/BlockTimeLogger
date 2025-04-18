//
//  ImportService.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 18/4/2025.
//

import Foundation

class ImportService {
    static let shared = ImportService()
    
    private init() {}

    func importFlights(from text: String) -> [Flight] {
        let lines = text.components(separatedBy: .newlines)
        var flights: [Flight] = []
        
        for line in lines {
            // Skip header lines and empty lines
            guard !line.isEmpty,
                  !line.contains("Sector"),
                  !line.contains("----"),
                  !line.contains("Report Date"),
                  !line.contains("Log Book record")
            else {
                continue
            }
            
            // Split line into components and filter empty strings
            let components = line.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            
            guard components.count >= 12 else { continue }

            print(components)

            // 0: Date
            // 1: Flight Number
            // 2: Departure Airport
            // 3: Arrival Airport
            // 4: Aircraft Registration
            // 5: Block Time
            // 6: Out Time
            // 7: Off Time
            // 8: On Time
            // 9: In Time
            // 10: TO
            // 11: LDG
            // 12: Autoland
            // 13: Commander Surname
            // 14: Commander First Name
            
            // Parse date - format: yyyy/MM/dd
            let dateParts = components[0].split(separator: "/")
            guard dateParts.count == 3,
                  let year = Int(dateParts[0]),
                  let month = Int(dateParts[1]),
                  let day = Int(dateParts[2]) else {
                continue
            }
            
            // Create date components
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            dateComponents.timeZone = TimeZone(identifier: "UTC")
            
            // Create date from components
            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: dateComponents) else { continue }
            
            // Create base flight object
            var flight = Flight.emptyFlight()
            flight.id = UUID()
            flight.date = date
            flight.flightNumber = components[1]
            flight.departureAirport = components[2]
            flight.arrivalAirport = components[3]
            flight.aircraftRegistration = components[4]
            flight.aircraftType = "B77W" // Default aircraft type
            
            // Helper function to parse time and handle +1/-1 indicators
            func parseTime(_ timeStr: String, baseDate: Date) -> Date? {
                // Extract the time part and any day adjustment
                var dayAdjustment = 0
                var cleanTime = timeStr
                
                if timeStr.contains("+1") {
                    dayAdjustment = 1
                    cleanTime = timeStr.replacingOccurrences(of: "+1", with: "")
                } else if timeStr.contains("-1") {
                    dayAdjustment = -1
                    cleanTime = timeStr.replacingOccurrences(of: "-1", with: "")
                }
                
                // Split the time into hours and minutes
                let timeParts = cleanTime.split(separator: ":")
                guard timeParts.count == 2,
                      let hours = Int(timeParts[0]),
                      let minutes = Int(timeParts[1]) else {
                    return nil
                }
                
                // Create date components with the time
                var timeComponents = DateComponents()
                timeComponents.year = year
                timeComponents.month = month
                timeComponents.day = day
                timeComponents.hour = hours
                timeComponents.minute = minutes
                timeComponents.second = 0
                timeComponents.timeZone = TimeZone(identifier: "UTC")
                
                // Create date from components
                guard var resultDate = calendar.date(from: timeComponents) else { return nil }
                
                // Apply day adjustment if needed
                if dayAdjustment != 0 {
                    resultDate = calendar.date(byAdding: .day, value: dayAdjustment, to: resultDate)!
                }
                
                return resultDate
            }
            
            // Parse all times (already in UTC)
            if let outTime = parseTime(components[6], baseDate: date) {
                flight.outTime = outTime
            }
            
            if let offTime = parseTime(components[7], baseDate: date) {
                flight.offTime = offTime
            }
            
            if let onTime = parseTime(components[8], baseDate: date) {
                flight.onTime = onTime
            }
            
            if let inTime = parseTime(components[9], baseDate: date) {
                flight.inTime = inTime
            }
            
            // Set pilot info and flight conditions
            // Skip the 'N' value (components[11]) when joining the commander name
            let commanderComponents = components[12...].filter { $0 != "N" }
            flight.pilotInCommand = commanderComponents.joined(separator: " ")
            flight.isSelf = false
            flight.position = .secondOfficer
            flight.operatingCapacity = .p2x
            flight.isIFR = true
            flight.isVFR = false
            flight.isPF = false
            
            flights.append(flight)
        }
        
        print(flights)
        
        return flights
    }
}
