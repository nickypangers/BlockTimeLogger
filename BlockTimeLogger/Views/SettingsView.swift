//
//  SettingsView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 10/5/2025.
//

import RevenueCat
import RevenueCatUI
import SwiftUI

struct SettingsView: View {
    @State private var isNotificationsEnabled = true
    @State private var isDarkModeEnabled = false
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @State private var isPresentingPaywall = false

    private var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                // Subscription Section
                Section {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Free Plan")
                            .font(.headline)
                        Spacer()
                        Text("Current")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Button {
                        isPresentingPaywall.toggle()
                    } label: {
                        Text("Upgrade to Pro")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } header: {
                    Text("Subscription")
                } footer: {
                    Text("Upgrade to Pro for unlimited flights and advanced features")
                }

                // Preferences Section
                Section {
                    Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                    Toggle("Dark Mode", isOn: $isDarkModeEnabled)
                } header: {
                    Text("Preferences")
                }

                // Data Management Section
                Section {
                    NavigationLink {
                        AircraftListView()
                    } label: {
                        Label("Manage Aircraft", systemImage: "airplane")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Data Management")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(versionString)
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://blocktimelogger.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://blocktimelogger.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Are you sure you want to clear all data?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    // TODO: Implement clear all data
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "This will permanently delete all your flights and aircraft data. This action cannot be undone."
                )
            }
            .sheet(isPresented: $isPresentingPaywall) {
                PaywallView(displayCloseButton: true)
            }
        }
    }
}

#Preview {
    SettingsView()
}
