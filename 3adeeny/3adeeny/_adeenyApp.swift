//
//  _adeenyApp.swift
//  3adeeny
//
//  Created by Mohamed Salah on 25/04/2026.
//

import SwiftUI
import Factory
import Navigation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("App will terminate 🛑")
    }
}


@main
struct _adeenyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @InjectedObject(\.appState) var appState
    var body: some Scene {
        WindowGroup {
            RootView()
                .id(appState.rootViewID)
        }
    }
}
