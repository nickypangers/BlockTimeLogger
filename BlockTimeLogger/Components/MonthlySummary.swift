//
//  MonthlySummary.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 3/4/2025.
//

import SwiftUI

struct MonthlySummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Summary")
                .font(.headline)

            HStack {
                StatisticCard(value: "42.5", label: "Block Hours", systemImage: "clock")
                StatisticCard(value: "18", label: "Flights", systemImage: "airplane")
            }

            HStack {
                StatisticCard(value: "12", label: "Landings", systemImage: "airplane.arrival")
                StatisticCard(value: "6", label: "Night Hours", systemImage: "moon.stars")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

struct StatisticCard: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: systemImage)
                Text(value)
                    .font(.title3.bold())
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
    }
}

#Preview {
    MonthlySummary()
}
