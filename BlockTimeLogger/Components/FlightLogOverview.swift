//
//  FlightLogOverview.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/3/2025.
//

import SwiftUI

struct FlightLogOverview: View {
  let flight: Flight
  @State private var tagsHeight: CGFloat = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Top row
      HStack {
        Text(flight.formattedDate)
          .font(.subheadline)
          .foregroundColor(Color("SlateGray"))

        Spacer()

        Image(systemName: "airplane")
          .foregroundColor(Color("SteelGray"))

        Spacer()

        Text("\(flight.aircraft?.registration ?? "") • \(flight.aircraft?.type ?? "")")
          .font(.subheadline)
          .lineLimit(1)
          .foregroundColor(Color("SlateGray"))
      }

      // Main flight info
      HStack(alignment: .top, spacing: 0) {
        VStack(alignment: .leading) {
          Text(flight.departureAirportICAO)
            .font(.title2)
            .bold()
          Text(flight.formattedOutTime)
            .font(.subheadline)
            .foregroundColor(Color("SteelGray"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .center) {
          Text(flight.formattedBlockTime)
            .font(.title2)
            .bold()
          Text(flight.flightNumber)
            .font(.subheadline)
            .foregroundColor(Color("SteelGray"))
        }
        .frame(maxWidth: .infinity)

        VStack(alignment: .trailing) {
          Text(flight.arrivalAirportICAO)
            .font(.title2)
            .bold()
          Text(flight.formattedInTime)
            .font(.subheadline)
            .foregroundColor(Color("SteelGray"))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
      }

      // Tags section
      ZStack {
        FlowLayout(spacing: 6) {
          Text("PIC: \(flight.isSelf ? "Self" : flight.pilotInCommand)")
            .tagStyle(color: FlightTag.pic.color)

          ForEach(flight.tags.filter { $0 != .pic }, id: \.self) { tag in
            Text(tag.displayName)
              .tagStyle(color: tag.color)
          }

          switch flight.operatingCapacity {
          case .p1:
            Text("P1")
              .tagStyle(color: OperatingCapacity.p1.color)
          case .p1us:
            Text("P1 U/S")
              .tagStyle(color: OperatingCapacity.p1us.color)
          case .p2:
            Text("P2")
              .tagStyle(color: OperatingCapacity.p2.color)
          case .p2x:
            Text("P2X")
              .tagStyle(color: OperatingCapacity.p2x.color)
          case .put:
            Text("P U/T")
              .tagStyle(color: OperatingCapacity.put.color)
          }
        }
        .background(
          GeometryReader { geometry in
            Color.clear
              .preference(
                key: ViewHeightKey.self,
                value: geometry.size.height
              )
          }
        )
      }
      .frame(minHeight: tagsHeight)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
        .shadow(color: Color("SteelGray").opacity(0.1), radius: 3, x: 0, y: 1)
    )
    .onPreferenceChange(ViewHeightKey.self) { height in
      tagsHeight = height ?? 0
    }
  }
}

// Helper for tag height measurement
struct ViewHeightKey: PreferenceKey {
  static var defaultValue: CGFloat? = nil
  static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
    value = value ?? nextValue()
  }
}

// Tag style extension
extension View {
  func tagStyle(color: Color) -> some View {
    font(.caption)
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .background(
        Capsule()
          .fill(color.opacity(0.2))
      )
      .foregroundColor(color)
  }
}

// Flow layout implementation
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

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
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
    .padding()
    .background(Color("CloudWhite"))
}
