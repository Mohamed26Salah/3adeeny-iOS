import SwiftUI

/// An optional text overlay rendered on top of a `PatternView`.
/// Supports one word and four animation styles.
///
/// ```swift
/// PatternView(config: PatternConfig(
///     type: .zebraCrossing(),
///     colors: .warning,
///     label: PatternLabel("STOP", color: .white, animation: .flash(frequency: 2))
/// ))
/// ```
public struct PatternLabel: Sendable {

    // MARK: - Animation

    public enum LabelAnimation: Sendable {
        /// Static — no animation.
        case none

        /// Hard on/off flash between full and zero opacity.
        /// - Parameter frequency: Cycles per second. Matches `PatternType.flash` convention.
        case flash(frequency: Double = 2.0)

        /// Rhythmic scale pulse between 1.0 and `scale`.
        /// - Parameters:
        ///   - scale: Peak scale factor (e.g. 1.25 = 25 % larger at peak).
        ///   - speed: Full pulse cycles per second.
        case pulse(scale: CGFloat = 1.25, speed: Double = 1.0)

        /// Rhythmic fade between `minOpacity` and 1.0.
        /// - Parameters:
        ///   - minOpacity: Dimmest opacity during the cycle.
        ///   - speed: Full fade cycles per second.
        case fade(minOpacity: Double = 0.25, speed: Double = 1.0)
    }

    // MARK: - Properties

    /// One word displayed centred over the pattern.
    public let text: String

    /// Text colour.
    public let color: Color

    /// SwiftUI font — defaults to a large, heavy rounded style that reads
    /// well over busy patterns.
    public let font: Font

    /// How (if at all) the text animates independently of the pattern.
    public let animation: LabelAnimation

    // MARK: - Init

    public init(
        _ text: String,
        color: Color = .white,
        font: Font = .system(size: 52, weight: .black, design: .rounded),
        animation: LabelAnimation = .none
    ) {
        self.text      = text
        self.color     = color
        self.font      = font
        self.animation = animation
    }
}
