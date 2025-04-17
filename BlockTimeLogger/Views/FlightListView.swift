//
//  SeeAllFlightsView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 18/4/2025.
//

import SwiftUI

struct FlightListView: View {
    let flights: [Flight]
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dateDescending
    @State private var filterOption: FilterOption = .all
    
    enum SortOption: String, CaseIterable, Identifiable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case blockTimeDescending = "Block Time (High to Low)"
        case blockTimeAscending = "Block Time (Low to High)"
        
        var id: String { rawValue }
    }
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All Flights"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter bar
                searchAndFilterBar
                
                // Flights list
                if flights.isEmpty {
                    emptyStateView
                } else {
                    flightsList
                }
            }
            .navigationTitle("All Flights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        
                        Divider()
                        
                        Picker("Filter", selection: $filterOption) {
                            ForEach(FilterOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort & Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search flights", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FilterOption.allCases) { option in
                        Button {
                            filterOption = option
                        } label: {
                            Text(option.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(filterOption == option ?
                                            Color.accentColor : Color(.secondarySystemBackground))
                                )
                                .foregroundColor(filterOption == option ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var flightsList: some View {
        List {
            ForEach(filteredAndSortedFlights) { flight in
                FlightLogOverview(flight: flight)
                    .background(
                        NavigationLink("", destination: FlightDetailView(flight: flight))
                            .opacity(0)
                    )
                
                    .buttonStyle(PlainButtonStyle())
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Flights Found")
                .font(.headline)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                searchText = ""
                filterOption = .all
            } label: {
                Text("Clear Filters")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor)
                    )
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var filteredAndSortedFlights: [Flight] {
        var result = flights
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { flight in
                flight.departureAirport.localizedCaseInsensitiveContains(searchText) ||
                    flight.arrivalAirport.localizedCaseInsensitiveContains(searchText) ||
                    flight.aircraftType.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply date filter
        let calendar = Calendar.current
        let now = Date()
        
        switch filterOption {
        case .today:
            result = result.filter { flight in
                calendar.isDate(flight.outTime, inSameDayAs: now)
            }
        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            result = result.filter { flight in
                flight.outTime >= startOfWeek
            }
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            result = result.filter { flight in
                flight.outTime >= startOfMonth
            }
        case .lastMonth:
            let currentMonthComponents = calendar.dateComponents([.year, .month], from: now)
            let firstDayOfCurrentMonth = calendar.date(from: currentMonthComponents)!
            
            let previousMonthComponents = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth)!
            let firstDayOfPreviousMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonthComponents))!
            
            let firstDayOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfPreviousMonth)!
            
            result = result.filter { flight in
                flight.outTime >= firstDayOfPreviousMonth && flight.outTime < firstDayOfNextMonth
            }
        case .all:
            break
        }
        
        // Apply sorting
        switch sortOption {
        case .dateDescending:
            result.sort { $0.outTime > $1.outTime }
        case .dateAscending:
            result.sort { $0.outTime < $1.outTime }
        case .blockTimeDescending:
            result.sort { $0.blockTime > $1.blockTime }
        case .blockTimeAscending:
            result.sort { $0.blockTime < $1.blockTime }
        }
        
        return result
    }
}

struct FlightRow: View {
    let flight: Flight
    
    var body: some View {
        HStack(spacing: 16) {
            // Date column
            VStack(alignment: .leading, spacing: 4) {
                Text(flight.formattedDate)
                    .font(.headline)
                
                Text(flight.formattedOutTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            // Route column
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(flight.departureAirport)
                        .font(.system(.body, design: .monospaced))
                        .bold()
                    
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(90))
                    
                    Text(flight.arrivalAirport)
                        .font(.system(.body, design: .monospaced))
                        .bold()
                }
                
                Text(flight.aircraftType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Block time column
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f", flight.blockTime))
                    .font(.headline)
                
                Text("hours")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FlightListView(flights: [])
}
