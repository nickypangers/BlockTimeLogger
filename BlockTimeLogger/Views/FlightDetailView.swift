//
//  FlightDetailView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

// FlightDetailView.swift
import SwiftUI

struct FlightDetailView: View {
    @State private var isEditing = false
    @State private var draftFlight: Flight
    @Environment(\.dismiss) private var dismiss
    private let originalFlight: Flight
    
    @State private var activePicker: PickerType?
    private enum PickerType: Identifiable {
        case date, out, off, on, `in`
        var id: Self { self }
    }
    
    init(flight: Flight) {
        self.originalFlight = flight
        self._draftFlight = State(initialValue: flight)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with edit toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if isEditing {
                            TextField("Flight Number", text: $draftFlight.flightNumber)
                                .font(.largeTitle.bold())
                        } else {
                            Text(draftFlight.flightNumber)
                                .font(.largeTitle.bold())
                        }
                            
                        if isEditing {
                            DatePicker("Flight Date", selection: $draftFlight.date, displayedComponents: .date)
                                .labelsHidden()
                        } else {
                            Text(draftFlight.formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                        
                    Spacer()
                        
                    if !isEditing {
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                                .padding(8)
                                .background(Circle().fill(Color.blue.opacity(0.1)))
                        }
                    }
                }
                .padding(.horizontal)
                    
                // Aircraft Information
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        if isEditing {
                            // Registration Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("REGISTRATION")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(.systemGray))
                                    .kerning(0.5)
                                TextField("", text: $draftFlight.aircraftRegistration)
                                    .textInputAutocapitalization(.characters)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                                
                            // Type Field
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TYPE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(.systemGray))
                                    .kerning(0.5)
                                TextField("", text: $draftFlight.aircraftType)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        } else {
                            Text(draftFlight.aircraftRegistration)
                                .font(.system(size: 16, weight: .semibold))
                            Text("•")
                                .foregroundColor(Color(.systemGray2))
                            Text(draftFlight.aircraftType)
                                .font(.system(size: 16))
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                        
                    // Airport Cards - Now in a VStack for leading alignment
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            AirportCard(
                                type: "DEPARTURE",
                                icao: $draftFlight.departureAirport,
                                time: draftFlight.formattedOutTime,
                                isEditing: isEditing
                            )
                            
                            AirportCard(
                                type: "ARRIVAL",
                                icao: $draftFlight.arrivalAirport,
                                time: draftFlight.formattedInTime,
                                isEditing: isEditing
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Colorful Timeline
                    FlightTimelineView(flight: $draftFlight, isEditing: isEditing) { event in
                        switch event {
                        case .out: activePicker = .out
                        case .off: activePicker = .off
                        case .on: activePicker = .on
                        case .in: activePicker = .in
                        }
                    }
                    .padding(.horizontal)
                    
                    // Time Summary Cards - Centered as before
                    VStack(spacing: 16) {
                        Text("TIME SUMMARY")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 16) {
                            TimeCard(title: "BLOCK TIME", value: draftFlight.formattedBlockTime, icon: "clock", color: .blue)
                            TimeCard(title: "FLIGHT TIME", value: draftFlight.formattedFlightTime, icon: "airplane", color: .green)
                        }
                        
                        HStack(spacing: 16) {
                            TimeCard(title: "TAXI OUT", value: draftFlight.formattedTaxiOutTime, icon: "arrow.up", color: .orange)
                            TimeCard(title: "TAXI IN", value: draftFlight.formattedTaxiInTime, icon: "arrow.down", color: .purple)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Pilot in Command Field
                    if isEditing {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("PILOT IN COMMAND")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(.systemGray))
                                    .kerning(0.5)
                                
                                Spacer()
                                
                                Button(action: {
                                    draftFlight.isSelf = !draftFlight.isSelf
                                    if draftFlight.isSelf {
                                        draftFlight.pilotInCommand = "Self"
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: draftFlight.isSelf ? "checkmark.square.fill" : "square")
                                            .foregroundColor(draftFlight.isSelf ? .blue : .gray)
                                        Text("Self")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            TextField("", text: $draftFlight.pilotInCommand)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                )
                                .disabled(draftFlight.isSelf)
                                .foregroundColor(draftFlight.isSelf ? .secondary : .primary)
                                .overlay(
                                    HStack {
                                        Text(draftFlight.isSelf ? "Self (PIC)" : "Enter name")
                                            .foregroundColor(Color(.systemGray3))
                                            .font(.system(size: 16))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .opacity(draftFlight.pilotInCommand.isEmpty ? 1 : 0)
                                )
                        }
                    } else {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("PIC: \(draftFlight.isSelf ? "Self" : draftFlight.pilotInCommand)")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(isEditing ? "Edit Flight" : "Flight Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        draftFlight = originalFlight
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validateTimes() {
                            isEditing = false
                            // Save to your data store
                        } else {
                            showTimeValidationAlert()
                        }
                    }
                    .bold()
                }
            }
        }
        .sheet(item: $activePicker) { picker in
            DateTimePicker(selection: bindingForPicker(picker))
        }
    }
    
