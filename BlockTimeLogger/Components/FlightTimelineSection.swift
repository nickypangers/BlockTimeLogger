//
//  FlightTimelineView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 6/4/2025.
//
import SwiftUI

struct FlightTimelineSection: View {
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
    
    struct TimelineEventView: View {
        let eventType: FlightEventType
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
}

#Preview {
    @Previewable @State var isEditing = false
    let flight = FlightDataService().generateMockFlights(count: 1)[0]
    let viewModel = FlightDetailViewModel(flight: flight)
    
    VStack {
        Button {
            isEditing.toggle()
        } label: {
            Text("Toggle")
        }
        FlightTimelineSection(flight: .constant(viewModel.draftFlight), isEditing: isEditing) {
            event in
            switch event {
            case .out: viewModel.activePicker = .out
            case .off: viewModel.activePicker = .off
            case .on: viewModel.activePicker = .on
            case .in: viewModel.activePicker = .in
            }
        }
    }
}
