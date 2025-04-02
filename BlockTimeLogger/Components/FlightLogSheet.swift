//
//  FlightLogSheet.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import SwiftUI

struct FlightLogSheet: View {
    let flights: [Flight]
    @Binding var sheetHeight: CGFloat
    @Binding var isExpanded: Bool
    let initialHeight: CGFloat

    private var maxHeight: CGFloat {
        UIScreen.main.bounds.height * 0.7
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .padding(.top, 8)
                .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 16) {
                    // Only show latest flight when collapsed
                    if !isExpanded {
                        FlightLogOverview(flight: flights.first!)
                            .padding(.horizontal)
                    } else {
                        // Show all flights when expanded
                        ForEach(flights) { flight in
                            FlightLogOverview(flight: flight)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom) // Extra padding at bottom
            }
        }
        .frame(height: sheetHeight)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newHeight = sheetHeight - value.translation.height
                    sheetHeight = min(max(newHeight, initialHeight), maxHeight)
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        if value.translation.height < -100 {
                            // Swipe up - expand
                            sheetHeight = maxHeight
                            isExpanded = true
                        } else if value.translation.height > 100 {
                            // Swipe down - collapse
                            sheetHeight = initialHeight
                            isExpanded = false
                        } else {
                            // Snap to nearest
                            sheetHeight = sheetHeight > (initialHeight + maxHeight) / 2 ? maxHeight : initialHeight
                            isExpanded = sheetHeight == maxHeight
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
    let flights: [Flight] = FlightDataService.shared.generateMockFlights(count: 20)

    FlightLogSheet(flights: flights, sheetHeight: .constant(700), isExpanded: .constant(true), initialHeight: 100)
}
