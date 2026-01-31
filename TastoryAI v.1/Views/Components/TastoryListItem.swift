import SwiftUI

// MARK: - TastoryListItem Component
struct TastoryListItem: View {
    let title: String
    var subtitle: String? = nil
    var leadingIcon: String? = nil
    var leadingIconColor: Color = TastoryColors.primaryGreen
    var leadingIconBgColor: Color? = TastoryColors.lightGreenBg
    var trailingText: String? = nil
    var trailingIcon: String? = nil
    var showChevron: Bool = true
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: TastorySpacing.sm) {
                // Leading Icon
                if let icon = leadingIcon {
                    ZStack {
                        if let bgColor = leadingIconBgColor {
                            Circle()
                                .fill(bgColor)
                                .frame(width: 40, height: 40)
                        }
                        Image(systemName: icon)
                            .font(.system(size: TastoryIconSize.medium))
                            .foregroundColor(leadingIconColor)
                    }
                    .frame(width: 40, height: 40)
                }

                // Title & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(TastoryTypography.body)
                        .foregroundColor(TastoryColors.primaryText)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(TastoryTypography.callout)
                            .foregroundColor(TastoryColors.secondaryText)
                    }
                }

                Spacer()

                // Trailing Content
                if let trailingText = trailingText {
                    Text(trailingText)
                        .font(TastoryTypography.callout)
                        .foregroundColor(TastoryColors.secondaryText)
                }

                if let trailingIcon = trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: TastoryIconSize.medium))
                        .foregroundColor(TastoryColors.primaryGreen)
                }

                if showChevron && action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TastoryColors.tertiaryText)
                }
            }
            .padding(.horizontal, TastorySpacing.md)
            .padding(.vertical, TastorySpacing.sm)
            .background(TastoryColors.cardBackground)
            .cornerRadius(TastoryRadius.large)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

// MARK: - TastoryListItem without card background (for inside lists)
struct TastoryListItemRow: View {
    let title: String
    var subtitle: String? = nil
    var leadingIcon: String? = nil
    var leadingIconColor: Color = TastoryColors.primaryGreen
    var leadingIconBgColor: Color? = TastoryColors.lightGreenBg
    var trailingText: String? = nil
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: TastorySpacing.sm) {
            // Leading Icon
            if let icon = leadingIcon {
                ZStack {
                    if let bgColor = leadingIconBgColor {
                        Circle()
                            .fill(bgColor)
                            .frame(width: 40, height: 40)
                    }
                    Image(systemName: icon)
                        .font(.system(size: TastoryIconSize.medium))
                        .foregroundColor(leadingIconColor)
                }
                .frame(width: 40, height: 40)
            }

            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TastoryTypography.body)
                    .foregroundColor(TastoryColors.primaryText)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(TastoryTypography.callout)
                        .foregroundColor(TastoryColors.secondaryText)
                }
            }

            Spacer()

            // Trailing Content
            if let trailingText = trailingText {
                Text(trailingText)
                    .font(TastoryTypography.callout)
                    .foregroundColor(TastoryColors.secondaryText)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(TastoryColors.tertiaryText)
            }
        }
        .padding(.vertical, TastorySpacing.xs)
    }
}

// MARK: - Preview
#Preview("List Items") {
    ScrollView {
        VStack(spacing: 12) {
            TastoryListItem(
                title: "Preferences",
                subtitle: "Currency, theme",
                leadingIcon: "slider.horizontal.3"
            ) {}

            TastoryListItem(
                title: "Privacy",
                subtitle: "Biometrics, data preferences",
                leadingIcon: "lock.fill"
            ) {}

            TastoryListItem(
                title: "Breakfast",
                leadingIcon: "folder.fill",
                trailingText: "12 recipes"
            ) {}

            TastoryListItem(
                title: "Add Category",
                leadingIcon: "plus.circle.fill",
                leadingIconColor: TastoryColors.primaryGreen,
                leadingIconBgColor: nil,
                showChevron: false,
                action: {}
            )

            TastoryListItem(
                title: "No Action Item",
                subtitle: "This item has no action",
                leadingIcon: "info.circle",
                showChevron: false
            )
        }
        .padding()
    }
    .background(TastoryColors.background)
}
