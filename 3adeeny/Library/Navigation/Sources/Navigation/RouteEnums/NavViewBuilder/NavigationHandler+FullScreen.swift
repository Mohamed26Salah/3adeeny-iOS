//
//  NavigationHandler+FullScreen.swift
// 
//
//  Created by Mohamed Salah on 29/03/2026.
//

import SwiftUI

//MARK: - FullScreen builder
extension NavRouter {
    @ViewBuilder
    public func build(fullScreenCover: FullScreenCover) -> some View {
        switch fullScreenCover {
        case .fullScreenView:
            Text("FullScreenSheet")
        }
    }
}
