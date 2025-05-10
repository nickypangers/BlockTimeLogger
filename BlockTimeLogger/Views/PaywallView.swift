//
//  PaywallView.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 10/5/2025.
//

import SwiftUI

struct PaywallView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedPlan: SubscriptionPlan = .monthly

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
              icon: "infinity", title: "Unlimited Flights",
              description: "Log as many flights as you need")
            FeatureRow(
              icon: "chart.bar.fill", title: "Advanced Analytics",
              description: "Detailed insights and statistics")
            FeatureRow(
              icon: "icloud.fill", title: "Cloud Sync",
              description: "Access your data across all devices")
            FeatureRow(
              icon: "doc.text.fill", title: "Export Options",
              description: "Multiple export formats and templates")
            //            FeatureRow(
            //              icon: "bell.fill", title: "Custom Reminders",
            //              description: "Set up notifications for important events")
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
            // TODO: Implement subscription purchase
          } label: {
            Text("Subscribe Now")
              .font(.headline)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.accentColor)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
          .padding(.horizontal)

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
    }
  }
}

struct SubscriptionPlanButton: View {
  let plan: PaywallView.SubscriptionPlan
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
  PaywallView()
}
