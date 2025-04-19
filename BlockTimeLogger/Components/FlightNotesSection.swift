//
//  FlightNotesSection.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 6/4/2025.
//

import SwiftUI

struct FlightNotesSection: View {
    @Binding var flight: Flight
    @State private var notesText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES")
                .font(.caption)
                .foregroundColor(.secondary)

            TextEditor(text: $notesText)
                .frame(minHeight: 100)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .onAppear {
                    notesText = flight.notes ?? ""
                }
                .onChange(of: notesText) { newValue in
                    flight.notes = newValue.isEmpty ? nil : newValue
                }
        }
        .padding(.horizontal)
    }
}

#Preview {
    FlightNotesSection(flight: .constant(FlightDataService().generateMockFlights(count: 1)[0]))
}
