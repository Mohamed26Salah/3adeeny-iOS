//
//  NavRouterView.swift
//
//
//  Created by Mohamed Salah on 25/04/2026.
//

import SwiftUI
import Navigation
public struct NavRouterView: View {
    @StateObject var router: NavRouter
    var rootView: Screen
    
    public init(Router: NavRouter, rootView: Screen) {
        self._router = StateObject(wrappedValue: Router)
        self.rootView = rootView
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            router.build(screen: rootView)
                .navigationDestination(for: Screen.self) { screen in
                    router.build(screen: screen)
                }
                .sheet(item: $router.sheet) { sheet in
                    router.build(sheet: sheet)
                }
                .fullScreenCover(item: $router.fullScreenCover) { fullScreenCover in
                    router.build(fullScreenCover: fullScreenCover)
                }
        }
        .environmentObject(router)
    }
}

