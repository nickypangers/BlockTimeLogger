//
//  PaywallView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 10/5/2025.
//

import RevenueCat
import SwiftUI

struct LocalPaywallView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var revenueCat = RevenueCatService.shared
  @State private var selectedPlan: SubscriptionPlan = .monthly
  @State private var isPurchasing = false
  @State private var showError = false
  @State private var errorMessage = ""

  enum SubscriptionPlan: String, CaseIterable {
    case monthly = "Monthly"
    case yearly = "Yearly"

    var price: String {
      switch self {
      case .monthly: return "$4.99"
      case .yearly: return "$49.99"
      }
    }

    var originalPrice: String? {
      switch self {
      case .monthly: return nil
      case .yearly: return "$59.99"
      }
    }

    var period: String {
      switch self {
      case .monthly: return "per month"
      case .yearly: return "per year"
      }
    }

    var savings: String? {
      switch self {
      case .monthly: return nil
      case .yearly: return "Save 16%"
      }
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 32) {
          // Header
          VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
              .font(.system(size: 60))
              .foregroundColor(.yellow)

            Text("Upgrade to Pro")
              .font(.title.bold())

            Text("Unlock all features and take your flight logging to the next level")
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          }
          .padding(.top, 32)

          // Features
          VStack(spacing: 24) {
            FeatureRow(
              icon: "infinity", title: "Unlimited Flights & Sims",
              description: "Log as many flights and simulator sessions as you need")
            FeatureRow(
              icon: "chart.bar.fill", title: "Advanced Analytics",
              description: "Detailed insights and statistics about your flying")
            FeatureRow(
              icon: "doc.text.fill", title: "Export Options",
              description: "Multiple export formats and templates")
            FeatureRow(
              icon: "icloud.fill", title: "Cloud Sync",
              description: "Access your data across all devices")
            FeatureRow(
              icon: "chart.line.uptrend.xyaxis", title: "Custom Reports & Insights",
              description:
                "Create personalized reports and get deeper insights into your flying patterns")
          }
          .padding(.horizontal)

          // Subscription Plans
          VStack(spacing: 16) {
            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
              SubscriptionPlanButton(
                plan: plan,
                isSelected: selectedPlan == plan,
                action: { selectedPlan = plan })
            }
          }
          .padding(.horizontal)

          // Subscribe Button
          Button {
            Task {
              await purchase()
            }
          } label: {
            if isPurchasing {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              Text("Subscribe Now")
                .font(.headline)
            }
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.accentColor)
          .foregroundColor(.white)
          .cornerRadius(12)
          .disabled(isPurchasing)
          .padding(.horizontal)

          // Restore Purchases
          Button {
            Task {
              await restorePurchases()
            }
          } label: {
            Text("Restore Purchases")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }

          // Terms
          Text(
            "Cancel anytime. Subscription will automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period."
          )
          .font(.caption)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
        }
        .padding(.bottom, 32)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.secondary)
          }
        }
      }
      .alert("Error", isPresented: $showError) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage)
      }
    }
  }

  private func purchase() async {
    isPurchasing = true
    do {
      try await revenueCat.purchase(plan: selectedPlan)
      dismiss()
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
    isPurchasing = false
  }

  private func restorePurchases() async {
    isPurchasing = true
    do {
      try await revenueCat.restorePurchases()
      if revenueCat.isPro {
        dismiss()
      } else {
        errorMessage = "No previous purchases found"
        showError = true
      }
    } catch {
      errorMessage = error.localizedDescription
      showError = true
    }
    isPurchasing = false
  }
}

struct SubscriptionPlanButton: View {
  let plan: LocalPaywallView.SubscriptionPlan
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(plan.rawValue)
            .font(.headline)
          HStack {
            Text(plan.price)
              .font(.title3.bold())
            if let originalPrice = plan.originalPrice {
              Text(originalPrice)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .strikethrough()
            }
          }
          Text(plan.period)
            .font(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()

        if let savings = plan.savings {
          Text(savings)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .cornerRadius(8)
        }

        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? .accentColor : .secondary)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: 2)
      )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  LocalPaywallView()
}
