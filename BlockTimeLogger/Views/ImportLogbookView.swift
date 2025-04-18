//
//  TextImportView.swift
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
                
                // Import button
                Button {
                    isImporting = true
                } label: {
                    if isImporting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Import Flights")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(logText.isEmpty || isImporting)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    ImportLogbookView()
}
