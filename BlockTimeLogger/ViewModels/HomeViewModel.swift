//
//  HomeViewModel.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//
import Combine
import Foundation

// MARK: - ViewModel

final class HomeViewModel: ObservableObject {
    @Published private(set) var flights: [Flight] = [] {
        didSet {
            calculateMetrics()
        }
    }

    @Published var monthlyMetrics: MetricGroup = .empty
    @Published var allTimeMetrics: MetricGroup = .empty
        
    private let flightDataService: FlightDataServiceProtocol
    private let calendar = Calendar.current
    private let db = LocalDatabase.shared
    private var cancellables = Set<AnyCancellable>()

    init(flightDataService: FlightDataServiceProtocol = FlightDataService.shared) {
        self.flightDataService = flightDataService
        loadFlights()
    }

    func loadFlights() {
        // Get flights from LocalDatabase

        db
            .observeFlights()
            .catch { _ in
                Just([])
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newFlights in
                self?.flights = newFlights
            }
            .store(in: &cancellables)
    }
        
    private func calculateMetrics() {
        // Calculate monthly metrics (last 30 days)
        let monthlyFlights = flights.filter { flight in
            calendar.dateComponents([.day], from: flight.date, to: Date()).day ?? 31 <= 30
        }
        monthlyMetrics = calculateMetrics(for: monthlyFlights)
            
        // Calculate all-time metrics (all flights)
        allTimeMetrics = calculateMetrics(for: flights)
    }
        
    private func calculateMetrics(for flights: [Flight]) -> MetricGroup {
        let blockHours = flights.reduce(0) { $0 + $1.blockTime } / 3600
        let nightHours = calculateNightHours(for: flights)
        let picHours = flights.reduce(0) { $0 + ($1.isSelf ? $1.blockTime : 0) } / 3600
        let crossCountryHours = flights.reduce(0) { $0 + (isCrossCountry(flight: $1) ? $1.blockTime : 0) } / 3600
        
        // Corrected landings calculation
        let landings = flights.reduce(0) { result, flight in
            result + flight.sector
        }
        
        return MetricGroup(
            blockHours: String(format: "%.1f", blockHours),
            flights: "\(flights.count)",
            landings: "\(landings)", // Use the calculated value
            nightHours: String(format: "%.1f", nightHours),
            picHours: String(format: "%.1f", picHours),
            crossCountryHours: String(format: "%.1f", crossCountryHours)
        )
    }
    
    private func calculateNightHours(for flights: [Flight]) -> Double {
        flights.reduce(0) { total, flight in
            // Simple implementation: consider any flight that starts or ends between sunset and sunrise as night
            // In a real app, you would use proper sunrise/sunset calculations based on date and location
            let calendar = Calendar.current
            let offComponents = calendar.dateComponents([.hour], from: flight.offTime)
            let onComponents = calendar.dateComponents([.hour], from: flight.onTime)
            
            let isNightFlight = (offComponents.hour ?? 12) >= 18 || (offComponents.hour ?? 12) <= 6 ||
                (onComponents.hour ?? 12) >= 18 || (onComponents.hour ?? 12) <= 6
            
            return total + (isNightFlight ? flight.blockTime : 0)
        } / 3600
    }
    
    private func isCrossCountry(flight: Flight) -> Bool {
        // Simple implementation: consider any flight with different departure/arrival airports as cross-country
        // In a real app, you might want to add distance requirements
        return flight.departureAirport != flight.arrivalAirport
    }
}
