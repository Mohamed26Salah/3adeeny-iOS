//
//  NavigationHandler+Sheet.swift
//
//
//  Created by Mohamed Salah on 25/04/2026.
//

import Foundation
import SwiftUI
import Navigation
//MARK: - Sheet builder -

extension NavRouter {
    
    @ViewBuilder
    public func build(sheet: Sheet) -> some View {
        switch sheet {
        case .bottomSheet:
            Text("bottomSheet")
        }
    }
}

