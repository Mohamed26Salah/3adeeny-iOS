import SwiftUI

/// A SwiftUI view that renders any `PatternConfig` using a single GPU-backed
/// `Canvas` pass. Animated patterns are driven by `TimelineView`.
/// An optional `PatternLabel` is rendered as an independent overlay.
///
/// ```swift
/// // Static with label
/// PatternView(config: PatternConfig(
///     type: .zebraCrossing(),
///     colors: .warning,
///     label: PatternLabel("STOP", color: .white, animation: .flash(frequency: 2))
/// ))
///
/// // Animated scrolling hazard stripes
/// PatternView(config: .diagonalStripes(animates: true, speed: 60))
/// ```
public struct PatternView: View {
    private let config: PatternConfig

    public init(config: PatternConfig) {
        self.config = config
    }

    /// Shorthand when you only need type + colors (no label, default scale).
    public init(
        _ type: PatternType,
        colors: PatternColors = .blackOnWhite,
        scale: CGFloat = 1.0
    ) {
        self.config = PatternConfig(type: type, colors: colors, scale: scale)
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            patternLayer
            if let label = config.label {
                PatternLabelView(label: label)
            }
        }
    }

    // MARK: - Pattern layer

    @ViewBuilder
    private var patternLayer: some View {
        if needsAnimation {
            TimelineView(.animation) { timeline in
                patternCanvas(time: timeline.date.timeIntervalSinceReferenceDate)
            }
        } else {
            patternCanvas(time: 0)
        }
    }

    /// Flash always animates; other patterns animate only when `config.animates` is true.
    private var needsAnimation: Bool {
        if case .flash = config.type { return true }
        return config.animates
    }

    private func patternCanvas(time: Double) -> some View {
        Canvas { context, size in
            PatternRenderer.draw(
                config: config,
                context: &context,
                size: size,
                time: time
            )
        }
    }
}

// MARK: - Label overlay

/// Renders a `PatternLabel` centred over the pattern with its chosen animation.
private struct PatternLabelView: View {
    let label: PatternLabel

    var body: some View {
        switch label.animation {

        case .none:
            labelText(opacity: 1, scale: 1)

        case .flash(let frequency):
            TimelineView(.animation) { tl in
                let on = sin(2 * Double.pi * frequency * tl.date.timeIntervalSinceReferenceDate) >= 0
                labelText(opacity: on ? 1 : 0, scale: 1)
            }

        case .pulse(let maxScale, let speed):
            TimelineView(.animation) { tl in
                let raw = sin(2 * Double.pi * speed * tl.date.timeIntervalSinceReferenceDate)
                let s   = 1 + (maxScale - 1) * CGFloat((raw + 1) / 2)
                labelText(opacity: 1, scale: s)
            }

        case .fade(let minOpacity, let speed):
            TimelineView(.animation) { tl in
                let raw = sin(2 * Double.pi * speed * tl.date.timeIntervalSinceReferenceDate)
                let op  = minOpacity + (1 - minOpacity) * (raw + 1) / 2
                labelText(opacity: op, scale: 1)
            }
        }
    }

    private func labelText(opacity: Double, scale: CGFloat) -> some View {
        Text(label.text)
            .font(label.font)
            .foregroundStyle(label.color)
            .opacity(opacity)
            .scaleEffect(scale)
    }
}

// MARK: - Previews

// Concrete CustomPattern: upward chevrons scrolling upward — walk signal.
private struct WalkSignalPattern: CustomPattern {
    func draw(
        context: inout GraphicsContext,
        origin: CGPoint,
        size: CGSize,
        colors: PatternColors,
        scale: CGFloat,
        phase: Double
    ) {
        let spacing: CGFloat = 48 * scale
        let armLen:  CGFloat = 14 * scale
        let lineW:   CGFloat = 4  * scale
        let offset   = CGFloat(phase.truncatingRemainder(dividingBy: Double(spacing)))

        let cols = Int(ceil(size.width  / spacing)) + 2
        let rows = Int(ceil(size.height / spacing)) + 2

        var path = Path()
        for row in 0..<rows {
            let xShift: CGFloat = row % 2 == 0 ? 0 : spacing / 2
            for col in 0..<cols {
                let cx = origin.x + CGFloat(col) * spacing + xShift
                let cy = origin.y + CGFloat(row) * spacing - offset
                path.move(to:    CGPoint(x: cx - armLen, y: cy + armLen))
                path.addLine(to: CGPoint(x: cx,          y: cy))
                path.addLine(to: CGPoint(x: cx + armLen, y: cy + armLen))
            }
        }
        context.stroke(path, with: .color(colors.foreground),
                       style: StrokeStyle(lineWidth: lineW, lineCap: .round, lineJoin: .round))
    }
}

