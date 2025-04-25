import SwiftUI

struct ColumnMapper: View {
    @ObservedObject var viewModel: ImportViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var requiredColumns: [ImportColumnMapping.ColumnType] {
        ImportColumnMapping.ColumnType.allCases.filter { $0.isRequired }
    }
    
    private var optionalColumns: [ImportColumnMapping.ColumnType] {
        ImportColumnMapping.ColumnType.allCases.filter { !$0.isRequired }
    }
    
    private func columnBinding(for column: ImportColumnMapping.ColumnType) -> Binding<Int> {
        Binding(
            get: { viewModel.columnMapping.getColumnIndex(for: column) ?? -1 },
            set: { viewModel.columnMapping.setColumnIndex(for: column, index: $0) }
        )
    }
    
    private func isColumnSelected(_ column: ImportColumnMapping.ColumnType, index: Int) -> Bool {
        viewModel.columnMapping.getColumnIndices(for: column).contains(index)
    }
    
    var body: some View {
        NavigationView {
            Form {
                if viewModel.sampleRow.isEmpty {
                    Section {
                        Text("No data available. Please paste your flight log data first.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    sampleRowSection
                    requiredColumnsSection
                    optionalColumnsSection
                    // autoDetectSection
                }
            }
            .navigationTitle("Column Mapping")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var sampleRowSection: some View {
        Section(header: Text("Sample Row")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.sampleRow.count, id: \.self) { index in
                        Text("\(index + 1): \(viewModel.sampleRow[index])")
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var requiredColumnsSection: some View {
        Section(header: Text("Required Columns")) {
            ForEach(requiredColumns, id: \.self) { column in
                if column.allowsMultipleMappings {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(column.rawValue)
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<viewModel.sampleRow.count, id: \.self) { index in
                                    Button {
                                        viewModel.columnMapping.setColumnIndex(for: column, index: index)
                                    } label: {
                                        Text("\(index + 1)")
                                            .padding(8)
                                            .background(isColumnSelected(column, index: index) ? Color.blue : Color.gray.opacity(0.1))
                                            .foregroundColor(isColumnSelected(column, index: index) ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Picker(column.rawValue, selection: columnBinding(for: column)) {
                        Text("Not Mapped").tag(-1)
                        ForEach(0..<viewModel.sampleRow.count, id: \.self) { index in
                            Text("Column \(index + 1)").tag(index)
                        }
                    }
                }
            }
        }
    }
    
    private var optionalColumnsSection: some View {
        Section(header: Text("Optional Columns")) {
            ForEach(optionalColumns, id: \.self) { column in
                Picker(column.rawValue, selection: columnBinding(for: column)) {
                    Text("Not Mapped").tag(-1)
                    ForEach(0..<viewModel.sampleRow.count, id: \.self) { index in
                        Text("Column \(index + 1)").tag(index)
                    }
                }
            }
        }
    }
    
    private var autoDetectSection: some View {
        Section {
            Button("Auto-Detect") {
                viewModel.autoDetectColumnMapping()
            }
        }
    }
}

#Preview {
    ColumnMapper(viewModel: ImportViewModel())
} 