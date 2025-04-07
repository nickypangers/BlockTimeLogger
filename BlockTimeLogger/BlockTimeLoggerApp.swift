//
//  BlockTimeLoggerApp.swift
//  BlockTimeLogger
//
//  Created by Nixon Pang on 28/3/2025.
//

// import FirebaseCore
import SwiftUI

//
// class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
//    {
//        FirebaseApp.configure()
//        return true
//    }
// }

@main
struct BlockTimeLoggerApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
            }
        }
    }
}
