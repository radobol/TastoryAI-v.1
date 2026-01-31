import SwiftUI

// MARK: - TastorySectionHeader Component
struct TastorySectionHeader: View {
    let title: String
    var count: Int? = nil
    var actionTitle: String? = nil
    var actionIcon: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            // Title with optional count
            HStack(spacing: TastorySpacing.xs) {
                Text(title)
                    .font(TastoryTypography.headline)
                    .foregroundColor(TastoryColors.primaryText)

                if let count = count {
                    Text("(\(count))")
                        .font(TastoryTypography.callout)
                        .foregroundColor(TastoryColors.secondaryText)
                }
            }

            Spacer()

            // Action button
            if let action = action {
                Button(action: action) {
                    HStack(spacing: TastorySpacing.xxs) {
                        if let actionIcon = actionIcon {
                            Image(systemName: actionIcon)
                                .font(.system(size: TastoryIconSize.small))
                        }
                        if let actionTitle = actionTitle {
                            Text(actionTitle)
                                .font(TastoryTypography.callout)
                        }
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
                }
            }
        }
        .padding(.bottom, TastorySpacing.xs)
    }
}

// MARK: - Preview
#Preview("Section Headers") {
    VStack(spacing: 24) {
        VStack(alignment: .leading) {
            TastorySectionHeader(title: "Ingredients")
            Text("Content goes here...")
                .foregroundColor(TastoryColors.secondaryText)
        }

        VStack(alignment: .leading) {
            TastorySectionHeader(title: "Ingredients", count: 8)
            Text("Content with count...")
                .foregroundColor(TastoryColors.secondaryText)
        }

        VStack(alignment: .leading) {
            TastorySectionHeader(
                title: "Instructions",
                actionTitle: "+ Add",
                action: {}
            )
            Text("Content with action button...")
                .foregroundColor(TastoryColors.secondaryText)
        }

        VStack(alignment: .leading) {
            TastorySectionHeader(
                title: "Tips & Notes",
                count: 3,
                actionIcon: "plus.circle.fill",
                action: {}
            )
            Text("Content with icon action...")
                .foregroundColor(TastoryColors.secondaryText)
        }
    }
    .padding()
    .background(TastoryColors.background)
}
