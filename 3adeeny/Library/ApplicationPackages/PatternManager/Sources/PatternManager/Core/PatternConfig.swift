import SwiftUI

// MARK: - PatternType
// Each case carries the geometry parameters for its shapes.
// All sizes are in points at scale 1.0 — PatternConfig.scale multiplies them uniformly.

public enum PatternType: @unchecked Sendable {

    // ── Road & Crossing ──────────────────────────────────────────────────────

    /// Thick horizontal alternating stripes — the classic pedestrian crossing.
    /// - Parameter stripeHeight: Height of each filled stripe in points.
    case zebraCrossing(stripeHeight: CGFloat = 26)

    /// 45-degree parallelogram stripes — construction hazard tape.
    /// - Parameter stripeWidth: Width of each filled diagonal stripe in points.
    case diagonalStripes(stripeWidth: CGFloat = 22)

    // ── High-Contrast Fills ──────────────────────────────────────────────────

    /// Alternating equal squares.
    /// - Parameter cellSize: Side length of each square in points.
    case checkerboard(cellSize: CGFloat = 32)

    /// Large filled circles on a solid field.
    /// - Parameters:
    ///   - radius:  Circle radius in points.
    ///   - spacing: Centre-to-centre distance in points.
    case polkaDots(radius: CGFloat = 13, spacing: CGFloat = 40)

    // ── Grid & Mesh ──────────────────────────────────────────────────────────

    /// Orthogonal line grid.
    /// - Parameters:
    ///   - spacing:   Distance between grid lines in points.
    ///   - lineWidth: Thickness of each line in points.
    case grid(spacing: CGFloat = 28, lineWidth: CGFloat = 2.5)

    /// Two sets of 45° diagonal lines crossing — diamond mesh.
    /// - Parameters:
    ///   - spacing:   Distance between parallel lines in points.
    ///   - lineWidth: Thickness of each line in points.
    case crosshatch(spacing: CGFloat = 22, lineWidth: CGFloat = 2.5)

    /// Filled rotated squares staggered per row.
    /// - Parameters:
    ///   - halfWidth:  Half the diamond's horizontal span in points.
    ///   - halfHeight: Half the diamond's vertical span in points.
    case diamonds(halfWidth: CGFloat = 18, halfHeight: CGFloat = 18)

    // ── Directional ──────────────────────────────────────────────────────────

    /// Rows of diagonal stripes alternating direction — herringbone weave.
    /// - Parameters:
    ///   - bandHeight:  Vertical height of each direction-band in points.
    ///   - stripeWidth: Width of each filled stripe within the band in points.
    case herringbone(bandHeight: CGFloat = 36, stripeWidth: CGFloat = 14)

    // ── Alarm / Alert ────────────────────────────────────────────────────────

    /// Full-view hard flash between foreground and background colours.
    /// - Parameter frequency: Number of on/off cycles per second (Hz).
    ///   1 Hz = slow pulse, 4 Hz = urgent alarm.
    case flash(frequency: Double = 2.0)

    // ── Custom ───────────────────────────────────────────────────────────────

    /// Fully custom drawing — conform to `CustomPattern` and pass it here.
    case custom(any CustomPattern)
}

// MARK: - PatternConfig

/// The single value you hand to `PatternView`.
/// Geometry sizing lives in `PatternType`; global scale, colors, rotation,
/// animation speed, and opacity live here.
public struct PatternConfig: Sendable {

    public let type: PatternType

    /// Foreground (shape) and background colours.
    /// Every preset in `PatternColors` can be used, or build your own:
    /// `PatternColors(foreground: .red, background: .white)`
    public let colors: PatternColors

    /// Global scale multiplier applied on top of per-pattern shape sizes.
    /// 1.0 = default baseline, 0.5 = smaller tiles, 2.0 = bigger tiles.
    public let scale: CGFloat

    /// Rotates the whole pattern around the view centre — no clipping occurs.
    public let rotation: Angle

    /// Overall opacity of the pattern layer (0 = invisible, 1 = fully opaque).
    public let opacity: Double

