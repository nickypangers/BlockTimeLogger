import SwiftUI

struct AirportSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AirportSearchViewModel
    @State private var searchText = ""
    let onSelect: (Airport) -> Void

    init(database: LocalDatabase, onSelect: @escaping (Airport) -> Void) {
        _viewModel = StateObject(wrappedValue: AirportSearchViewModel(database: database))
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationView {
            List(viewModel.filteredAirports) { airport in
                Button(action: {
                    onSelect(airport)
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(airport.name)
                            .font(.headline)
                        Text("\(airport.icao) - \(airport.iata)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search airports")
            .onChange(of: searchText) { _, newValue in
                viewModel.filterAirports(searchText: newValue)
            }
            .navigationTitle("Select Airport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
