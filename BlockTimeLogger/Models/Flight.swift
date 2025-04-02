//
//  Flight.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import Foundation

struct Flight: Identifiable {
    let id = UUID()
    var flightNumber: String
    var date: Date
    var aircraftRegistration: String
    var aircraftType: String
    var departureAirport: String
    var arrivalAirport: String
    
    var pilotInCommand: String
    var isSelf: Bool
    
    // Timing fields (all as Date objects)
    var outTime: Date // Wheels off chocks
    var offTime: Date // Wheels up (takeoff)
    var onTime: Date // Wheels down (landing)
    var inTime: Date // Wheels on chocks
    
    // Calculated durations
    var blockTime: TimeInterval {
        inTime.timeIntervalSince(outTime)
    }
    
    var flightTime: TimeInterval {
        onTime.timeIntervalSince(offTime)
    }
    
    var taxiOutTime: TimeInterval {
        offTime.timeIntervalSince(outTime)
    }
    
    var taxiInTime: TimeInterval {
        inTime.timeIntervalSince(onTime)
    }
    
    // Formatted display strings
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    var formattedOutTime: String {
        formatTime(outTime)
    }
    
    var formattedOffTime: String {
        formatTime(offTime)
    }
    
    var formattedOnTime: String {
        formatTime(onTime)
    }
    
    var formattedInTime: String {
        formatTime(inTime)
    }
    
    var formattedBlockTime: String {
        formatHoursMinutes(blockTime)
    }
    
    var formattedFlightTime: String {
        formatHoursMinutes(flightTime)
    }
    
    var formattedTaxiOutTime: String {
        formatHoursMinutes(taxiOutTime)
    }
    
    var formattedTaxiInTime: String {
        formatHoursMinutes(taxiInTime)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        return formatter.string(from: date) + "z"
    }
    
    private func formatHoursMinutes(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}
