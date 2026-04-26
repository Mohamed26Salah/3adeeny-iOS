import CoreFoundation

/// Layout constants. Prefer these tokens over raw numbers so that tightening
/// or loosening the layout only requires changing one file.
public enum AppSpacing {

    // MARK: - Spacing scale (8-point grid)

    /// 4 pt  — icon-to-label gaps, inline badge padding.
    public static let xs:   CGFloat = 4
    /// 8 pt  — tight internal padding (chip, tag).
    public static let sm:   CGFloat = 8
    /// 12 pt — compact list row vertical padding.
    public static let smMd: CGFloat = 12
    /// 16 pt — default internal padding, list row horizontal insets.
    public static let md:   CGFloat = 16
    /// 20 pt — comfortable card padding.
    public static let mdLg: CGFloat = 20
    /// 24 pt — section spacing inside a screen.
    public static let lg:   CGFloat = 24
    /// 32 pt — space between major sections.
    public static let xl:   CGFloat = 32
    /// 48 pt — hero / splash vertical breathing room.
    public static let xxl:  CGFloat = 48

    // MARK: - Screen insets

    /// Standard horizontal margin from screen edge to content.
    public static let screenHorizontal: CGFloat = md
    /// Standard vertical margin at the top/bottom of a scrollable screen.
    public static let screenVertical:   CGFloat = lg

    // MARK: - Corner Radii

    public enum Radius {
        /// 4 pt  — tags, small badges.
        public static let xs:   CGFloat = 4
        /// 8 pt  — input fields, small cards.
        public static let sm:   CGFloat = 8
        /// 12 pt — standard cards, sheets.
        public static let md:   CGFloat = 12
        /// 16 pt — large cards, bottom sheets.
        public static let lg:   CGFloat = 16
        /// 24 pt — hero image corners, modals.
        public static let xl:   CGFloat = 24
        /// 9999  — pill/capsule shapes (buttons, tags).
        public static let full: CGFloat = 9999
    }

    // MARK: - Icon sizes

    public enum Icon {
        public static let sm:  CGFloat = 16
        public static let md:  CGFloat = 24
        public static let lg:  CGFloat = 32
        public static let xl:  CGFloat = 48
    }
}
