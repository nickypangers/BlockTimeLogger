//
//  FlightTag.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import SwiftUI

enum FlightTag: String, CaseIterable, Identifiable {
    case pic
    case pf
    case ifr
    case vfr
    case captain
    case firstOfficer
    case secondOfficer
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .pic: return "PIC"
        case .pf: return "PF"
        case .ifr: return "IFR"
        case .vfr: return "VFR"
        case .captain: return "CN"
        case .firstOfficer: return "FO"
        case .secondOfficer: return "SO"
        }
    }
    
    var color: Color {
        switch self {
        case .pic: return .blue
        case .pf: return .green
        case .ifr: return .orange
        case .vfr: return .mint
        case .captain: return .red
        case .firstOfficer: return .purple
        case .secondOfficer: return .indigo
        }
    }
}
