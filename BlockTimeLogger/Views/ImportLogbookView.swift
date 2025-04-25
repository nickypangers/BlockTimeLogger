//
//  ImportLogbookView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 19/4/2025.
//

import SwiftUI

struct ImportLogbookView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool
    @StateObject var homeViewModel: HomeViewModel
    @StateObject private var importViewModel = ImportViewModel()
    @State private var showColumnMapping = false
    
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
                // VStack(alignment: .leading, spacing: 4) {
                //     Text("Example Format:")
                //         .font(.caption)
                //         .foregroundColor(.secondary)
                    
                //     Text("""
                //     Sector    Flt                    Block    UTC      UTC       UTC      UTC     Take       Auto
                //     Date(UTC)   No.    Sector    Reg   Time   Off-Blk  Airborne  Landing   On-Blk Off  Land  Land     Commander
                //     ----------  ----  --------  -----  -----  -------  --------  --------  -------  ---  ----  ----  -------------------
                //     2024/10/01  ABC810   VHHH CYVR   B-AAA  11:33  08:09    08:24     19:36     19:42     0     0    N     APPLESEED J
                //     """)
                //     .font(.caption)
                //     .foregroundColor(.secondary)
                //     .padding(8)
                //     .background(Color(.systemGray6))
                //     .cornerRadius(8)
                // }
                // .padding(.horizontal)
                
                // Text editor
                TextEditor(text: $importViewModel.logText)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .focused($isTextEditorFocused)
                
                // Column mapping button
                Button {
                    importViewModel.extractSampleRow()
                    showColumnMapping = true
                } label: {
                    HStack {
                        Image(systemName: "tablecells")
                        Text("Map Columns")
                        if !importViewModel.isMappingValid {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                
                // Import button
                Button {
                    importFlights()
                } label: {
                    if importViewModel.isImporting {
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
                .disabled(importViewModel.logText.isEmpty || importViewModel.isImporting || !importViewModel.isMappingValid)
                .padding(.horizontal)
                
                if importViewModel.importedCount > 0 {
                    Text("Successfully imported \(importViewModel.importedCount) flights")
                        .foregroundColor(.green)
                        .padding(.top)
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Import Error", isPresented: $importViewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importViewModel.errorMessage)
            }
            .sheet(isPresented: $showColumnMapping) {
                ColumnMapper(viewModel: importViewModel)
            }
        }
        .onTapGesture {
            isTextEditorFocused = false
        }
    }
    
    private func importFlights() {
        if importViewModel.parseAndMatchFlights() {
            dismiss()
            
            // Present confirmation view with the mapped flights from the ViewModel
            let confirmationView = ImportLogbookConfirmView(
                flights: importViewModel.flights,
                homeViewModel: homeViewModel,
                importViewModel: importViewModel
            )
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(UIHostingController(rootView: confirmationView), animated: true)
            }
        }
    }
}

#Preview {
    ImportLogbookView(homeViewModel: HomeViewModel())
}
