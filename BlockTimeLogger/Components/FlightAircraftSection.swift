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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AIRCRAFT")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isEditing {
                aircraftRegistrationAndType()
                
                pilotInformation()
                
                roleConfiguration()
            } else {
                HStack(spacing: 12) {
                    Text(flight.aircraftRegistration)
                        .font(.system(size: 16, weight: .semibold))
                    Text("•")
                        .foregroundColor(Color(.systemGray2))
                    Text(flight.aircraftType)
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
    }

    @ViewBuilder
    private func aircraftRegistrationAndType() -> some View {
        HStack(spacing: 16) {
            registrationField()
            typeField()
        }
    }
    
    @ViewBuilder
    private func registrationField() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("REGISTRATION")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(.systemGray))
            
            if isEditing {
                TextField("N12345", text: $flight.aircraftRegistration)
                    .aviationInputStyle()
                    .font(.system(size: 16, weight: .medium))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color(.systemGray4), lineWidth: 1)
                    )
            } else {
                Text(flight.aircraftRegistration)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
    
    @ViewBuilder
    private func typeField() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TYPE")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(.systemGray))
                .kerning(0.5)
            TextField("", text: $flight.aircraftType)
                .aviationInputStyle()
                .font(.system(size: 16, weight: .medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
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
            Toggle("Pilot Flying (PF)", isOn: $flight.isPF)
            
            ifrVfrToggles()
            
            positionPicker()
            
            // Operating Capacity
            VStack(alignment: .leading, spacing: 4) {
                Text("Operating Capacity")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(.systemGray))
                    .kerning(0.5)
                
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
        HStack {
            Toggle("IFR", isOn: $flight.isIFR)
                .onChange(of: flight.isIFR) {
                    if flight.isIFR { flight.isVFR = false }
                }
            
            Toggle("VFR", isOn: $flight.isVFR)
                .onChange(of: flight.isVFR) {
                    if flight.isVFR { flight.isIFR = false }
                }
        }
    }
    
    @ViewBuilder
    private func positionPicker() -> some View {
        Picker("Position", selection: $flight.position) {
            ForEach(Flight.Position.allCases, id: \.self) { position in
                Text(position.rawValue).tag(position)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    let mockFlight = Flight(
        id: UUID(),
        flightNumber: "TEST123",
        date: Date(),
        aircraftRegistration: "N12345",
        aircraftType: "B737",
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
