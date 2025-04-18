//
//  ExportService.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 18/4/2025.
//

import Foundation
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - Export Methods
    
    func exportLogbook(
        flights: [Flight],
        style: Export.LogbookStyle,
        format: Export.ExportFormat,
        dateRange: Export.DateRange,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // Filter flights based on date range
        let filteredFlights = filterFlightsByDateRange(flights, dateRange: dateRange)
        
        // Generate file based on format
        switch format {
        case .pdf:
            generatePDF(flights: filteredFlights, style: style, completion: completion)
        case .csv:
            generateCSV(flights: filteredFlights, style: style, completion: completion)
        case .excel:
            generateExcel(flights: filteredFlights, style: style, completion: completion)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func filterFlightsByDateRange(_ flights: [Flight], dateRange: Export.DateRange) -> [Flight] {
        let calendar = Calendar.current
        let now = Date()
        
        switch dateRange {
        case .lastMonth:
            // Get the first day of the current month
            let currentMonthComponents = calendar.dateComponents([.year, .month], from: now)
            let firstDayOfCurrentMonth = calendar.date(from: currentMonthComponents)!
            
            // Get the first day of the previous month
            let previousMonthComponents = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth)!
            let firstDayOfPreviousMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonthComponents))!
            
            // Get the first day of the current month (which is the end of the previous month)
            let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfPreviousMonth)!
            
            return flights.filter { flight in
                flight.outTime >= firstDayOfPreviousMonth && flight.outTime < firstDayOfNextMonth
            }
            
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
    
    private func generatePDF(flights: [Flight], style: Export.LogbookStyle, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileName = "\(style.rawValue)_Logbook.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // Create PDF document with landscape orientation
        let format = UIGraphicsPDFRendererFormat()
        
        // Set landscape orientation (A4 landscape: 297mm x 210mm)
        let pageWidth: CGFloat = 11.7 * 72.0 // 297mm
        let pageHeight: CGFloat = 8.3 * 72.0 // 210mm
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // Create PDF context with landscape orientation
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                // Set the page orientation to landscape
                context.cgContext.translateBy(x: 0, y: pageHeight)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                
                context.beginPage()
                
                // Calculate scaling factor based on A4 landscape dimensions
                let margins: CGFloat = 20 // 20pt margins on each side
                let availableWidth = pageWidth - (margins * 2)
                let availableHeight = pageHeight - (margins * 2)
                
                // Base font size that we'll scale
                let baseFontSize: CGFloat = 8
                let textFont = UIFont.systemFont(ofSize: baseFontSize)
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: textFont,
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.alignment = .left
                        style.lineBreakMode = .byWordWrapping
                        return style
                    }()
                ]
                
                // Table setup with scaled dimensions
                let columnWidths: [CGFloat] = [60, 80, 80, 80, 80, 80, 60, 60, 60, 60, 40, 40, 40, 40, 60]
                let rowHeight: CGFloat = 18
                let startY: CGFloat = margins
                let leftMargin: CGFloat = margins
