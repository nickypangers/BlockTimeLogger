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
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedFormat: Export.ExportFormat = .pdf
    @State private var selectedDateRange: Export.DateRange = .allTime
    @State private var selectedStyle: Export.LogbookStyle = .hkcad
    @State private var isExporting = false
    @State private var showError = false
    @State private var exportedFileURL: URL?
    @State private var showPDFViewer = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(Export.ExportFormat.allCases, id: \.self) { format in
                            Label(format.rawValue, systemImage: format.icon)
                                .tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Date Range") {
                    Picker("Date Range", selection: $selectedDateRange) {
                        ForEach(Export.DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
                
                Section("Logbook Style") {
                    ForEach(Export.LogbookStyle.allCases, id: \.self) { style in
                        HStack {
                            Text(style.rawValue)
                            Spacer()
                            if selectedStyle == style {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedStyle = style
                        }
                        
                        Text(style.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: exportLogbook) {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text("Export Logbook")
                        }
                    }
                    .disabled(isExporting)
                }
            }
            .navigationTitle("Export Logbook")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Export Failed", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There was an error exporting your logbook. Please try again.")
            }
            .sheet(isPresented: $showPDFViewer) {
                if let url = exportedFileURL {
                    PDFViewer(url: url)
                }
            }
        }
    }
    
    private func exportLogbook() {
        isExporting = true
        
        // Get flights from view model
        let flights = homeViewModel.flights
        
        // Use ExportService to generate the file
        ExportService.shared.exportLogbook(
            flights: flights,
            style: selectedStyle,
            format: selectedFormat,
            dateRange: selectedDateRange
        ) { result in
            isExporting = false
            
            switch result {
            case .success(let url):
                if selectedFormat == .pdf {
                    // For PDF, show the viewer
                    exportedFileURL = url
                    showPDFViewer = true
                } else {
                    // For other formats, show share sheet
                    let activityVC = UIActivityViewController(
                        activityItems: [url],
                        applicationActivities: nil
                    )
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController
                    {
                        rootVC.present(activityVC, animated: true)
                    }
                }
            case .failure:
                showError = true
            }
        }
    }
    
    private func filterFlightsByDateRange(_ flights: [Flight], range: Export.DateRange) -> [Flight] {
        let calendar = Calendar.current
        let now = Date()
        
        switch range {
        case .lastMonth:
            let firstDayOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let firstDayOfLastMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth)!
            return flights.filter { $0.outTime >= firstDayOfLastMonth && $0.outTime < firstDayOfCurrentMonth }
            
        case .last3Months:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!
            return flights.filter { $0.outTime >= threeMonthsAgo }
            
        case .last6Months:
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
            return flights.filter { $0.outTime >= sixMonthsAgo }
            
        case .lastYear:
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return flights.filter { $0.outTime >= oneYearAgo }
            
        case .allTime:
            return flights
        }
    }
}

#Preview {
    ExportLogbookView()
}
