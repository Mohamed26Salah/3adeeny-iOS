import SwiftUI

/// Conform to this protocol to create a fully custom pattern and pass it to
/// `PatternView` exactly like any built-in type.
///
/// Example:
/// ```swift
/// struct ChevronPattern: CustomPattern {
///     func draw(context: inout GraphicsContext, origin: CGPoint,
///               size: CGSize, colors: PatternColors,
///               scale: CGFloat, phase: Double) {
///         // your Canvas drawing code here
///     }
/// }
///
/// PatternView(config: PatternConfig(type: .custom(ChevronPattern()), colors: .hazard))
/// ```
///
/// - Note: `phase` is a continuously growing value driven by elapsed time × animation speed.
///   Take the modulo of your own tile period to get a smooth loop offset.
public protocol CustomPattern: Sendable {
    /// Draw the pattern into `context`.
    ///
    /// - Parameters:
    ///   - context: A mutable `GraphicsContext` scoped to the view's bounds.
    ///              Rotation (if any) is already applied — draw as if the canvas is axis-aligned.
    ///   - origin:  Top-left corner of the drawing area (may be negative when the pattern
    ///              is expanded to cover rotation overshoot).
    ///   - size:    Drawing area dimensions (may be larger than the view when rotated).
    ///   - colors:  Foreground and background resolved from `PatternConfig`.
    ///   - scale:   Uniform scale factor; multiply all geometry constants by this value.
    ///   - phase:   `elapsed × animationSpeed` — take `phase.truncatingRemainder(dividingBy: period)`
    ///              to derive a scroll offset that loops cleanly.
    func draw(
        context: inout GraphicsContext,
        origin: CGPoint,
        size: CGSize,
        colors: PatternColors,
        scale: CGFloat,
        phase: Double
    )
}
