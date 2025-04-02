//
//  FlightLogSheet.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import SwiftUI

struct FlightLogSheet: View {
    @Binding var sheetHeight: CGFloat
    @Binding var fullHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var showFlightSheet: Bool

    let flights: [FlightLogOverview] = [
        FlightLogOverview(flightNumber: "CPA 123", date: "20 MAR 2025", aircraft: "B-KPM • B77W", departure: "EDDF", arrival: "VHHH", duration: "11:06"),
        FlightLogOverview(flightNumber: "CPA 456", date: "19 MAR 2025", aircraft: "B-KPL • B77W", departure: "VHHH", arrival: "EDDF", duration: "10:45"),
        FlightLogOverview(flightNumber: "CPA 789", date: "18 MAR 2025", aircraft: "B-KPQ • B77W", departure: "EDDF", arrival: "KJFK", duration: "12:30")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(flights.indices, id: \.self) { index in
                    flights[index]
                }
            }
            .padding()
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollViewHeightKey.self, value: geometry.size.height)
                }
            )
        }
        .frame(height: sheetHeight)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .overlay(
            VStack {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(Color(.systemGray3))
                    .padding(8)
                Spacer()
            }
        )
        .onPreferenceChange(ScrollViewHeightKey.self) { height in
            fullHeight = min(height, UIScreen.main.bounds.height * 0.8)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newHeight = fullHeight - value.translation.height
                    sheetHeight = min(max(newHeight, 200), fullHeight)
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        if value.translation.height < -100 {
                            sheetHeight = fullHeight
                            isExpanded = true
                        } else if value.translation.height > 100 {
                            showFlightSheet = false
                        } else {
                            sheetHeight = isExpanded ? fullHeight : 200
                        }
                    }
                }
        )
    }
}

struct ScrollViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    FlightLogSheet(sheetHeight: .constant(400), fullHeight: .constant(400), isExpanded: .constant(true), showFlightSheet: .constant(true))
}
