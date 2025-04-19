import SwiftUI

struct PositionTagView: View {
    let position: Flight.Position
    
    var body: some View {
        switch position {
        case .captain:
            Text("CN")
                .tagStyle(color: FlightTag.captain.color)
        case .firstOfficer:
            Text("FO")
                .tagStyle(color: FlightTag.firstOfficer.color)
        case .secondOfficer:
            Text("SO")
                .tagStyle(color: FlightTag.secondOfficer.color)
        }
    }
}

#Preview {
    VStack {
        PositionTagView(position: .captain)
        PositionTagView(position: .firstOfficer)
        PositionTagView(position: .secondOfficer)
    }
} 