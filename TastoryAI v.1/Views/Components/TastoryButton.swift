import SwiftUI

// MARK: - Button Style Enum
enum TastoryButtonStyle {
    case primary      // Green background, white text
    case secondary    // Gray background, dark text
    case text         // No background, green text
    case destructive  // No background, red text
}

// MARK: - TastoryButton Component
struct TastoryButton: View {
    let title: String
    let style: TastoryButtonStyle
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var isFullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            HStack(spacing: TastorySpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: TastoryIconSize.medium))
                    }
                    Text(title)
                        .font(TastoryTypography.headline)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: buttonHeight)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(TastoryRadius.xLarge)
        }
        .disabled(isLoading || isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Computed Properties

    private var buttonHeight: CGFloat {
        switch style {
        case .primary:
            return TastoryButtonHeight.primary
        case .secondary:
            return TastoryButtonHeight.secondary
        case .text, .destructive:
            return TastoryButtonHeight.small
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return TastoryColors.primaryText
        case .text:
            return TastoryColors.primaryGreen
        case .destructive:
            return TastoryColors.errorRed
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return TastoryColors.primaryGreen
        case .secondary:
            return TastoryColors.secondaryButtonBg
        case .text, .destructive:
            return .clear
        }
    }
}

// MARK: - Preview
#Preview("Primary Button") {
    VStack(spacing: 16) {
        TastoryButton(title: "Save Recipe", style: .primary) {}

        TastoryButton(title: "Save Recipe", style: .primary, icon: "checkmark") {}

        TastoryButton(title: "Loading...", style: .primary, isLoading: true) {}

        TastoryButton(title: "Disabled", style: .primary, isDisabled: true) {}
    }
    .padding()
}

#Preview("Secondary Button") {
    VStack(spacing: 16) {
        TastoryButton(title: "Cancel", style: .secondary) {}

        TastoryButton(title: "Select Photo", style: .secondary, icon: "photo") {}
    }
    .padding()
}

#Preview("Text & Destructive Buttons") {
    VStack(spacing: 16) {
        TastoryButton(title: "+ Add Category", style: .text) {}

        TastoryButton(title: "Delete", style: .destructive, icon: "trash") {}

        TastoryButton(title: "Edit", style: .text, icon: "pencil", isFullWidth: false) {}
    }
    .padding()
}
