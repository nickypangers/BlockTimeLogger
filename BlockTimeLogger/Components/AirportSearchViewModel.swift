import Foundation
import Combine

class AirportSearchViewModel: ObservableObject {
    @Published var airports: [Airport] = []
    @Published var filteredAirports: [Airport] = []
    private var cancellables = Set<AnyCancellable>()
    private let database: LocalDatabase
    
    init(database: LocalDatabase) {
        self.database = database
        setupObservers()
    }
    
    private func setupObservers() {
        database.observeAirports()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] airports in
                self?.airports = airports
                self?.filterAirports(searchText: "")
            }
            .store(in: &cancellables)
    }
    
    func filterAirports(searchText: String) {
        if searchText.isEmpty {
            filteredAirports = airports
        } else {
            filteredAirports = airports.filter { airport in
                airport.name.localizedCaseInsensitiveContains(searchText) ||
                airport.icao.localizedCaseInsensitiveContains(searchText) ||
                airport.iata.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
} 