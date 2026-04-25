//
//  Sheet.swift
//  
//
//  Created by Mohamed Salah on 29/03/2026.
//

import Foundation

public enum Sheet {
    case bottomSheet
}

extension Sheet: Identifiable {
    public var id: String {
        return String(describing: self).extractedStringBeforeParenthesis()
    }
}

extension Sheet: Equatable {
    public static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        return lhs.id == rhs.id
    }
}

