//
//  NavigationHandler+Sheet.swift
//
//
//  Created by Mohamed Salah on 29/03/2026.
//

import Foundation
import SwiftUI
//MARK: - Sheet builder -

extension NavRouter {
    
    @ViewBuilder
    public func build(sheet: Sheet) -> some View {
        switch sheet {
        case .bottomSheet:
            Text("BottomSheet")
        }
    }
}

