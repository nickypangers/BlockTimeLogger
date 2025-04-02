//
//  FlightLogOverview.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/3/2025.
//

import SwiftUI
import WrappingHStack

struct FlightLogOverview: View {
    let flight: Flight
        
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(flight.formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    
                Spacer()
                    
                Image(systemName: "airplane")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                Spacer()
                    
                Text("\(flight.aircraftRegistration) • \(flight.aircraftType)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(.primary.opacity(0.8))
                
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(flight.departureAirport)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        
                    Text("1234z")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                    
                Spacer()
                    
                VStack(spacing: 4) {
                    Text(flight.formattedBlockTime)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        
                    Text(flight.flightNumber)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                    
                Spacer()
                    
                VStack(alignment: .trailing) {
                    Text(flight.arrivalAirport)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        
                    Text("0123z")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
                
            FlowLayout(spacing: 6) {
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
                Text("PIC: \(flight.isSelf ? "Self" : flight.pilotInCommand)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill)))
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
                Text("P2X")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemFill))
                    )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .foregroundColor(.white)
    }
}

// Flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 && lineWidth > 0 {
                totalHeight += lineHeight + spacing
                totalWidth = max(totalWidth, lineWidth)
                lineWidth = 0
                lineHeight = 0
            }
            
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        totalHeight += lineHeight
        totalWidth = max(totalWidth, lineWidth - spacing)
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var point = bounds.origin
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if point.x + size.width > bounds.maxX && point.x > bounds.minX {
                point.x = bounds.minX
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(at: point, proposal: .unspecified)
            point.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    FlightLogOverview(flight: FlightDataService.shared.generateMockFlights(count: 1)[0])
}
