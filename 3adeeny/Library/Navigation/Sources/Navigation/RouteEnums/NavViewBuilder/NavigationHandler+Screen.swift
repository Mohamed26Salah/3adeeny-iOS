//
//  NavigationHandler+Screen.swift
//  
//
//  Created by Mohamed Salah on 29/03/2026.
//

import SwiftUI

//MARK: - Screen builder
extension NavRouter {
    @ViewBuilder
    public func build(screen: Screen) -> some View {
        switch screen {
        case .home:
            Text("Home")
        case .profile:
            Text("Profile")
        }
    }
}
