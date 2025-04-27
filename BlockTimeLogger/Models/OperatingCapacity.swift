import SwiftUI

enum OperatingCapacity: String, CaseIterable, Codable {
    case p1 = "P1"
    case p1us = "P1 U/S"
    case p2 = "P2"
    case p2x = "P2X"
    case put = "P U/T"
    
    var description: String {
        switch self {
        case .p1: return "Pilot in Command"
        case .p1us: return "Pilot in Command Under Supervision"
        case .p2: return "Co-Pilot"
        case .p2x: return "Co-Pilot with Extended Duties"
        case .put: return "Pilot Under Training"
        }
    }
    
    var color: Color {
        switch self {
        case .p1: return .blue
        case .p1us: return .blue
        case .p2: return .green
        case .p2x: return .green
        case .put: return .purple
        }
    }
    
    static var simOptions: [OperatingCapacity] {
        [.put, .p1us]
    }
}

struct FlightTimeTypePicker: View {
    @Binding var selectedType: OperatingCapacity
    
    var body: some View {
        Picker("Operating Capacity", selection: $selectedType) {
            ForEach(OperatingCapacity.allCases, id: \.self) { type in
                Text(type.description).tag(type)
            }
        }
    }
}

#Preview {
    Form {
        FlightTimeTypePicker(
            selectedType: .constant(.p2)
        )
    }
} 