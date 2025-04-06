//
//  DigitalTimeInput.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//
import SwiftUI

struct DigitalTimeInput: View {
    @Binding var time: Date
    @State private var timeString: String = ""
    @State private var isInvalid: Bool = false
    
    var body: some View {
        TextField("HHMM", text: $timeString)
            .frame(width: 80)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 18, design: .monospaced))
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isInvalid ? Color.red : Color.gray, lineWidth: 1)
            )
            .onChange(of: timeString) {
                validateAndUpdateTime()
            }
            .onAppear {
                updateTimeString()
            }
    }
    
    private func updateTimeString() {
        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!
        
        let components = utcCalendar.dateComponents([.hour, .minute], from: time)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        timeString = String(format: "%02d%02d", hour, minute)
    }
    
    private func validateAndUpdateTime() {
        // Limit to 4 digits
        if timeString.count > 4 {
            timeString = String(timeString.prefix(4))
            return
        }
        
        // Only allow digits
        guard timeString.allSatisfy({ $0.isNumber }) else {
            timeString = String(timeString.filter { $0.isNumber })
            return
        }
        
        // Parse hours and minutes
        let hour: Int
        let minute: Int
        
        if timeString.count == 4 {
            hour = Int(timeString.prefix(2)) ?? 0
            minute = Int(timeString.suffix(2)) ?? 0
        } else if timeString.count == 3 {
            hour = Int(timeString.prefix(1)) ?? 0
            minute = Int(timeString.suffix(2)) ?? 0
        } else if timeString.count == 2 {
            hour = Int(timeString) ?? 0
            minute = 0
        } else if timeString.count == 1 {
            hour = Int(timeString) ?? 0
            minute = 0
        } else {
            hour = 0
            minute = 0
        }
        
        // Validate
        isInvalid = hour < 0 || hour > 23 || minute < 0 || minute > 59
        
        // Update bound time if valid
        if !isInvalid {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: time)
            components.hour = hour
            components.minute = minute
            components.timeZone = TimeZone(identifier: "UTC")
            
            if let newDate = calendar.date(from: components) {
                time = newDate
            }
        }
    }
}

#Preview {
    DigitalTimeInput(time: .constant(Date()))
}
