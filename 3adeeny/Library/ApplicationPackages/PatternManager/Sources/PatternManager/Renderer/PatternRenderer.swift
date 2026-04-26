import SwiftUI

/// Stateless drawing engine — pure functions, no stored state.
/// `time` is raw seconds since a stable reference so each function
/// can derive its own scroll offset or flash phase independently.
enum PatternRenderer {

    // MARK: - Entry point

    static func draw(
        config: PatternConfig,
        context: inout GraphicsContext,
        size: CGSize,
        time: Double
    ) {
        // ── Flash is special: no rotation, no expansion, just fill the whole view ──
        if case .flash(let frequency) = config.type {
            drawFlash(ctx: &context, size: size,
                      frequency: frequency, colors: config.colors,
                      opacity: config.opacity, time: time)
            return
        }

        // 1 ── Fill background
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(config.colors.background.opacity(config.opacity))
        )

        // 2 ── Clip to view bounds — rotation overshoot won't leak
        context.clip(to: Path(CGRect(origin: .zero, size: size)))

        // 3 ── Build a rotated copy of the (already clipped) context
        var ctx = context
        let (drawOrigin, drawSize) = expandedRect(for: size, rotation: config.rotation)

        if config.rotation.radians != 0 {
            ctx.translateBy(x: size.width / 2,  y: size.height / 2)
            ctx.rotate(by: config.rotation)
            ctx.translateBy(x: -size.width / 2, y: -size.height / 2)
        }

        let fg = GraphicsContext.Shading.color(config.colors.foreground.opacity(config.opacity))
        let s  = config.scale
        let spd = config.animationSpeed

