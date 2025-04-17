//
//  ExportService.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 18/4/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import PDFKit

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - Export Methods
    
    func exportLogbook(
        flights: [Flight],
        style: ExportLogbookView.LogbookStyle,
        format: ExportLogbookView.ExportFormat,
        dateRange: ExportLogbookView.DateRange,
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
    
    private func filterFlightsByDateRange(_ flights: [Flight], dateRange: ExportLogbookView.DateRange) -> [Flight] {
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
    
    private func generatePDF(flights: [Flight], style: ExportLogbookView.LogbookStyle, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileName = "\(style.rawValue)_Logbook.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "BlockTimeLogger",
            kCGPDFContextAuthor: "Pilot",
            kCGPDFContextTitle: "\(style.rawValue) Pilot Logbook"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                
                let titleFont = UIFont.boldSystemFont(ofSize: 24)
                let headerFont = UIFont.boldSystemFont(ofSize: 16)
                let textFont = UIFont.systemFont(ofSize: 12)
                
                // Title
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.black
                ]
                let title = "PILOT LOGBOOK"
                let titleSize = title.size(withAttributes: titleAttributes)
                let titleRect = CGRect(x: (pageWidth - titleSize.width) / 2,
                                     y: 50,
                                     width: titleSize.width,
                                     height: titleSize.height)
                title.draw(in: titleRect, withAttributes: titleAttributes)
                
                // Subtitle
                let subtitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: headerFont,
                    .foregroundColor: UIColor.black
                ]
                let subtitle = "Civil Aviation Department of Hong Kong"
                let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
                let subtitleRect = CGRect(x: (pageWidth - subtitleSize.width) / 2,
                                        y: titleRect.maxY + 20,
                                        width: subtitleSize.width,
                                        height: subtitleSize.height)
                subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
                
                // Pilot Information
                var yPosition = subtitleRect.maxY + 40
                let pilotInfoAttributes: [NSAttributedString.Key: Any] = [
                    .font: textFont,
                    .foregroundColor: UIColor.black
                ]
                
                let pilotInfo = [
                    "PILOT INFORMATION",
                    "Name: [PILOT NAME]",
                    "License Number: [LICENSE NUMBER]",
                    "Date of Issue: [DATE]",
                    "Date of Expiry: [DATE]"
                ]
                
                for info in pilotInfo {
                    let infoSize = info.size(withAttributes: pilotInfoAttributes)
                    let infoRect = CGRect(x: 50, y: yPosition, width: infoSize.width, height: infoSize.height)
                    info.draw(in: infoRect, withAttributes: pilotInfoAttributes)
                    yPosition += infoSize.height + 10
                }
                
                // Summary Section
                yPosition += 20
                let summaryTitle = "SUMMARY OF FLIGHT TIME"
                let summaryTitleSize = summaryTitle.size(withAttributes: [.font: headerFont])
                let summaryTitleRect = CGRect(x: 50, y: yPosition, width: summaryTitleSize.width, height: summaryTitleSize.height)
                summaryTitle.draw(in: summaryTitleRect, withAttributes: [.font: headerFont])
                
                yPosition += summaryTitleSize.height + 20
                
                let summaryItems = [
                    "Total Block Time: \(calculateTotalBlockTime(flights))",
                    "Total Flight Time: \(calculateTotalFlightTime(flights))",
                    // "Total Night Hours: \(calculateTotalNightHours(flights))",
                    "Total Landings: \(calculateTotalLandings(flights))"
                ]
                
                for item in summaryItems {
                    let itemSize = item.size(withAttributes: pilotInfoAttributes)
                    let itemRect = CGRect(x: 50, y: yPosition, width: itemSize.width, height: itemSize.height)
                    item.draw(in: itemRect, withAttributes: pilotInfoAttributes)
                    yPosition += itemSize.height + 10
                }
                
                // Flight Log Table
                yPosition += 20
                let tableTitle = "DETAILED FLIGHT LOG"
                let tableTitleSize = tableTitle.size(withAttributes: [.font: headerFont])
                let tableTitleRect = CGRect(x: 50, y: yPosition, width: tableTitleSize.width, height: tableTitleSize.height)
                tableTitle.draw(in: tableTitleRect, withAttributes: [.font: headerFont])
                
                yPosition += tableTitleSize.height + 20
                
                // Table Headers
                let columnWidths: [CGFloat] = [80, 100, 100, 80, 80, 80, 80, 50, 50, 80, 100]
                let headers = ["Date", "Aircraft Type", "Registration", "Departure", "Arrival", "Block Time", "Flight Time", "Night", "Landings", "Position", "Remarks"]
                
                // Draw header row
                var xPosition: CGFloat = 50
                for (index, header) in headers.enumerated() {
                    let headerSize = header.size(withAttributes: pilotInfoAttributes)
                    let headerRect = CGRect(x: xPosition, y: yPosition, width: columnWidths[index], height: headerSize.height)
                    header.draw(in: headerRect, withAttributes: pilotInfoAttributes)
                    xPosition += columnWidths[index] + 10
                }
                
                yPosition += 20
                
                // Draw separator line
                let separatorPath = UIBezierPath()
                separatorPath.move(to: CGPoint(x: 50, y: yPosition))
                separatorPath.addLine(to: CGPoint(x: pageWidth - 50, y: yPosition))
                UIColor.black.setStroke()
                separatorPath.stroke()
                
                yPosition += 20
                
                // Draw flight entries
                let sortedFlights = flights.sorted { $0.date < $1.date }
                for flight in sortedFlights {
                    if yPosition > pageHeight - 100 {
                        context.beginPage()
                        yPosition = 50
                    }
                    
                    let nightIndicator = isNightFlight(flight) ? "Y" : "N"
                    let entries = [
                        flight.formattedDate,
                        flight.aircraftType,
                        flight.aircraftRegistration,
                        flight.departureAirport,
                        flight.arrivalAirport,
                        formatHoursMinutes(flight.blockTime),
                        formatHoursMinutes(flight.flightTime),
                        nightIndicator,
                        "\(flight.sector)",
                        flight.flightTimeType.rawValue,
                        flight.notes
                    ]
                    
                    xPosition = 50
                    for (index, entry) in entries.enumerated() {
                        let entrySize = entry.size(withAttributes: pilotInfoAttributes)
                        let entryRect = CGRect(x: xPosition, y: yPosition, width: columnWidths[index], height: entrySize.height)
                        entry.draw(in: entryRect, withAttributes: pilotInfoAttributes)
                        xPosition += columnWidths[index] + 10
                    }
                    
                    yPosition += 20
                }
                
                // Draw footer on last page
                if yPosition < pageHeight - 100 {
                    yPosition = pageHeight - 100
                    let footerText = "I certify that the above entries are true and correct."
                    let footerSize = footerText.size(withAttributes: pilotInfoAttributes)
                    let footerRect = CGRect(x: 50, y: yPosition, width: footerSize.width, height: footerSize.height)
                    footerText.draw(in: footerRect, withAttributes: pilotInfoAttributes)
                    
                    yPosition += footerSize.height + 40
                    
                    let signatureText = "Signature: _____________________"
                    let signatureSize = signatureText.size(withAttributes: pilotInfoAttributes)
                    let signatureRect = CGRect(x: 50, y: yPosition, width: signatureSize.width, height: signatureSize.height)
                    signatureText.draw(in: signatureRect, withAttributes: pilotInfoAttributes)
                    
                    yPosition += signatureSize.height + 20
                    
                    let dateText = "Date: \(Date().formatted(date: .long, time: .omitted))"
                    let dateSize = dateText.size(withAttributes: pilotInfoAttributes)
                    let dateRect = CGRect(x: 50, y: yPosition, width: dateSize.width, height: dateSize.height)
                    dateText.draw(in: dateRect, withAttributes: pilotInfoAttributes)
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
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    private func generateCSV(flights: [Flight], style: ExportLogbookView.LogbookStyle, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileName = "\(style.rawValue)_Logbook.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var content = ""
        
        // Add header based on style
        switch style {
        case .hkcad:
            content += "Date,Aircraft Type,Departure,Arrival,Block Time,Remarks\n"
        // case .caa:
        //     content += "Date,Aircraft Type,Registration,Departure,Arrival,Block Time,Remarks\n"
        // case .faa:
        //     content += "Date,Aircraft Type,Registration,Departure,Arrival,Block Time,Remarks\n"
        // case .easa:
        //     content += "Date,Aircraft Type,Registration,Departure,Arrival,Block Time,Remarks\n"
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
    
    private func generateExcel(flights: [Flight], style: ExportLogbookView.LogbookStyle, completion: @escaping (Result<URL, Error>) -> Void) {
        // In a real app, this would generate an Excel file using a library like XlsxWriter
        // For now, we'll create a CSV file with .xlsx extension as a placeholder
        
        let fileName = "\(style.rawValue)_Logbook.xlsx"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var content = ""
        
        // Add header based on style
        switch style {
        case .hkcad:
            content += "Date,Aircraft Type,Departure,Arrival,Block Time,Remarks\n"
        // case .caa:
        //     content += "Date,Aircraft Type,Registration,Departure,Arrival,Block Time,Remarks\n"
        // case .faa:
        //     content += "Date,Aircraft Type,Registration,Departure,Arrival,Block Time,Remarks\n"
        // case .easa:
        //     content += "Date,Aircraft Type,Registration,Departure,Arrival,Block Time,Remarks\n"
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