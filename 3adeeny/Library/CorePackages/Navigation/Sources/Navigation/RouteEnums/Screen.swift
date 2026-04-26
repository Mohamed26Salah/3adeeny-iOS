//
//  Screen.swift
// 
//
//  Created by Mohamed Salah on 29/03/2026.
//
import Foundation

public enum Screen {
    case home
    case profile
}

extension Screen: Identifiable {
    public var id: String {
        return String(describing: self).extractedStringBeforeParenthesis()
    }
}

extension Screen: Equatable {
    public static func == (lhs: Screen, rhs: Screen) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Screen: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

