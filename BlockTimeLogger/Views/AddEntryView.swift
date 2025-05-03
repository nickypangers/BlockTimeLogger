import SwiftUI

enum EntryType: String, CaseIterable, Identifiable {
  case flight = "Flight"
  // case sim = "Sim"

  var id: String { rawValue }
}

struct AddEntryView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedEntryType: EntryType = .flight
  @StateObject var homeViewModel: HomeViewModel

  var body: some View {
    NavigationStack {
      VStack {
        Picker("Entry Type", selection: $selectedEntryType) {
          ForEach(EntryType.allCases) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(.segmented)
        .padding()

        switch selectedEntryType {
        case .flight:
          AddFlightView(homeViewModel: homeViewModel)
        // case .sim:
        //     AddSimView(homeViewModel: homeViewModel)
        }
      }
      //            .navigationTitle("Add Entry")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  AddEntryView(homeViewModel: HomeViewModel())
}
