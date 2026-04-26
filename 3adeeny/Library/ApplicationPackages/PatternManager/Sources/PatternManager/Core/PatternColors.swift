import SwiftUI

/// A foreground + background pair that drives a pattern's contrast.
/// Add new presets here as the brand evolves — no view code needs to change.
public struct PatternColors: Sendable {
    public let foreground: Color
    public let background: Color

    public init(foreground: Color, background: Color) {
        self.foreground = foreground
        self.background = background
    }

    // MARK: - Presets

    /// Classic pedestrian crossing — maximum contrast.
    public static let blackOnWhite   = PatternColors(foreground: .black,  background: .white)
    public static let whiteOnBlack   = PatternColors(foreground: .white,  background: .black)

    /// Construction / hazard tape.
    public static let hazard         = PatternColors(
        foreground: Color(red: 1.00, green: 0.84, blue: 0.00),
        background: .black
    )

    /// Emergency / alert.
    public static let warning        = PatternColors(
        foreground: Color(red: 0.91, green: 0.19, blue: 0.19),
        background: .white
    )

    /// Road-works orange.
    public static let construction   = PatternColors(
        foreground: Color(red: 1.00, green: 0.50, blue: 0.00),
        background: .black
    )

    /// High-visibility green (safe-to-cross signal).
    public static let safe           = PatternColors(
        foreground: Color(red: 0.13, green: 0.72, blue: 0.33),
        background: .black
    )

    /// Red-on-yellow — danger, do not cross.
    public static let danger         = PatternColors(
        foreground: Color(red: 0.91, green: 0.19, blue: 0.19),
        background: Color(red: 1.00, green: 0.84, blue: 0.00)
    )
}
