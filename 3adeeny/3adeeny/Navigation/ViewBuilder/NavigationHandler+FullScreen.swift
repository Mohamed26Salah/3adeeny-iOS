//
//  NavigationHandler+FullScreen.swift
// 
//
//  Created by Mohamed Salah on 25/04/2026.
//

import SwiftUI
import Navigation
//MARK: - FullScreen builder

extension NavRouter {
    @ViewBuilder
    public func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .fullScreenView:
            Text("fullScreen")
        }
    }
}
