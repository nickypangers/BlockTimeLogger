//
//  HomeViewModel.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 4/4/2025.
//

import Foundation

// MARK: - ViewModel

final class HomeViewModel: ObservableObject {
    @Published var flights: [Flight] = []
    @Published var monthlyMetrics: TimeSummary.MetricGroup = .empty
    @Published var allTimeMetrics: TimeSummary.MetricGroup = .empty
        
    private let flightDataService: FlightDataServiceProtocol
    private let calendar = Calendar.current

    init(flightDataService: FlightDataServiceProtocol = FlightDataService.shared) {
        self.flightDataService = flightDataService
        loadFlights()
    }

    func loadFlights() {
        // Get both stored flights and generate some mock ones
        let storedFlights = flightDataService.fetchFlights()
        let mockFlights = flightDataService.generateMockFlights(count: max(5 - storedFlights.count, 0))
        flights = (storedFlights + mockFlights).sorted { $0.date > $1.date }
        calculateMetrics()
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
        
    private func calculateMetrics(for flights: [Flight]) -> TimeSummary.MetricGroup {
        let blockHours = flights.reduce(0) { $0 + $1.blockTime } / 3600
        let nightHours = calculateNightHours(for: flights)
        let picHours = flights.reduce(0) { $0 + ($1.isSelf ? $1.blockTime : 0) } / 3600
        let crossCountryHours = flights.reduce(0) { $0 + (isCrossCountry(flight: $1) ? $1.blockTime : 0) } / 3600
        
        // Corrected landings calculation
        let landings = flights.reduce(0) { result, flight in
            result + flight.sector
        }
        
        return TimeSummary.MetricGroup(
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

extension TimeSummary.MetricGroup {
    static var empty: TimeSummary.MetricGroup {
        TimeSummary.MetricGroup(
            blockHours: "0.0",
            flights: "0",
            landings: "0",
            nightHours: "0.0",
            picHours: "0.0",
            crossCountryHours: "0.0"
        )
    }
}
