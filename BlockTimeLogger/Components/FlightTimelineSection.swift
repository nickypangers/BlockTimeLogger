//
//  FlightTimelineView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 6/4/2025.
//
import SwiftUI

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

struct TimelineEventView<ViewModel: ObservableObject>: View {
    let eventType: FlightTimelineSection.FlightEventType
    @Binding var time: Date?
    var duration: String? = nil
    let isEditing: Bool
    let onTap: () -> Void
    @State private var timeString: String = ""
    @ObservedObject var viewModel: ViewModel

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
            .onTapGesture {
                onTap()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(eventType.title)
                    .font(.system(size: 14, weight: .semibold))
                if isEditing {
                    TextField("HHMM", text: $timeString)
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, design: .monospaced))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .onChange(of: timeString) { _, newValue in
                            validateAndUpdateTime(newValue)
                        }
                        .onAppear {
                            updateTimeString()
                        }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(time.map { formatZuluTime(time: $0) } ?? "----")
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

    private func updateTimeString() {
        guard let time = time else {
            timeString = ""
            return
        }

        var utcCalendar = Calendar.current
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!

        let components = utcCalendar.dateComponents([.hour, .minute], from: time)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        timeString = String(format: "%02d%02d", hour, minute)
    }

    private func validateAndUpdateTime(_ newValue: String) {
        // Limit to 4 digits
        if newValue.count > 4 {
            timeString = String(newValue.prefix(4))
            return
        }

        // Only allow digits
        guard newValue.allSatisfy({ $0.isNumber }) else {
            timeString = String(newValue.filter { $0.isNumber })
            return
        }

        // Parse hours and minutes
        let hour: Int
        let minute: Int

        if newValue.count == 4 {
            hour = Int(newValue.prefix(2)) ?? 0
            minute = Int(newValue.suffix(2)) ?? 0
        } else if newValue.count == 3 {
            hour = Int(newValue.prefix(1)) ?? 0
            minute = Int(newValue.suffix(2)) ?? 0
        } else if newValue.count == 2 {
            hour = Int(newValue) ?? 0
            minute = 0
        } else if newValue.count == 1 {
            hour = Int(newValue) ?? 0
            minute = 0
        } else {
            hour = 0
            minute = 0
        }

        // Validate
        guard hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 else {
            return
        }

        // Update bound time if valid
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let flightDate = calendar.startOfDay(for: Date())
        var components = calendar.dateComponents([.year, .month, .day], from: flightDate)
        components.hour = hour
        components.minute = minute
        components.second = 0
        components.timeZone = TimeZone(identifier: "UTC")

        if let newDate = calendar.date(from: components) {
            time = newDate
            if let detailViewModel = viewModel as? FlightDetailViewModel {
                detailViewModel.updateTime(newDate, for: eventType)
            } else if let addViewModel = viewModel as? AddFlightViewModel {
                addViewModel.updateTime(newDate, for: eventType)
            }
        }
    }

    private func formatZuluTime(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "HHmm"
        return "\(formatter.string(from: time))z"
    }
}

struct FlightTimelineSection: View {
    @Binding var flight: Flight
    let isEditing: Bool
    var onEventTap: ((FlightEventType) -> Void)?
    @ObservedObject var viewModel: FlightDetailViewModel

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
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                TimelineEventView(
                    eventType: FlightEventType.out,
                    time: Binding(
                        get: { flight.outTime },
                        set: { flight.outTime = $0 ?? flight.outTime }
                    ),
                    isEditing: isEditing,
                    onTap: { onEventTap?(.out) },
                    viewModel: viewModel
                )

                TimelineConnectionView(duration: flight.formattedTaxiOutTime, label: "TAXI OUT")

                TimelineEventView(
                    eventType: FlightEventType.off,
                    time: Binding(
                        get: { flight.offTime },
                        set: { flight.offTime = $0 ?? flight.outTime }
                    ),
                    isEditing: isEditing,
                    onTap: { onEventTap?(.off) },
                    viewModel: viewModel
                )

                TimelineConnectionView(
                    duration: flight.formattedFlightTime, label: "FLIGHT TIME", isHighlighted: true
                )

                TimelineEventView(
                    eventType: FlightEventType.on,
                    time: Binding(
                        get: { flight.onTime },
                        set: { flight.onTime = $0 ?? flight.onTime }
                    ),
                    isEditing: isEditing,
                    onTap: { onEventTap?(.on) },
                    viewModel: viewModel
                )

                TimelineConnectionView(duration: flight.formattedTaxiInTime, label: "TAXI IN")

                TimelineEventView(
                    eventType: FlightEventType.in,
                    time: Binding(
                        get: { flight.inTime },
                        set: { flight.inTime = $0 ?? flight.inTime }
                    ),
                    duration: flight.formattedBlockTime,
                    isEditing: isEditing,
                    onTap: { onEventTap?(.in) },
                    viewModel: viewModel
                )
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .padding(.horizontal)
    }
}

struct AddFlightTimelineSection: View {
    @Binding var flight: Flight
    let isEditing: Bool
    @ObservedObject var viewModel: AddFlightViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FLIGHT TIMELINE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                TimelineEventView(
                    eventType: FlightTimelineSection.FlightEventType.out,
                    time: Binding(
                        get: { flight.outTime },
                        set: { flight.outTime = $0 ?? flight.outTime }
                    ),
                    isEditing: isEditing,
                    onTap: {},
                    viewModel: viewModel
                )

                TimelineConnectionView(duration: flight.formattedTaxiOutTime, label: "TAXI OUT")

                TimelineEventView(
                    eventType: FlightTimelineSection.FlightEventType.off,
                    time: Binding(
                        get: { flight.offTime },
                        set: { flight.offTime = $0 ?? flight.outTime }
                    ),
                    isEditing: isEditing,
                    onTap: {},
                    viewModel: viewModel
                )

                TimelineConnectionView(
                    duration: flight.formattedFlightTime, label: "FLIGHT TIME", isHighlighted: true
                )

                TimelineEventView(
                    eventType: FlightTimelineSection.FlightEventType.on,
                    time: Binding(
                        get: { flight.onTime },
                        set: { flight.onTime = $0 ?? flight.onTime }
                    ),
                    isEditing: isEditing,
                    onTap: {},
                    viewModel: viewModel
                )

                TimelineConnectionView(duration: flight.formattedTaxiInTime, label: "TAXI IN")

                TimelineEventView(
                    eventType: FlightTimelineSection.FlightEventType.in,
                    time: Binding(
                        get: { flight.inTime },
                        set: { flight.inTime = $0 ?? flight.inTime }
                    ),
                    duration: flight.formattedBlockTime,
                    isEditing: isEditing,
                    onTap: {},
                    viewModel: viewModel
                )
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .padding(.horizontal)
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
        FlightTimelineSection(
            flight: .constant(viewModel.draftFlight), isEditing: isEditing, viewModel: viewModel
        )
    }
}
