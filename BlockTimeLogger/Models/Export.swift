//
//  LogbookStyle.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 18/4/2025.
//

import Foundation

enum Export {
    enum ExportFormat: String, CaseIterable {
        case pdf = "PDF"
        case csv = "CSV"
        case excel = "Excel"
            
        var icon: String {
            switch self {
            case .pdf: return "doc.text"
            case .csv: return "tablecells"
            case .excel: return "tablecells.badge.ellipsis"
            }
        }
    }
        
    enum DateRange: String, CaseIterable {
        case lastMonth = "Last Month"
        case last3Months = "Last 3 Months"
        case last6Months = "Last 6 Months"
        case lastYear = "Last Year"
        case allTime = "All Time"
    }
        
    enum LogbookStyle: String, CaseIterable {
        case hkcad = "HKCAD"
            
        var icon: String {
            switch self {
            case .hkcad: return "airplane.circle"
            }
        }
            
        var description: String {
            switch self {
            case .hkcad: return "Hong Kong Civil Aviation Department format"
            }
        }
    }
}
