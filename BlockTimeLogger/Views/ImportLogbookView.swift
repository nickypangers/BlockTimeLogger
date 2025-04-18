//
//  ImportLogbookView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 19/4/2025.
//

import SwiftUI

struct ImportLogbookView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logText: String = ""
    @State private var isImporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var importedCount = 0
    @FocusState private var isTextEditorFocused: Bool

    @StateObject var homeViewModel: HomeViewModel
    
    private let importService = ImportService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import Flight Log")
                        .font(.title2)
                        .bold()
                    
                    Text("Paste your flight log data in the format shown below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Example format
                VStack(alignment: .leading, spacing: 4) {
                    Text("Example Format:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("""
                    Sector    Flt                    Block    UTC      UTC       UTC      UTC     Take       Auto
                    Date(UTC)   No.    Sector    Reg   Time   Off-Blk  Airborne  Landing   On-Blk Off  Land  Land     Commander
                    ----------  ----  --------  -----  -----  -------  --------  --------  -------  ---  ----  ----  -------------------
                    2024/10/01  810   HKG YVR   B-KQY  11:33  08:09    08:24     19:36     19:42     0     0    N     SO KYA
                    """)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Text editor
                TextEditor(text: $logText)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .focused($isTextEditorFocused)
                
                // Import button
                Button {
                    importFlights()
                } label: {
                    if isImporting {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("Importing...")
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Import Flights")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(logText.isEmpty || isImporting)
                .padding(.horizontal)
                
                if importedCount > 0 {
                    Text("Successfully imported \(importedCount) flights")
                        .foregroundColor(.green)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Import Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .onTapGesture {
            isTextEditorFocused = false
        }
    }
    
    private func importFlights() {
        isImporting = true
        importedCount = 0
        
        // Parse flights using ImportService
        let flights = importService.importFlights(from: logText)
        
        do {
//            try LocalDatabase.shared.createMultipleFlights(flights)
            for flight in flights {
                try LocalDatabase.shared.createFlight(flight)
                importedCount += 1
            }
            homeViewModel.loadFlights()
        } catch {
            errorMessage = "Error importing flights: \(error.localizedDescription)"
            showError = true
            return
        }

        isImporting = false
        
        // Show success message or error
        if importedCount == 0 {
            errorMessage = "No valid flights found in the provided data"
            showError = true
        }
    }
}

#Preview {
    ImportLogbookView(homeViewModel: HomeViewModel())
}
