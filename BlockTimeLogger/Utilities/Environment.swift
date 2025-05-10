import Foundation

enum AppConfig {
  static func value(for key: String) -> String {
    guard let value = Bundle.main.infoDictionary?[key] as? String else {
      fatalError("Could not find value for key: \(key)")
    }
    return value
  }

  static var revenueCatApiKey: String {
    value(for: "REVENUECAT_API_KEY")
  }
}
