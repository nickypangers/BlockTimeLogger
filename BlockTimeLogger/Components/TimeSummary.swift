//
//  TimeSummary+Fixed.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//
import SwiftUI

struct TimeSummary: View {
    enum TimeRange: String, CaseIterable {
        case monthly = "Monthly"
        case allTime = "All Time"
    }
    
    @State private var selectedTimeRange: TimeRange = .monthly
    @State private var isExpanded = false
    
    // Configuration
    let metrics: [MetricGroup]
    let iconColor = Color("SteelGray") // Using custom color from assets
    
    init(monthlyMetrics: MetricGroup, allTimeMetrics: MetricGroup) {
        self.metrics = [monthlyMetrics, allTimeMetrics]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            timeRangePicker
            summaryCards
        }
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var summaryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Primary metrics
            HStack(spacing: 12) {
                MetricCard(value: currentMetrics.blockHours,
                           label: "Block Hours",
                           icon: "clock",
                           iconColor: iconColor)
                MetricCard(value: currentMetrics.flights,
                           label: "Flights",
                           icon: "airplane",
                           iconColor: iconColor)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Secondary metrics
            if isExpanded {
                expandedMetrics
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            expandToggleButton
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var expandedMetrics: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(value: currentMetrics.landings,
                           label: "Landings",
                           icon: "airplane.arrival",
                           iconColor: iconColor)
                MetricCard(value: currentMetrics.nightHours,
                           label: "Night Hours",
                           icon: "moon.stars",
                           iconColor: iconColor)
            }
            
            HStack(spacing: 12) {
                MetricCard(value: currentMetrics.picHours,
                           label: "PIC Hours",
                           icon: "person.fill",
                           iconColor: iconColor)
                MetricCard(value: currentMetrics.crossCountryHours,
                           label: "XC Hours",
                           icon: "map.fill",
                           iconColor: iconColor)
            }
        }
        .padding(.horizontal)
    }
    
    private var expandToggleButton: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(isExpanded ? "Show Less" : "Show More")
                    .font(.caption)
                    .foregroundColor(iconColor)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(iconColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    private var currentMetrics: MetricGroup {
        selectedTimeRange == .monthly ? metrics[0] : metrics[1]
    }
}

struct MetricCard: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(value)
                    .font(.title3.bold())
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

#Preview {
    TimeSummary(
        monthlyMetrics: .sampleMonthly,
        allTimeMetrics: .sampleAllTime
    )
} 