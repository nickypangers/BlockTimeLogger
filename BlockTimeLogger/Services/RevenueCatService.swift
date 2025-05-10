import RevenueCat
import SwiftUI

class RevenueCatService: ObservableObject {
  static let shared = RevenueCatService()

  @Published var customerInfo: CustomerInfo?
  @Published var isPro: Bool = false

  private init() {
    // Configure RevenueCat
    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: AppConfig.revenueCatApiKey)

    // Get current customer info
    Task {
      await refreshCustomerInfo()
    }
  }

  @MainActor
  func refreshCustomerInfo() async {
    do {
      customerInfo = try await Purchases.shared.customerInfo()
      isPro = customerInfo?.entitlements["pro"]?.isActive == true
    } catch {
      print("Error fetching customer info: \(error)")
    }
  }

  func purchase(plan: LocalPaywallView.SubscriptionPlan) async throws {
    let productId = plan == .monthly ? "pro_monthly" : "pro_yearly"

    do {
      let offerings = try await Purchases.shared.offerings()
      guard let offering = offerings.current,
        let package = offering.package(identifier: productId)
      else {
        throw NSError(
          domain: "RevenueCatService", code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Product not found"])
      }

      let result = try await Purchases.shared.purchase(package: package)
      customerInfo = result.customerInfo
      isPro = result.customerInfo.entitlements["pro"]?.isActive == true
    } catch {
      print("Purchase failed: \(error)")
      throw error
    }
  }

  func restorePurchases() async throws {
    do {
      customerInfo = try await Purchases.shared.restorePurchases()
      isPro = customerInfo?.entitlements["pro"]?.isActive == true
    } catch {
      print("Restore failed: \(error)")
      throw error
    }
  }
}
