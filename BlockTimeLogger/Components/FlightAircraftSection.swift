//
//  AircraftSection.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 5/4/2025.
//

import Foundation
import SwiftUI

struct FlightAircraftSection: View {
  @Binding var flight: Flight
  var isEditing: Bool
  @State private var showAircraftSearch = false

  private let db = LocalDatabase.shared

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("AIRCRAFT")
        .font(.caption)
        .foregroundColor(.secondary)

      if isEditing {
        aircraftSelection()
        pilotInformation()
        roleConfiguration()
      } else {
        HStack(spacing: 12) {
          Text(flight.aircraft?.registration ?? "")
            .font(.system(size: 16, weight: .semibold))
          Text("•")
            .foregroundColor(Color(.systemGray2))
          Text(flight.aircraft?.type ?? "")
            .font(.system(size: 16))
            .foregroundColor(Color(.systemGray))
        }

        // Tag display
        FlowLayout(spacing: 6) {
          Text("PIC: \(flight.isSelf ? "Self" : flight.pilotInCommand)")
            .tagStyle(color: FlightTag.pic.color)

          if flight.isPF {
            Text("PF")
              .tagStyle(color: FlightTag.pf.color)
          }

          if flight.isIFR {
            Text("IFR")
              .tagStyle(color: FlightTag.ifr.color)
          } else if flight.isVFR {
            Text("VFR")
              .tagStyle(color: FlightTag.vfr.color)
          }

          // Position tag
          let positionTag: FlightTag = {
            let pos = flight.position as Flight.Position
            switch pos {
            case .captain: return .captain
            case .firstOfficer: return .firstOfficer
            case .secondOfficer: return .secondOfficer
            }
          }()
          Text(positionTag.displayName)
            .tagStyle(color: positionTag.color)

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
        .padding(.top, 4)
      }
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
    .sheet(isPresented: $showAircraftSearch) {
      AircraftSearchSheet(
        selectedAircraft: Binding(
          get: { flight.aircraft },
          set: { newAircraft in
            if let aircraft = newAircraft {
              flight.aircraft = aircraft
              flight.aircraftId = aircraft.id
            }
          }
        ))
    }
  }

  @ViewBuilder
  private func aircraftSelection() -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("AIRCRAFT")
        .font(.system(size: 11, weight: .bold))
        .foregroundColor(Color(.systemGray))

      Button {
        showAircraftSearch = true
      } label: {
        HStack {
          if let aircraft = flight.aircraft {
            Text("\(aircraft.registration) - \(aircraft.type)")
              .font(.system(size: 16, weight: .medium))
          } else {
            Text("Select Aircraft")
              .font(.system(size: 16))
              .foregroundColor(.secondary)
          }
          Spacer()
          Image(systemName: "chevron.right")
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Color(.systemGray4), lineWidth: 1)
        )
      }
    }
  }

  @ViewBuilder
  private func pilotInformation() -> some View {
    VStack(spacing: 12) {
      Toggle("Are you the PIC?", isOn: $flight.isSelf)

      if !flight.isSelf {
        VStack(alignment: .leading, spacing: 4) {
          Text("PILOT IN COMMAND")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color(.systemGray))
          TextField("PIC Name", text: $flight.pilotInCommand)
            .textInputAutocapitalization(.characters)
            .font(.system(size: 16, weight: .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
              RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
        }
      }
    }
  }

  @ViewBuilder
  private func roleConfiguration() -> some View {
    VStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text("Pilot Role")
          .sectionHeaderStyle()

        Picker("Pilot Role", selection: $flight.isPF) {
          Text("PF").tag(true)
          Text("PM").tag(false)
        }
        .pickerStyle(.segmented)
      }

      ifrVfrToggles()

      positionPicker()

      // Operating Capacity
      VStack(alignment: .leading, spacing: 4) {
        Text("Operating Capacity")
          .sectionHeaderStyle()

        Picker("Operating Capacity", selection: $flight.operatingCapacity) {
          ForEach(OperatingCapacity.allCases, id: \.self) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(.segmented)
      }
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .cornerRadius(10)
  }

  @ViewBuilder
  private func ifrVfrToggles() -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Flight Type")
        .sectionHeaderStyle()

      Picker(
        "Flight Type",
        selection: Binding(
          get: { flight.isIFR ? 0 : 1 },
          set: { newValue in
            flight.isIFR = newValue == 0
            flight.isVFR = newValue == 1
          }
        )
      ) {
        Text("IFR").tag(0)
        Text("VFR").tag(1)
      }
      .pickerStyle(.segmented)
    }
  }

  @ViewBuilder
  private func positionPicker() -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Position")
        .sectionHeaderStyle()

      Picker("Position", selection: $flight.position) {
        ForEach(Flight.Position.allCases, id: \.self) { position in
          Text(position.rawValue).tag(position)
        }
      }
      .pickerStyle(.segmented)
    }
  }
}

#Preview {
  let mockFlight = Flight(
    id: UUID(),
    flightNumber: "TEST123",
    date: Date(),
    aircraftId: 0,
    departureAirportId: 1,
    arrivalAirportId: 2,
    pilotInCommand: "John Doe",
    isSelf: true,
    isPF: true,
    isIFR: true,
    isVFR: false,
    position: .captain,
    operatingCapacity: .p1,
    outTime: Date(),
    offTime: Date().addingTimeInterval(3600),
    onTime: Date().addingTimeInterval(7200),
    inTime: Date().addingTimeInterval(8100),
    notes: nil,
    userId: 1
  )

  FlightAircraftSection(
    flight: .constant(mockFlight),
    isEditing: true
  )
}
