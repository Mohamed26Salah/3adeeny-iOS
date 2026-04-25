//
//  NavigationHandler+Screen.swift
//
//
//  Created by Mohamed Salah on 25/04/2026.
//

import Foundation
import SwiftUI
import Navigation
//MARK: - Screen builder

extension NavRouter {
    @ViewBuilder
    public func build(screen: Screen) -> some View {
        switch screen {
        case .home:
            Text("Home")
        case .profile:
            Text("FullScreen")
        }
    }
}
