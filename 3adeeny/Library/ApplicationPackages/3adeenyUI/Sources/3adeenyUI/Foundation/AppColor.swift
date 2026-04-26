import SwiftUI

// MARK: - Adaptive initialiser

public extension Color {
    /// Creates a color that resolves to different values in light and dark mode.
    init(light: Color, dark: Color) {
        self = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
}

// MARK: - AppColor

/// Central color palette. Every token is adaptive — pass the whole file to a designer
/// and swap values here when branding evolves; no view code needs to change.
public enum AppColor {

    // MARK: Backgrounds

    /// Page / screen background.
    public static let background        = Color(light: .white,                    dark: .black)
    /// Cards, sheets, grouped list rows.
    public static let surface           = Color(light: Color(white: 0.96),        dark: Color(white: 0.10))
    /// Modals or overlapping surfaces one level above `surface`.
    public static let surfaceElevated   = Color(light: .white,                    dark: Color(white: 0.16))

    // MARK: Labels

    /// Primary text — highest contrast.
    public static let label             = Color(light: .black,                    dark: .white)
    /// Supporting text, subtitles.
    public static let labelSecondary    = Color(light: Color(white: 0.35),        dark: Color(white: 0.65))
    /// Placeholder text, hints.
    public static let labelTertiary     = Color(light: Color(white: 0.55),        dark: Color(white: 0.45))
    /// Non-interactive / inactive labels.
    public static let labelDisabled     = Color(light: Color(white: 0.75),        dark: Color(white: 0.30))

    // MARK: Interactive — Primary

    /// Fill of primary action elements (buttons, toggles, etc.).
    public static let primary           = Color(light: .black,                    dark: .white)
    /// Foreground drawn on top of `primary` fill.
    public static let primaryForeground = Color(light: .white,                    dark: .black)

    // MARK: Borders & Separators

    /// Lines between list rows, card borders.
    public static let separator         = Color(light: Color(white: 0.88),        dark: Color(white: 0.22))
    /// Strokes on secondary / outlined elements.
    public static let border            = Color(light: Color(white: 0.78),        dark: Color(white: 0.32))

    // MARK: Feedback

    /// Destructive actions (delete, logout).
    public static let destructive           = Color(light: Color(red: 0.91, green: 0.19, blue: 0.19),
                                                    dark:  Color(red: 1.00, green: 0.38, blue: 0.38))
    public static let destructiveForeground = Color.white

    /// Success confirmation.
    public static let success               = Color(light: Color(red: 0.13, green: 0.65, blue: 0.33),
                                                    dark:  Color(red: 0.24, green: 0.80, blue: 0.48))
    public static let successForeground     = Color.white
}
