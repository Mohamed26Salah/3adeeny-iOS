//
//  RootView2.swift
//  PC-Revamp
//
//  Created by Mohamed Salah on 07/08/2024.
//

import SwiftUI
import Factory
import Navigation

public struct RootView: View {
    @InjectedObject(\.appState) var appState
    
    public init() {
    }
    
    public var body: some View {
        Group {
            switch appState.currentAppStateFlow {
            case .onboarding:
                OnbaordingView()
            case .guest:
                Text("guest")
            case .loggedIn:
                BottomTabsView()
            }
        }
    }
}



//TODO: Mak an actual Screen

struct OnbaordingView: View {
    @Injected(\.appState) var appState: AppState
    var body: some View {
        VStack {
            Button {
                appState.currentAppStateFlow = .loggedIn
            } label: {
                Text("➡️ Sign In")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

        }
    }
}
