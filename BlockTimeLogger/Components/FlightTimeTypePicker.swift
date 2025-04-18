import SwiftUI

struct OperatingCapacityPicker: View {
    @Binding var selectedType: Flight.OperatingCapacity
    let isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Position")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            if isEditing {
                Picker("Position", selection: $selectedType) {
                    ForEach(Flight.OperatingCapacity.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
            } else {
                Text(selectedType.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 20) {
        OperatingCapacityPicker(
            selectedType: .constant(.p2),
            isEditing: true
        )
        
        OperatingCapacityPicker(
            selectedType: .constant(.p1),
            isEditing: false
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 