    // MARK: - Helper Functions

    private func bindingForPicker(_ picker: PickerType) -> Binding<Date> {
        switch picker {
        case .date: return $draftFlight.date
        case .out: return $draftFlight.outTime
        case .off: return $draftFlight.offTime
        case .on: return $draftFlight.onTime
        case .in: return $draftFlight.inTime
        }
    }
    
    private func validateTimes() -> Bool {
        return draftFlight.outTime < draftFlight.offTime &&
            draftFlight.offTime < draftFlight.onTime &&
            draftFlight.onTime < draftFlight.inTime
    }
    
    private func showTimeValidationAlert() {
        let alert = UIAlertController(
            title: "Invalid Time Sequence",
            message: "Times must follow: OUT → OFF → ON → IN with positive durations",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController
        {
            rootViewController.present(alert, animated: true)
        }
    }
}

// MARK: - Supporting Views

struct FlightTimelineView: View {
    @Binding var flight: Flight
    let isEditing: Bool
    var onEventTap: ((FlightEventType) -> Void)?
    
    enum FlightEventType {
        case out, off, on, `in`
        
        var icon: String {
            switch self {
            case .out: return "arrow.up.right.circle.fill"
            case .off: return "airplane.circle.fill"
            case .on: return "airplane.circle.fill"
            case .in: return "arrow.down.right.circle.fill"
            }
        }
        
        var title: String {
            switch self {
            case .out: return "OUT - WHEELS OFF"
            case .off: return "OFF - TAKEOFF"
            case .on: return "ON - LANDING"
            case .in: return "IN - WHEELS ON"
            }
        }
        
        var color: Color {
            switch self {
            case .out: return .blue
            case .off: return .green
            case .on: return .orange
            case .in: return .red
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FLIGHT TIMELINE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(spacing: 0) {
                TimelineEventView(eventType: .out, time: $flight.outTime, isEditing: isEditing) {
                    onEventTap?(.out)
                }
                
                TimelineConnectionView(duration: flight.formattedTaxiOutTime, label: "TAXI OUT")
                
                TimelineEventView(eventType: .off, time: $flight.offTime, isEditing: isEditing) {
                    onEventTap?(.off)
                }
                
                TimelineConnectionView(duration: flight.formattedFlightTime, label: "FLIGHT TIME", isHighlighted: true)
                
                TimelineEventView(eventType: .on, time: $flight.onTime, isEditing: isEditing) {
                    onEventTap?(.on)
                }
                
                TimelineConnectionView(duration: flight.formattedTaxiInTime, label: "TAXI IN")
                
                TimelineEventView(eventType: .in, time: $flight.inTime, duration: flight.formattedBlockTime, isEditing: isEditing) {
                    onEventTap?(.in)
                }
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
}

struct TimelineEventView: View {
    let eventType: FlightTimelineView.FlightEventType
    @Binding var time: Date
    var duration: String? = nil
    let isEditing: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(eventType.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: eventType.icon)
                    .foregroundColor(eventType.color)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(eventType.title)
                    .font(.system(size: 14, weight: .semibold))
                if isEditing {
                    DigitalTimeInput(time: $time)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatZuluTime(time: time))
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if let duration = duration {
                VStack(alignment: .trailing) {
                    Text("BLOCK TIME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    Text(duration)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func formatZuluTime(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "HHmm"
        return "\(formatter.string(from: time))z"
    }
}

struct TimelineConnectionView: View {
    let duration: String
    let label: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Rectangle()
                .fill(isHighlighted ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(width: 2)
                .padding(.leading, 19)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isHighlighted ? .blue : .secondary)
                Text(duration)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isHighlighted ? .blue : .primary)
            }
            
            Spacer()
        }
        .frame(height: 40)
        .padding(.leading, 12)
    }
}

struct AirportCard: View {
    let type: String
    @Binding var icao: String
    let time: String
    let isEditing: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(type)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
            
            if isEditing {
                TextField("ICAO", text: $icao)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
            } else {
                Text(icao)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }
            
            Text(time)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct TimeCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

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

#Preview {
    NavigationStack {
        FlightDetailView(flight: FlightDataService.shared.generateMockFlights(count: 1).first!)
    }
}
