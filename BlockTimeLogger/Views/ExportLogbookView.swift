//
//  ExportLogbookView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 18/4/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportLogbookView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedFormat: ExportFormat = .pdf
    @State private var selectedStyle: LogbookStyle = .hkcad
    @State private var dateRange: DateRange = .allTime
    @State private var isExporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum ExportFormat: String, CaseIterable, Identifiable {
        case pdf = "PDF Document"
        case csv = "CSV Spreadsheet"
        case excel = "Excel Spreadsheet"
        
        var id: String { rawValue }
        
        var fileExtension: String {
            switch self {
            case .pdf: return "pdf"
            case .csv: return "csv"
            case .excel: return "xlsx"
            }
        }
        
        var contentType: UTType {
            switch self {
            case .pdf: return .pdf
            case .csv: return .commaSeparatedText
            case .excel: return .spreadsheet
            }
        }
        
        var icon: String {
            switch self {
            case .pdf: return "doc.text.fill"
            case .csv: return "tablecells.fill"
            case .excel: return "tablecells.badge.ellipsis"
            }
        }
    }
    
    enum LogbookStyle: String, CaseIterable, Identifiable {
        case hkcad = "Hong Kong CAD"
        // case caa = "UK CAA"
        // case faa = "US FAA"
        // case easa = "European EASA"
        
        var id: String { rawValue }
        
        var description: String {
            switch self {
            case .hkcad: return "Civil Aviation Department of Hong Kong"
            // case .caa: return "Civil Aviation Authority of the United Kingdom"
            // case .faa: return "Federal Aviation Administration of the United States"
            // case .easa: return "European Union Aviation Safety Agency"
            }
        }
    }
    
    enum DateRange: String, CaseIterable, Identifiable {
        case lastMonth = "Last Month"
        case last3Months = "Last 3 Months"
        case last6Months = "Last 6 Months"
        case lastYear = "Last Year"
        case allTime = "All Time"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Logbook Style") {
                    ForEach(LogbookStyle.allCases) { style in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {                                
                                Text(style.rawValue)
                                
                                Spacer()
                                
                                if selectedStyle == style {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Text(style.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedStyle = style
                        }
                    }
                }
                
                Section("Export Format") {
                    ForEach(ExportFormat.allCases) { format in
                        HStack {
                            Image(systemName: format.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            
                            Text(format.rawValue)
                            
                            Spacer()
                            
                            if selectedFormat == format {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFormat = format
                        }
                    }
                }
                
                Section("Date Range") {
                    ForEach(DateRange.allCases) { range in
                        HStack {
                            Text(range.rawValue)
                            
                            Spacer()
                            
                            if dateRange == range {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dateRange = range
                        }
                    }
                }
                
                Section {
                    Button {
                        exportLogbook()
                    } label: {
                        HStack {
                            Spacer()
                            
                            if isExporting {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("Exporting...")
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Logbook")
                            }
                            
                            Spacer()
                        }
                    }
                    .disabled(isExporting)
                }
            }
            .navigationTitle("Export Logbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Export Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                viewModel.loadFlights()
            }
        }
    }
    
    private func exportLogbook() {
        isExporting = true
        
        ExportService.shared.exportLogbook(
            flights: viewModel.flights,
            style: selectedStyle,
            format: selectedFormat,
            dateRange: dateRange
        ) { result in
            isExporting = false
            
            switch result {
            case .success(let fileURL):
                // Share the file
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    ExportService.shared.shareFile(fileURL, from: rootVC)
                }
            case .failure(let error):
                errorMessage = "Failed to create export file: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

#Preview {
    ExportLogbookView()
} 