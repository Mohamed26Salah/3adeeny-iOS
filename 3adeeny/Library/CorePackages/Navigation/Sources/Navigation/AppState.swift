//
//  AppState.swift
//  Navigation
//
//  Created by Mohamed Salah on 25/04/2026.
//

import Foundation
import SwiftUI
import Factory
import Combine

public enum Tab: String, CaseIterable {
    case home = "home"
    case profile = "profile"
    
    static func convert(from: String) -> Self? {
        return Tab.allCases.first { tab in
            tab.rawValue.lowercased() == from.lowercased()
        }
    }
}

public enum AppStateEnum {
    case onboarding
    case guest
    case loggedIn
}


public class AppState: ObservableObject {
    @Published public var currentAppStateFlow: AppStateEnum = .onboarding {
        didSet {
            rootViewID = UUID()
        }
    }
    
    @Published public var rootViewID: UUID = UUID() //To Reset The views
    @Published public var selectedTab = Tab.home{
        willSet{
            if(selectedTab == newValue){
                resetTab()
            }
        }
    }
    
    @Published public var homeRouter = NavRouter()
    @Published public var profileRouter = NavRouter()
    
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Active Router
    public var activeRouter: NavRouter {
        switch selectedTab {
        case .home:
            return homeRouter
        case .profile:
            return profileRouter
        }
    }
    
    public init() {
        setupBindings()
    }
}

//MARK: - Handle Tabs Visibility -
extension AppState {
    private func setupBindings() {
        // Combine the selectedTab with both routers' paths
        Publishers.CombineLatest3($selectedTab, homeRouter.$path, profileRouter.$path)
            .map { selectedTab, homePath, profilePath -> Bool in
                switch selectedTab {
                case .home:
                    return homePath.isEmpty
                case .profile:
                    return profilePath.isEmpty
                }
            }
            .removeDuplicates()
            .sink { isVisible in
                DispatchQueue.main.async {
                    UITabBar.setVisibility(isVisible)
                }
            }
            .store(in: &cancellables)
    }
}

//MARK: - Handle App DeepLink -

extension AppState {
    public func handleDeepLink(url: URL) {
        //TODO: Handle Deep Link Here
    }
}

//MARK: - Handle App Tab Bar -

extension AppState {
    public func resetTab(){
        switch selectedTab{
        case Tab.home:
            homeRouter.popToRoot()
        case Tab.profile:
            profileRouter.popToRoot()
        }
    }
}

public extension Container {
    var appState: Factory<AppState> {
        Factory(self) { AppState() }
            .singleton
    }
}