//                let rightMargin: CGFloat = margins
                let columnSpacing: CGFloat = 4
                let cellPadding: CGFloat = 4 // Padding within each cell
                
                // Calculate total table width
                let tableWidth = columnWidths.reduce(0, +) + (CGFloat(columnWidths.count - 1) * columnSpacing)
                
                // Calculate scale factor to fit width
                let widthScaleFactor = min(1.0, availableWidth / tableWidth)
                
                // Apply scale transform
                context.cgContext.translateBy(x: leftMargin, y: startY)
                context.cgContext.scaleBy(x: widthScaleFactor, y: widthScaleFactor)
                
                // Table Headers
                let headers = [
                    "Date",
                    "Aircraft Type",
                    "Aircraft Registration",
                    "Pilot-in-command",
                    "Co-pilot or student",
                    "Holder's operating capacity",
                    "From",
                    "To",
                    "No. of Take-offs",
                    "No. of Landings",
                    "P1",
                    "P1(U/S)",
                    "P2/P2X",
                    "P/UT",
                    "Instrument Time"
                ]
                
                // Draw header row with multiline support
                var xPosition: CGFloat = 0
                var yPosition: CGFloat = 0
                var maxHeaderHeight: CGFloat = rowHeight
                
                // First pass: calculate maximum header height
                for (index, header) in headers.enumerated() {
                    let headerRect = CGRect(
                        x: xPosition + cellPadding,
                        y: yPosition + cellPadding,
                        width: columnWidths[index] - (cellPadding * 2),
                        height: .greatestFiniteMagnitude
                    )
                    let boundingRect = header.boundingRect(
                        with: headerRect.size,
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: textAttributes,
                        context: nil
                    )
                    maxHeaderHeight = max(maxHeaderHeight, boundingRect.height + (cellPadding * 2))
                    xPosition += columnWidths[index] + columnSpacing
                }
                
                // Second pass: draw headers with proper height and padding
                xPosition = 0
                for (index, header) in headers.enumerated() {
                    let headerRect = CGRect(
                        x: xPosition + cellPadding,
                        y: yPosition + cellPadding,
                        width: columnWidths[index] - (cellPadding * 2),
                        height: maxHeaderHeight - (cellPadding * 2)
                    )
                    header.draw(in: headerRect, withAttributes: textAttributes)
                    xPosition += columnWidths[index] + columnSpacing
                }
                
                yPosition += maxHeaderHeight + 8
                
                // Draw flight entries
                let sortedFlights = flights.sorted { $0.date < $1.date }
                for flight in sortedFlights {
                    // Check if we need a new page
                    let scaledYPosition = yPosition * widthScaleFactor
                    if scaledYPosition > availableHeight - 50 {
                        context.beginPage()
                        yPosition = 0
                        
                        // Reset transform for new page
                        context.cgContext.translateBy(x: leftMargin, y: startY)
                        context.cgContext.scaleBy(x: widthScaleFactor, y: widthScaleFactor)
                        
                        // Redraw headers on new page with multiline support and padding
                        xPosition = 0
                        for (index, header) in headers.enumerated() {
                            let headerRect = CGRect(
                                x: xPosition + cellPadding,
                                y: yPosition + cellPadding,
                                width: columnWidths[index] - (cellPadding * 2),
                                height: maxHeaderHeight - (cellPadding * 2)
                            )
                            header.draw(in: headerRect, withAttributes: textAttributes)
                            xPosition += columnWidths[index] + columnSpacing
                        }
                        
                        yPosition += maxHeaderHeight + 8
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    
                    let entries = [
                        dateFormatter.string(from: flight.outTime),
                        flight.aircraftType,
                        flight.aircraftRegistration,
                        flight.isSelf ? "Self" : flight.pilotInCommand,
                        flight.isSelf ? "" : "Self", // Co-pilot column is empty when PIC is self
                        flight.operatingCapacity.rawValue,
                        flight.departureAirport,
                        flight.arrivalAirport,
                        String(flight.sector),
                        String(flight.sector),
                        flight.operatingCapacity == .p1 ? "\(formatHoursMinutes(flight.blockTime))" : "",
                        flight.operatingCapacity == .p1us ? "\(formatHoursMinutes(flight.blockTime))" : "",
                        flight.operatingCapacity == .p2 || flight.operatingCapacity == .p2x ? "\(formatHoursMinutes(flight.blockTime))" : "",
                        flight.operatingCapacity == .put ? "\(formatHoursMinutes(flight.blockTime))" : "",
                        flight.isIFR ? "\(formatHoursMinutes(flight.blockTime))" : ""
                    ]
                    
                    xPosition = 0
                    for (index, entry) in entries.enumerated() {
                        let entryRect = CGRect(
                            x: xPosition + cellPadding,
                            y: yPosition + cellPadding,
                            width: columnWidths[index] - (cellPadding * 2),
                            height: rowHeight - (cellPadding * 2)
                        )
                        entry.draw(in: entryRect, withAttributes: textAttributes)
                        xPosition += columnWidths[index] + columnSpacing
                    }
                    
                    yPosition += rowHeight + 4
                }
                
                // Calculate totals
                let p1Total = flights.filter { $0.operatingCapacity == .p1 }.reduce(0) { $0 + $1.blockTime }
                let p1usTotal = flights.filter { $0.operatingCapacity == .p1us }.reduce(0) { $0 + $1.blockTime }
                let p2Total = flights.filter { $0.operatingCapacity == .p2 || $0.operatingCapacity == .p2x }.reduce(0) { $0 + $1.blockTime }
                let putTotal = flights.filter { $0.operatingCapacity == .put }.reduce(0) { $0 + $1.blockTime }
                let grandTotal = flights.reduce(0) { $0 + $1.blockTime }
                
                // Add spacing before totals
                yPosition += 8
                
                // Draw totals row
                let totalEntries = [
                    "Total",
                    "", "", "", "", "", "", "", "", "",
                    "\(formatHoursMinutes(p1Total))",
                    "\(formatHoursMinutes(p1usTotal))",
                    "\(formatHoursMinutes(p2Total))",
                    "\(formatHoursMinutes(putTotal))",
                    ""
                ]
                
                xPosition = 0
                for (index, entry) in totalEntries.enumerated() {
                    let entryRect = CGRect(
                        x: xPosition + cellPadding,
                        y: yPosition + cellPadding,
                        width: columnWidths[index] - (cellPadding * 2),
                        height: rowHeight - (cellPadding * 2)
                    )
                    entry.draw(in: entryRect, withAttributes: textAttributes)
                    xPosition += columnWidths[index] + columnSpacing
                }
                
                yPosition += rowHeight + 4
                
                // Draw grand total row
                let grandTotalEntries = [
                    "Grand Total",
                    "", "", "", "", "", "", "", "", "",
                    "", "", "", "",
                    "\(formatHoursMinutes(grandTotal))"
                ]
                
                xPosition = 0
                for (index, entry) in grandTotalEntries.enumerated() {
                    let entryRect = CGRect(
                        x: xPosition + cellPadding,
                        y: yPosition + cellPadding,
                        width: columnWidths[index] - (cellPadding * 2),
                        height: rowHeight - (cellPadding * 2)
                    )
                    entry.draw(in: entryRect, withAttributes: textAttributes)
                    xPosition += columnWidths[index] + columnSpacing
                }
            }
            
            completion(.success(tempURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Helper Methods for PDF Generation
    
    private func calculateTotalBlockTime(_ flights: [Flight]) -> String {
        let totalSeconds = flights.reduce(0) { $0 + $1.blockTime }
        return formatHoursMinutes(totalSeconds)
    }
    
    private func calculateTotalFlightTime(_ flights: [Flight]) -> String {
        let totalSeconds = flights.reduce(0) { $0 + $1.flightTime }
        return formatHoursMinutes(totalSeconds)
    }
    
    private func calculateTotalNightHours(_ flights: [Flight]) -> String {
        let nightFlights = flights.filter { isNightFlight($0) }
        let totalSeconds = nightFlights.reduce(0) { $0 + $1.blockTime }
        return formatHoursMinutes(totalSeconds)
    }
    
    private func calculateTotalLandings(_ flights: [Flight]) -> String {
        let total = flights.reduce(0) { $0 + $1.sector }
        return "\(total)"
    }
    
    private func isNightFlight(_ flight: Flight) -> Bool {
        let calendar = Calendar.current
        let offComponents = calendar.dateComponents([.hour], from: flight.offTime)
        let onComponents = calendar.dateComponents([.hour], from: flight.onTime)
        
        return (offComponents.hour ?? 12) >= 18 || (offComponents.hour ?? 12) <= 6 ||
            (onComponents.hour ?? 12) >= 18 || (onComponents.hour ?? 12) <= 6
    }
    
    private func formatHoursMinutes(_ interval: TimeInterval) -> String {
        let totalHours = interval / 3600
        return String(format: "%.1f", totalHours)
    }
    
    private func generateCSV(flights: [Flight], style: Export.LogbookStyle, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileName = "\(style.rawValue)_Logbook.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var content = ""
        // Add header based on style
        switch style {
        case .hkcad:
            content += "Date,Aircraft Type,Departure,Arrival,Block Time,Remarks\n"
        }
        
        // Add flight data
        for flight in flights {
            content += "\(flight.formattedDate),\(flight.aircraftType),\(flight.departureAirport),\(flight.arrivalAirport),\(String(format: "%.1f", flight.blockTime)),\n"
        }
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            completion(.success(tempURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func generateExcel(flights: [Flight], style: Export.LogbookStyle, completion: @escaping (Result<URL, Error>) -> Void) {
        // In a real app, this would generate an Excel file using a library like XlsxWriter
        // For now, we'll create a CSV file with .xlsx extension as a placeholder
        
        let fileName = "\(style.rawValue)_Logbook.xlsx"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var content = ""
        
        // Add header based on style
        switch style {
        case .hkcad:
            content += "Date,Aircraft Type,Departure,Arrival,Block Time,Remarks\n"
        }
        
        // Add flight data
        for flight in flights {
            content += "\(flight.formattedDate),\(flight.aircraftType),\(flight.departureAirport),\(flight.arrivalAirport),\(String(format: "%.1f", flight.blockTime)),\n"
        }
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            completion(.success(tempURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Share Methods
    
    func shareFile(_ url: URL, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        viewController.present(activityVC, animated: true)
    }
}
