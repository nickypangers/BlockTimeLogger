//
//  AircraftSection.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 5/4/2025.
//

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
                    switch flight.position {
                    case .captain:
                        Text("CN")
                            .tagStyle(color: FlightTag.captain.color)
                    case .firstOfficer:
                        Text("FO")
                            .tagStyle(color: FlightTag.firstOfficer.color)
                    case .secondOfficer:
                        Text("SO")
                            .tagStyle(color: FlightTag.secondOfficer.color)
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
    FlightAircraftSection(
        flight: .constant(FlightDataService().generateMockFlights(count: 1)[0]),
        isEditing: true
    )
}