    /// When `true` the pattern scrolls / flashes continuously.
    /// `.flash` patterns always animate regardless of this flag.
    public let animates: Bool

    /// Speed of the scroll animation in points-per-second.
    /// Only meaningful for scrolling patterns; ignored by `.flash` (use its `frequency` instead).
    /// 30–60 = subtle, 80–120 = urgent.
    public let animationSpeed: Double

    /// Optional single-word label rendered centred over the pattern.
    /// Supports its own independent animation (flash, pulse, fade).
    public let label: PatternLabel?

    public init(
        type: PatternType,
        colors: PatternColors = .blackOnWhite,
        scale: CGFloat = 1.0,
        rotation: Angle = .zero,
        opacity: Double = 1.0,
        animates: Bool = false,
        animationSpeed: Double = 40,
        label: PatternLabel? = nil
    ) {
        self.type           = type
        self.colors         = colors
        self.scale          = max(0.25, min(scale, 6.0))
        self.rotation       = rotation
        self.opacity        = max(0, min(opacity, 1))
        self.animates       = animates
        self.animationSpeed = animationSpeed
        self.label          = label
    }
}

// MARK: - Convenience factories
// These let callers configure everything in one line without remembering enum syntax.

public extension PatternConfig {

    /// Zebra crossing with full control over stripe size, colours, and animation.
    static func zebraCrossing(
        stripeHeight: CGFloat = 26,
        colors: PatternColors = .blackOnWhite,
        scale: CGFloat = 1.0,
        animates: Bool = false,
        speed: Double = 40,
        label: PatternLabel? = nil
    ) -> PatternConfig {
        PatternConfig(type: .zebraCrossing(stripeHeight: stripeHeight),
                      colors: colors, scale: scale, animates: animates, animationSpeed: speed,
                      label: label)
    }

    /// Diagonal hazard stripes with full control.
    static func diagonalStripes(
        stripeWidth: CGFloat = 22,
        colors: PatternColors = .hazard,
        scale: CGFloat = 1.0,
        rotation: Angle = .zero,
        animates: Bool = false,
        speed: Double = 50,
        label: PatternLabel? = nil
    ) -> PatternConfig {
        PatternConfig(type: .diagonalStripes(stripeWidth: stripeWidth),
                      colors: colors, scale: scale, rotation: rotation,
                      animates: animates, animationSpeed: speed, label: label)
    }

    /// Checkerboard with full control.
    static func checkerboard(
        cellSize: CGFloat = 32,
        colors: PatternColors = .blackOnWhite,
        scale: CGFloat = 1.0,
        label: PatternLabel? = nil
    ) -> PatternConfig {
        PatternConfig(type: .checkerboard(cellSize: cellSize), colors: colors, scale: scale,
                      label: label)
    }

    /// Polka dots with full control.
    static func polkaDots(
        radius: CGFloat = 13,
        spacing: CGFloat = 40,
        colors: PatternColors = .blackOnWhite,
        scale: CGFloat = 1.0,
        label: PatternLabel? = nil
    ) -> PatternConfig {
        PatternConfig(type: .polkaDots(radius: radius, spacing: spacing),
                      colors: colors, scale: scale, label: label)
    }

    /// Full-view flash alarm. Always animates — `animates` flag not required.
    static func flash(
        frequency: Double = 2.0,
        colors: PatternColors = .blackOnWhite,
        label: PatternLabel? = nil
    ) -> PatternConfig {
        PatternConfig(type: .flash(frequency: frequency), colors: colors, animates: true,
                      label: label)
    }

    /// Rotated zebra — vertical stripes for side panels.
    static func verticalZebra(
        stripeHeight: CGFloat = 26,
        colors: PatternColors = .blackOnWhite,
        scale: CGFloat = 1.0,
        label: PatternLabel? = nil
    ) -> PatternConfig {
        PatternConfig(type: .zebraCrossing(stripeHeight: stripeHeight),
                      colors: colors, scale: scale, rotation: .degrees(90), label: label)
    }
}
