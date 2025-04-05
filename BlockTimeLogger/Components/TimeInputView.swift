//
//  TimeInputView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 5/4/2025.
//

import SwiftUI

struct TimeInputView: View {
    @State private var timeString = ""
    @State private var utcDate: Date?
    @State private var showError = false
    
    var body: some View {
        VStack {
            TextField("Enter time (HHmm)", text: $timeString)
                .keyboardType(.numberPad)
                .onChange(of: timeString) { _, newValue in
                    // Limit to 4 digits and validate as user types
                    if newValue.count > 4 {
                        timeString = String(newValue.prefix(4))
                    }
                    
                    // Try to convert when we have exactly 4 digits
                    if newValue.count == 4 {
                        convertTimeStringToUTCDate()
                    } else {
                        utcDate = nil
                    }
                }
                .padding()
                .border(Color.gray, width: 1)
            
            if let date = utcDate {
                Text("UTC Date: \(formattedDate(date))")
                    .padding()
            }
            
            if showError {
                Text("Invalid time format. Use HHmm (0000-2359)")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private func convertTimeStringToUTCDate() {
        guard timeString.count == 4,
              let hours = Int(timeString.prefix(2)),
              let minutes = Int(timeString.suffix(2)),
              hours >= 0 && hours < 24,
              minutes >= 0 && minutes < 60
        else {
            showError = true
            utcDate = nil
            return
        }
        
        showError = false
        
        // Get current date components (year, month, day)
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        // Create new date with the entered time in UTC
        var newComponents = DateComponents()
        newComponents.year = components.year
        newComponents.month = components.month
        newComponents.day = components.day
        newComponents.hour = hours
        newComponents.minute = minutes
        newComponents.timeZone = TimeZone(identifier: "UTC")
        
        if let date = calendar.date(from: newComponents) {
            utcDate = date
        } else {
            showError = true
            utcDate = nil
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
        return formatter.string(from: date)
    }
}

struct TimeInputView_Previews: PreviewProvider {
    static var previews: some View {
        TimeInputView()
    }
}
