//
//  Router.swift
//  KodeiOS
//
//  Created by Mohamed Salah on 10/03/2024.
//  Copyright © 2024 34ML. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public class NavRouter: ObservableObject {
    
    @Published public var path: [Screen] = []
    @Published public var sheet: Sheet?
    @Published public var fullScreenCover: FullScreenCover?
    
    public init() {}
    
    public func push(_ screen: Screen) {
        path.append(screen)
    }
    
    public func present(sheet: Sheet) {
        self.sheet = sheet
    }
    
    public func present(fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    // MARK: - In-house Navigation

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    public func popToRoot() {
        path.removeAll()
    }
    
    public func pop(count: Int) {
        guard count > 0, count <= path.count else { return }
        path.removeLast(count)
    }
    
    public func pop(to screen: Screen) {
        guard let index = path.lastIndex(of: screen) else { return }
        path.removeSubrange((index + 1)...)
    }
    
    public func dismissSheet() {
        self.sheet = nil
    }
    
    public func dismissFullScreenCover() {
        self.fullScreenCover = nil
    }
}
