import SwiftUI

// MARK: - TastoryEmptyState Component
struct TastoryEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonIcon: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: TastorySpacing.md) {
            // Icon in circle
            ZStack {
                Circle()
                    .fill(TastoryColors.lightGreenBg)
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: TastoryIconSize.xxLarge))
                    .foregroundColor(TastoryColors.primaryGreen)
            }

            // Title
            Text(title)
                .font(TastoryTypography.title)
                .foregroundColor(TastoryColors.primaryText)
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .font(TastoryTypography.body)
                .foregroundColor(TastoryColors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TastorySpacing.xl)

            // Optional Action Button
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                TastoryButton(
                    title: buttonTitle,
                    style: .primary,
                    icon: buttonIcon,
                    isFullWidth: false,
                    action: buttonAction
                )
                .padding(.top, TastorySpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(TastorySpacing.xl)
    }
}

// MARK: - Preview
#Preview("Empty States") {
    VStack {
        TastoryEmptyState(
            icon: "book.closed",
            title: "No recipes yet",
            message: "Add your first recipe by tapping the + button below."
        )
    }
    .background(TastoryColors.background)
}

#Preview("Empty State with Button") {
    VStack {
        TastoryEmptyState(
            icon: "folder",
            title: "No categories",
            message: "Create categories to organize your recipes.",
            buttonTitle: "Create Category",
            buttonIcon: "plus",
            buttonAction: {}
        )
    }
    .background(TastoryColors.background)
}

#Preview("Search Empty State") {
    VStack {
        TastoryEmptyState(
            icon: "magnifyingglass",
            title: "No results found",
            message: "Try searching for different keywords or check your spelling."
        )
    }
    .background(TastoryColors.background)
}
