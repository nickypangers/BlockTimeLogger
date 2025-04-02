//
//  HomeView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/3/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1 - Flight Dashboard
            FlightDashboardView()
                .tabItem {
                    Label("Flights", systemImage: "airplane")
                }
                .tag(0)

            // Tab 2 - Logbook
            LogbookView()
                .tabItem {
                    Label("Logbook", systemImage: "book.closed")
                }
                .tag(1)

            // Tab 3 - Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
        }
        .accentColor(.blue) // Set tab bar tint color
    }
}

// Preview

#Preview {
    HomeView()
}
