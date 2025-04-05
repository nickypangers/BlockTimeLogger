//
//  AirportCard.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import SwiftUI

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
                    .aviationInputStyle()
                    .multilineTextAlignment(.center)
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