        // 4 ── Dispatch
        switch config.type {
        case .zebraCrossing(let stripeHeight):
            drawZebra(ctx: &ctx, o: drawOrigin, s: drawSize,
                      stripeH: stripeHeight * s, fg: fg, time: time, speed: spd)

        case .diagonalStripes(let stripeWidth):
            drawDiagonalStripes(ctx: &ctx, o: drawOrigin, s: drawSize,
                                stripeW: stripeWidth * s, fg: fg, time: time, speed: spd)

        case .checkerboard(let cellSize):
            drawCheckerboard(ctx: &ctx, o: drawOrigin, s: drawSize,
                             cell: cellSize * s, fg: fg)

        case .polkaDots(let radius, let spacing):
            drawPolkaDots(ctx: &ctx, o: drawOrigin, s: drawSize,
                          radius: radius * s, spacing: spacing * s, fg: fg)

        case .grid(let spacing, let lineWidth):
            drawGrid(ctx: &ctx, o: drawOrigin, s: drawSize,
                     spacing: spacing * s, lineW: max(1, lineWidth * s), fg: fg)

        case .crosshatch(let spacing, let lineWidth):
            drawCrosshatch(ctx: &ctx, o: drawOrigin, s: drawSize,
                           spacing: spacing * s, lineW: max(1, lineWidth * s), fg: fg)

        case .diamonds(let halfWidth, let halfHeight):
            drawDiamonds(ctx: &ctx, o: drawOrigin, s: drawSize,
                         hw: halfWidth * s, hh: halfHeight * s, fg: fg)

        case .herringbone(let bandHeight, let stripeWidth):
            drawHerringbone(ctx: &ctx, o: drawOrigin, s: drawSize,
                            bandH: bandHeight * s, stripeW: stripeWidth * s, fg: fg)

        case .custom(let pattern):
            let scrollOffset = time * spd
            pattern.draw(context: &ctx, origin: drawOrigin, size: drawSize,
                         colors: config.colors, scale: s, phase: scrollOffset)

        case .flash:
            break // handled above
        }
    }

    // MARK: - Geometry helpers

    private static func expandedRect(
        for size: CGSize,
        rotation: Angle
    ) -> (origin: CGPoint, size: CGSize) {
        guard rotation.radians != 0 else { return (.zero, size) }
        let d = ceil(sqrt(size.width * size.width + size.height * size.height))
        return (
            CGPoint(x: -(d - size.width) / 2, y: -(d - size.height) / 2),
            CGSize(width: d, height: d)
        )
    }

    private static func scrollOffset(time: Double, speed: Double, period: CGFloat) -> CGFloat {
        CGFloat(time * speed).truncatingRemainder(dividingBy: period)
    }

    // MARK: ── Flash ──────────────────────────────────────────────────────────
    //
    //  Full-view solid fill that toggles between foreground and background.
    //  sin() produces a smooth -1…1 wave; threshold at 0 gives a hard toggle.

    private static func drawFlash(
        ctx: inout GraphicsContext,
        size: CGSize,
        frequency: Double,
        colors: PatternColors,
        opacity: Double,
        time: Double
    ) {
        let isOn  = sin(2 * Double.pi * frequency * time) >= 0
        let color = isOn ? colors.foreground : colors.background
        ctx.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .color(color.opacity(opacity))
        )
    }

    // MARK: ── Zebra Crossing ─────────────────────────────────────────────────
    //
    //  ██████████████████████
    //  ░░░░░░░░░░░░░░░░░░░░░░   ← stripeH gap
    //  ██████████████████████
    //
    //  Filled rects in alternating rows. The gap is always equal to stripeH.

    private static func drawZebra(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        stripeH: CGFloat,
        fg: GraphicsContext.Shading,
        time: Double, speed: Double
    ) {
        let period = stripeH * 2
        let offset = scrollOffset(time: time, speed: speed, period: period)
        var path   = Path()
        var y      = o.y - period + offset
        var fill   = true
        while y < o.y + s.height + stripeH {
            if fill {
                path.addRect(CGRect(x: o.x, y: y, width: s.width, height: stripeH))
            }
            y    += stripeH
            fill.toggle()
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Diagonal Stripes ───────────────────────────────────────────────
    //
    //  ▓▓░░▓▓░░▓▓  (45° parallelograms)
    //
    //  Each stripe is a parallelogram: top-left corner scrolls by `offset`.

    private static func drawDiagonalStripes(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        stripeW: CGFloat,
        fg: GraphicsContext.Shading,
        time: Double, speed: Double
    ) {
        let period = stripeW * 2
        let offset = scrollOffset(time: time, speed: speed, period: period)
        let extra  = s.height   // diagonal overshoot
        var path   = Path()
        var x      = o.x - extra - period + offset
        while x < o.x + s.width + extra {
            path.move(to:    CGPoint(x: x,             y: o.y))
            path.addLine(to: CGPoint(x: x + stripeW,   y: o.y))
            path.addLine(to: CGPoint(x: x + stripeW + extra, y: o.y + s.height))
            path.addLine(to: CGPoint(x: x + extra,     y: o.y + s.height))
            path.closeSubpath()
            x += period
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Checkerboard ───────────────────────────────────────────────────
    //
    //  ▓░▓░▓░
    //  ░▓░▓░▓

    private static func drawCheckerboard(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        cell: CGFloat,
        fg: GraphicsContext.Shading
    ) {
        let cols = Int(ceil(s.width  / cell)) + 2
        let rows = Int(ceil(s.height / cell)) + 2
        var path = Path()
        for row in 0..<rows {
            for col in 0..<cols {
                guard (row + col) % 2 == 0 else { continue }
                path.addRect(CGRect(
                    x: o.x + CGFloat(col) * cell,
                    y: o.y + CGFloat(row) * cell,
                    width: cell, height: cell
                ))
            }
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Polka Dots ─────────────────────────────────────────────────────
    //
    //  ●  ●  ●     (staggered rows for visual density)
    //    ●  ●  ●

    private static func drawPolkaDots(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        radius: CGFloat, spacing: CGFloat,
        fg: GraphicsContext.Shading
    ) {
        let cols = Int(ceil(s.width  / spacing)) + 3
        let rows = Int(ceil(s.height / spacing)) + 3
        var path = Path()
        for row in 0..<rows {
            let xOff = row % 2 == 0 ? 0.0 : spacing / 2
            for col in 0..<cols {
                let cx = o.x + CGFloat(col) * spacing + xOff
                let cy = o.y + CGFloat(row) * spacing
                path.addEllipse(in: CGRect(
                    x: cx - radius, y: cy - radius,
                    width: radius * 2, height: radius * 2
                ))
            }
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Grid ───────────────────────────────────────────────────────────
    //
    //  ┼──┼──┼
    //  │  │  │
    //  ┼──┼──┼

    private static func drawGrid(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        spacing: CGFloat, lineW: CGFloat,
        fg: GraphicsContext.Shading
    ) {
        var path = Path()
        var y = o.y
        while y <= o.y + s.height {
            path.addRect(CGRect(x: o.x, y: y, width: s.width, height: lineW))
            y += spacing
        }
        var x = o.x
        while x <= o.x + s.width {
            path.addRect(CGRect(x: x, y: o.y, width: lineW, height: s.height))
            x += spacing
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Crosshatch ─────────────────────────────────────────────────────
    //
    //  ╲ ╱ ╲ ╱
    //  ╱ ╲ ╱ ╲

    private static func drawCrosshatch(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        spacing: CGFloat, lineW: CGFloat,
        fg: GraphicsContext.Shading
    ) {
        let extra = s.height
        var path  = Path()
        var x     = o.x - extra
        // ╲ forward diagonals
        while x < o.x + s.width + extra {
            path.move(to:    CGPoint(x: x,            y: o.y))
            path.addLine(to: CGPoint(x: x + lineW,    y: o.y))
            path.addLine(to: CGPoint(x: x + lineW + extra, y: o.y + s.height))
            path.addLine(to: CGPoint(x: x + extra,    y: o.y + s.height))
            path.closeSubpath()
            x += spacing
        }
        // ╱ backward diagonals
        x = o.x - extra
        while x < o.x + s.width + extra {
            path.move(to:    CGPoint(x: x + extra,          y: o.y))
            path.addLine(to: CGPoint(x: x + extra + lineW,  y: o.y))
            path.addLine(to: CGPoint(x: x + lineW,          y: o.y + s.height))
            path.addLine(to: CGPoint(x: x,                  y: o.y + s.height))
            path.closeSubpath()
            x += spacing
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Diamonds ───────────────────────────────────────────────────────
    //
    //    ◆   ◆
    //  ◆   ◆   ◆
    //    ◆   ◆

    private static func drawDiamonds(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        hw: CGFloat, hh: CGFloat,
        fg: GraphicsContext.Shading
    ) {
        let spacingX = hw * 2.6
        let spacingY = hh * 2.6
        let cols = Int(ceil(s.width  / spacingX)) + 3
        let rows = Int(ceil(s.height / spacingY)) + 3
        var path = Path()
        for row in 0..<rows {
            let xOff = row % 2 == 0 ? 0.0 : spacingX / 2
            for col in 0..<cols {
                let cx = o.x + CGFloat(col) * spacingX + xOff
                let cy = o.y + CGFloat(row) * spacingY
                path.move(to:    CGPoint(x: cx,      y: cy - hh))
                path.addLine(to: CGPoint(x: cx + hw, y: cy))
                path.addLine(to: CGPoint(x: cx,      y: cy + hh))
                path.addLine(to: CGPoint(x: cx - hw, y: cy))
                path.closeSubpath()
            }
        }
        ctx.fill(path, with: fg)
    }

    // MARK: ── Herringbone ────────────────────────────────────────────────────
    //
    //  ╲╲╲│╱╱╱│╲╲╲│╱╱╱    ← even band goes ↘, odd band goes ↙
    //  ╲╲╲│╱╱╱│╲╲╲│╱╱╱

    private static func drawHerringbone(
        ctx: inout GraphicsContext,
        o: CGPoint, s: CGSize,
        bandH: CGFloat, stripeW: CGFloat,
        fg: GraphicsContext.Shading
    ) {
        let period   = stripeW * 2
        let numBands = Int(ceil(s.height / bandH)) + 3
        var path     = Path()

        for band in 0..<numBands {
            let bandY    = o.y + CGFloat(band - 1) * bandH
            let goRight  = band % 2 == 0
            var x        = o.x - bandH - period
            while x < o.x + s.width + bandH {
                if goRight {
                    // Parallelogram going ↘
                    path.move(to:    CGPoint(x: x,           y: bandY))
                    path.addLine(to: CGPoint(x: x + stripeW, y: bandY))
                    path.addLine(to: CGPoint(x: x + stripeW + bandH, y: bandY + bandH))
                    path.addLine(to: CGPoint(x: x + bandH,   y: bandY + bandH))
                } else {
                    // Parallelogram going ↙
                    path.move(to:    CGPoint(x: x + bandH,            y: bandY))
                    path.addLine(to: CGPoint(x: x + bandH + stripeW,  y: bandY))
                    path.addLine(to: CGPoint(x: x + stripeW,          y: bandY + bandH))
                    path.addLine(to: CGPoint(x: x,                    y: bandY + bandH))
                }
                path.closeSubpath()
                x += period
            }
        }
        ctx.fill(path, with: fg)
    }
}
