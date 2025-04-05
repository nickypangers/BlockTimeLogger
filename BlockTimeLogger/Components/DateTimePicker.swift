//
//  DateTimePicker.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import SwiftUI

struct DateTimePicker: View {
    @Binding var selection: Date

    var body: some View {
        NavigationStack {
            DatePicker(
                "Select Time",
                selection: $selection,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .navigationTitle("Edit Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Dismisses the sheet
                    }
                }
            }
            .padding()
        }
    }
}
