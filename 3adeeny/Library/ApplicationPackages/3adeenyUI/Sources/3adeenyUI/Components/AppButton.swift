import SwiftUI

// MARK: - Variant

public enum AppButtonVariant: Sendable {
    /// Filled black/white — the strongest call to action on a screen.
    case primary
    /// Outlined, transparent fill — secondary actions alongside a primary.
    case secondary
    /// No border, no fill — tertiary / least-prominent actions.
    case ghost
    /// Red fill — irreversible or dangerous actions.
    case destructive
}

// MARK: - Size

public enum AppButtonSize: Sendable {
    /// Full-width, 52 pt tall — main CTAs (login, submit, confirm).
    case large
    /// Full-width, 44 pt tall — form actions, modal footers.
    case medium
    /// Intrinsic width, 36 pt tall — inline or secondary placement.
    case small
}

// MARK: - AppButton

public struct AppButton: View {
    private let title: String
    private let variant: AppButtonVariant
    private let size: AppButtonSize
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        variant: AppButtonVariant = .primary,
        size: AppButtonSize = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                // Label — hidden while loading so the spinner takes its place
                label
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(size == .small ? 0.75 : 1)
                }
            }
            .frame(maxWidth: size == .small ? nil : .infinity)
            .frame(height: buttonHeight)
            .padding(.horizontal, size == .small ? AppSpacing.md : 0)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(borderOverlay)
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.38 : 1)
        .animation(.easeInOut(duration: 0.18), value: isLoading)
        .animation(.easeInOut(duration: 0.18), value: isDisabled)
    }

    // MARK: - Sub-views

    private var label: some View {
        Text(title)
            .font(labelFont)
            .lineLimit(1)
    }

    @ViewBuilder
    private var borderOverlay: some View {
        if variant == .secondary {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(AppColor.border, lineWidth: 1.5)
        }
    }

    // MARK: - Resolved tokens

    private var buttonHeight: CGFloat {
        switch size {
        case .large:  return 52
        case .medium: return 44
        case .small:  return 36
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .large:  return AppSpacing.Radius.md
        case .medium: return AppSpacing.Radius.md
        case .small:  return AppSpacing.Radius.sm
        }
    }

    private var labelFont: Font {
        switch size {
        case .large:  return AppFont.headline
        case .medium: return AppFont.headline
        case .small:  return AppFont.footnoteMedium
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:     return AppColor.primary
        case .secondary:   return .clear
        case .ghost:       return .clear
        case .destructive: return AppColor.destructive
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:     return AppColor.primaryForeground
        case .secondary:   return AppColor.label
        case .ghost:       return AppColor.label
        case .destructive: return AppColor.destructiveForeground
        }
    }
}

// MARK: - Previews

#Preview("All variants — Light") {
    VStack(spacing: AppSpacing.md) {
        AppButton("Continue",           variant: .primary)     {}
        AppButton("Maybe later",        variant: .secondary)   {}
        AppButton("Skip",               variant: .ghost)       {}
        AppButton("Delete account",     variant: .destructive) {}
        AppButton("Loading…",           variant: .primary,     isLoading: true)  {}
        AppButton("Disabled",           variant: .primary,     isDisabled: true) {}
        HStack(spacing: AppSpacing.sm) {
            AppButton("Save",   variant: .primary,   size: .small) {}
            AppButton("Cancel", variant: .secondary, size: .small) {}
            AppButton("Skip",   variant: .ghost,     size: .small) {}
        }
    }
    .padding(AppSpacing.screenHorizontal)
}

#Preview("All variants — Dark") {
    VStack(spacing: AppSpacing.md) {
        AppButton("Continue",           variant: .primary)     {}
        AppButton("Maybe later",        variant: .secondary)   {}
        AppButton("Skip",               variant: .ghost)       {}
        AppButton("Delete account",     variant: .destructive) {}
        AppButton("Loading…",           variant: .primary,     isLoading: true)  {}
        AppButton("Disabled",           variant: .primary,     isDisabled: true) {}
        HStack(spacing: AppSpacing.sm) {
            AppButton("Save",   variant: .primary,   size: .small) {}
            AppButton("Cancel", variant: .secondary, size: .small) {}
            AppButton("Skip",   variant: .ghost,     size: .small) {}
        }
    }
    .padding(AppSpacing.screenHorizontal)
    .background(AppColor.background)
    .preferredColorScheme(.dark)
}
