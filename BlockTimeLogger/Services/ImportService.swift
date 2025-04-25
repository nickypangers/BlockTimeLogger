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

    func importFlights(from text: String, columnMapping: ImportColumnMapping) -> [Flight] {
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

            // Create base flight object
            var flight = Flight.emptyFlight()
            flight.id = UUID()
            
            // Parse date
            if let dateIndex = columnMapping.getColumnIndex(for: .date),
               dateIndex < components.count
            {
                let dateStr = components[dateIndex]
                let dateParts = dateStr.split(separator: "/")
                if dateParts.count == 3,
                   let year = Int(dateParts[0]),
                   let month = Int(dateParts[1]),
                   let day = Int(dateParts[2])
                {
                    var dateComponents = DateComponents()
                    dateComponents.year = year
                    dateComponents.month = month
                    dateComponents.day = day
                    dateComponents.hour = 0
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    dateComponents.timeZone = TimeZone(identifier: "UTC")
                    
                    let calendar = Calendar(identifier: .gregorian)
                    if let date = calendar.date(from: dateComponents) {
                        flight.date = date
                    }
                }
            }
            
            // Parse flight number
            if let flightNumberIndex = columnMapping.getColumnIndex(for: .flightNumber),
               flightNumberIndex < components.count
            {
                flight.flightNumber = components[flightNumberIndex]
            }
            
            // Parse departure and arrival airports
            if let depIndex = columnMapping.getColumnIndex(for: .departureAirport),
               let arrIndex = columnMapping.getColumnIndex(for: .arrivalAirport),
               depIndex < components.count,
               arrIndex < components.count
            {
                let depCode = components[depIndex]
                let arrCode = components[arrIndex]
                
                let departureAirport = depCode.count == 3 ? LocalDatabase.shared.getAirportByIATA(depCode) : LocalDatabase.shared.getAirportByICAO(depCode)
                let arrivalAirport = arrCode.count == 3 ? LocalDatabase.shared.getAirportByIATA(arrCode) : LocalDatabase.shared.getAirportByICAO(arrCode)
                
                flight.departureAirport = departureAirport
                flight.departureAirportId = departureAirport?.id ?? 0
                flight.arrivalAirport = arrivalAirport
                flight.arrivalAirportId = arrivalAirport?.id ?? 0
            }
            
            // Parse aircraft registration
            if let regIndex = columnMapping.getColumnIndex(for: .aircraftRegistration),
               regIndex < components.count
            {
                flight.aircraftRegistration = components[regIndex]
            }
            
            // Parse times
            let calendar = Calendar(identifier: .gregorian)
            
            func parseTime(_ timeStr: String, baseDate: Date) -> Date? {
                var dayAdjustment = 0
                var cleanTime = timeStr
                
                if timeStr.contains("+1") {
                    dayAdjustment = 1
                    cleanTime = timeStr.replacingOccurrences(of: "+1", with: "")
                } else if timeStr.contains("-1") {
                    dayAdjustment = -1
                    cleanTime = timeStr.replacingOccurrences(of: "-1", with: "")
                }
                
                let timeParts = cleanTime.split(separator: ":")
                guard timeParts.count == 2,
                      let hours = Int(timeParts[0]),
                      let minutes = Int(timeParts[1])
                else {
                    return nil
                }
                
                var timeComponents = DateComponents()
                timeComponents.year = calendar.component(.year, from: baseDate)
                timeComponents.month = calendar.component(.month, from: baseDate)
                timeComponents.day = calendar.component(.day, from: baseDate)
                timeComponents.hour = hours
                timeComponents.minute = minutes
                timeComponents.second = 0
                timeComponents.timeZone = TimeZone(identifier: "UTC")
                
                guard var resultDate = calendar.date(from: timeComponents) else { return nil }
                
                if dayAdjustment != 0 {
                    resultDate = calendar.date(byAdding: .day, value: dayAdjustment, to: resultDate)!
                }
                
                return resultDate
            }
            
            if let outTimeIndex = columnMapping.getColumnIndex(for: .outTime),
               outTimeIndex < components.count,
               let outTime = parseTime(components[outTimeIndex], baseDate: flight.date)
            {
                flight.outTime = outTime
            }
            
            if let offTimeIndex = columnMapping.getColumnIndex(for: .offTime),
               offTimeIndex < components.count,
               let offTime = parseTime(components[offTimeIndex], baseDate: flight.date)
            {
                flight.offTime = offTime
            }
            
            if let onTimeIndex = columnMapping.getColumnIndex(for: .onTime),
               onTimeIndex < components.count,
               let onTime = parseTime(components[onTimeIndex], baseDate: flight.date)
            {
                flight.onTime = onTime
            }
            
            if let inTimeIndex = columnMapping.getColumnIndex(for: .inTime),
               inTimeIndex < components.count,
               let inTime = parseTime(components[inTimeIndex], baseDate: flight.date)
            {
                flight.inTime = inTime
            }
            
            // Parse captain
            let picIndices = columnMapping.getColumnIndices(for: .pic)
            if !picIndices.isEmpty {
                let picParts = picIndices.compactMap { index -> String? in
                    guard index < components.count else { return nil }
                    return components[index].trimmingCharacters(in: .whitespaces)
                }
                flight.pilotInCommand = picParts.joined(separator: " ")
            }
            
            // Set default values
            flight.aircraftType = "B77W"
            flight.isSelf = false
            flight.position = .secondOfficer
            flight.operatingCapacity = .p2x
            flight.isIFR = true
            flight.isVFR = false
            flight.isPF = false
            
            flights.append(flight)
        }
        
        return flights
    }
}
