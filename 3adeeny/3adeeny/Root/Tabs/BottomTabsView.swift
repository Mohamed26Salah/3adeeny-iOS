//
//  TabsView.swift
//
//
//  Created by Mohamed Salah on 25/04/2026.
//


import Factory
import SwiftUI
import Navigation
import UIKit

public struct BottomTabsView : View {
    @InjectedObject(\.appState) var appState: AppState
    @State var updateState: Bool = false
    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            homeTabView()
            merchantTabView()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    @ViewBuilder
    func homeTabView() -> some View {
        NavRouterView(
            Router: appState.homeRouter,
            rootView: .home
        )
        .navigationViewStyle(.stack)
        .tag(Tab.home)
        .tabItem {
            Label{
                Text("Home")
            } icon: {
                Image(systemName: "house.fill")
                    .renderingMode(.template)
            }
        }
    }
    
    @ViewBuilder
    func merchantTabView() -> some View {
        NavRouterView(
            Router: appState.profileRouter,
            rootView: .profile
        )
        .tag(Tab.profile)
        .tabItem {
            Label{
                Text("Profile")
            } icon: {
                Image(systemName: "person.fill")
                    .renderingMode(.template)
            }
        }
    }
}
