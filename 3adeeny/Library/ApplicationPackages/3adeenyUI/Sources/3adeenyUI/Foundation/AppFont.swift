import SwiftUI

/// Typography scale built on SF Pro (the iOS system font).
/// All sizes mirror Apple's Human Interface Guidelines type ramp so the app
/// feels native while still being easy to override per-screen.
public enum AppFont {

    // MARK: - Display

    /// 34 pt  Bold  — hero screens, empty-state headlines.
    public static let largeTitle    = Font.system(size: 34, weight: .bold,     design: .default)
    /// 28 pt  Bold  — screen titles in navigation bars.
    public static let title         = Font.system(size: 28, weight: .bold,     design: .default)
    /// 22 pt  SemiBold — section headers, modal titles.
    public static let title2        = Font.system(size: 22, weight: .semibold, design: .default)
    /// 20 pt  SemiBold — card titles, prominent labels.
    public static let title3        = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: - Body

    /// 17 pt  SemiBold — list row labels, button labels, tab bar items.
    public static let headline      = Font.system(size: 17, weight: .semibold, design: .default)
    /// 17 pt  Regular  — primary readable content.
    public static let body          = Font.system(size: 17, weight: .regular,  design: .default)
    /// 16 pt  Regular  — secondary body copy.
    public static let callout       = Font.system(size: 16, weight: .regular,  design: .default)
    /// 15 pt  Regular  — supporting info under a headline.
    public static let subheadline   = Font.system(size: 15, weight: .regular,  design: .default)

    // MARK: - Small

    /// 13 pt  Regular  — metadata, timestamps.
    public static let footnote      = Font.system(size: 13, weight: .regular,  design: .default)
    /// 13 pt  Medium   — labels on tags, chips.
    public static let footnoteMedium = Font.system(size: 13, weight: .medium,  design: .default)
    /// 12 pt  Regular  — image captions, fine print.
    public static let caption       = Font.system(size: 12, weight: .regular,  design: .default)
    /// 11 pt  Regular  — badge labels, the smallest legible text.
    public static let caption2      = Font.system(size: 11, weight: .regular,  design: .default)
}

// MARK: - View modifier convenience

public extension View {
    func appFont(_ font: Font) -> some View {
        self.font(font)
    }
}