#Preview("Labels") {
    ScrollView {
        VStack(spacing: 4) {
            label("Static label")
            PatternView(config: PatternConfig(
                type: .zebraCrossing(),
                colors: .blackOnWhite,
                label: PatternLabel("WAIT", color: .black)
            ))
            .frame(height: 110)

            label("Flashing label on flashing pattern")
            PatternView(config: .flash(
                frequency: 2.0,
                colors: .warning,
                label: PatternLabel("STOP", color: .white, animation: .flash(frequency: 2.0))
            ))
            .frame(height: 110)

            label("Pulse label")
            PatternView(config: PatternConfig(
                type: .diagonalStripes(),
                colors: .hazard,
                animates: true,
                animationSpeed: 50,
                label: PatternLabel("SLOW", color: .black, animation: .pulse(scale: 1.3, speed: 1.2))
            ))
            .frame(height: 110)

            label("Fade label")
            PatternView(config: PatternConfig(
                type: .checkerboard(),
                colors: .safe,
                label: PatternLabel("GO", color: .white, animation: .fade(minOpacity: 0.1, speed: 0.8))
            ))
            .frame(height: 110)

            label("Custom pattern + flashing label")
            PatternView(config: PatternConfig(
                type: .custom(WalkSignalPattern()),
                colors: .safe,
                animates: true,
                animationSpeed: 40,
                label: PatternLabel("WALK", color: .white, animation: .pulse(scale: 1.2, speed: 1.0))
            ))
            .frame(height: 110)
        }
        .padding(.bottom, 12)
    }
}

#Preview("Built-in patterns") {
    ScrollView {
        VStack(spacing: 2) {
            Group {
                label("Zebra Crossing")
                PatternView(config: .zebraCrossing())
                    .frame(height: 100)

                label("Diagonal Stripes — Hazard")
                PatternView(config: .diagonalStripes())
                    .frame(height: 100)

                label("Checkerboard")
                PatternView(config: .checkerboard())
                    .frame(height: 100)

                label("Polka Dots")
                PatternView(.polkaDots(), colors: .blackOnWhite)
                    .frame(height: 100)
            }
            Group {
                label("Grid")
                PatternView(.grid(), colors: .blackOnWhite)
                    .frame(height: 100)

                label("Crosshatch")
                PatternView(.crosshatch(), colors: .warning)
                    .frame(height: 100)

                label("Diamonds")
                PatternView(.diamonds(), colors: .safe)
                    .frame(height: 100)

                label("Herringbone")
                PatternView(.herringbone(), colors: .hazard)
                    .frame(height: 100)

                label("Flash — 2 Hz alarm")
                PatternView(config: .flash(frequency: 2.0, colors: .warning))
                    .frame(height: 100)

                label("Custom — Walk Signal ↑")
                PatternView(config: PatternConfig(
                    type: .custom(WalkSignalPattern()),
                    colors: .safe,
                    animates: true,
                    animationSpeed: 40
                ))
                .frame(height: 100)
            }
        }
    }
}

#Preview("Rotated + Animated") {
    VStack(spacing: 12) {
        Text("Animated zebra — 60 pt/s").font(.caption)
        PatternView(config: PatternConfig(
            type: .zebraCrossing(stripeHeight: 26),
            colors: .blackOnWhite,
            scale: 1.2,
            animates: true,
            animationSpeed: 60
        ))
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16))

        Text("Hazard @ 30° rotation + animated").font(.caption)
        PatternView(config: PatternConfig(
            type: .diagonalStripes(stripeWidth: 22),
            colors: .hazard,
            scale: 1.0,
            rotation: .degrees(30),
            animates: true,
            animationSpeed: 50
        ))
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16))

        Text("Diamonds — safe green, 2× scale").font(.caption)
        PatternView(config: PatternConfig(
            type: .diamonds(halfWidth: 18, halfHeight: 18),
            colors: .safe,
            scale: 2.0
        ))
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16))

        Text("Flash — urgent red/yellow 4 Hz").font(.caption)
        PatternView(config: .flash(frequency: 4.0, colors: .danger))
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding()
}

private func label(_ text: String) -> some View {
    Text(text)
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.top, 8)
}
