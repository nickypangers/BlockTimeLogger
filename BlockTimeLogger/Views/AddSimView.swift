//
//  AddSimView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/4/2025.
//

import SwiftUI

struct AddSimView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddSimViewModel()
    @StateObject var homeViewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Aircraft Details") {
                    TextField("Aircraft Type", text: $viewModel.sim.aircraftType)
                    TextField("Registration", text: $viewModel.sim.registration)
                    TextField("PIC", text: $viewModel.sim.pic)
                }
                
                Section("Session Details") {
                    DatePicker("Date", selection: $viewModel.sim.date, displayedComponents: .date)
                    VStack(alignment: .leading) {
                        Text("Operating Capacity")
                            .foregroundColor(.secondary)
                        Picker("Operating Capacity", selection: $viewModel.sim.operatingCapacity) {
                            ForEach(OperatingCapacity.simOptions, id: \.self) { capacity in
                                Text(capacity.rawValue).tag(capacity)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                Section("Time Details") {
                    HStack {
                        Text("Instrument Time")
                        Spacer()
                        TextField("Hours", value: $viewModel.sim.instrumentTime, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("hours")
                    }
                    
                    HStack {
                        Text("Simulator Time")
                        Spacer()
                        TextField("Hours", value: $viewModel.sim.simulatorTime, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("hours")
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: Binding(
                        get: { viewModel.sim.notes ?? "" },
                        set: { viewModel.sim.notes = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Add Sim Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validateSim() {
                            saveSim()
                            dismiss()
                        }
                    }
                }
            }
            .alert("Validation Error", isPresented: $viewModel.showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.validationMessage)
            }
        }
    }
    
    private func validateSim() -> Bool {
        guard !viewModel.sim.aircraftType.isEmpty else {
            viewModel.validationMessage = "Aircraft type is required"
            viewModel.showValidationAlert = true
            return false
        }
        
        guard !viewModel.sim.registration.isEmpty else {
            viewModel.validationMessage = "Registration is required"
            viewModel.showValidationAlert = true
            return false
        }
        
        guard !viewModel.sim.pic.isEmpty else {
            viewModel.validationMessage = "PIC is required"
            viewModel.showValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func saveSim() {
        do {
//            try LocalDatabase.shared.saveSim(viewModel.sim)
            print(viewModel.sim)
        } catch {
            print("Error saving sim: \(error)")
        }
    }
}

#Preview {
    AddSimView(homeViewModel: HomeViewModel())
}
