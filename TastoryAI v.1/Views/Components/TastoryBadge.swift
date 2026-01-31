import SwiftUI

// MARK: - Badge Style Enum
enum TastoryBadgeStyle {
    case `default`    // Light gray background, dark text
    case primary      // Light green background, green text
    case count        // Green background, white text (for numbers)
    case tag          // With icon, for categories
}

// MARK: - TastoryBadge Component
struct TastoryBadge: View {
    let text: String
    var style: TastoryBadgeStyle = .default
    var icon: String? = nil

    var body: some View {
        HStack(spacing: TastorySpacing.xxs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(text)
                .font(TastoryTypography.caption)
        }
        .padding(.horizontal, style == .count ? TastorySpacing.xs : TastorySpacing.sm)
        .padding(.vertical, TastorySpacing.xxs)
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .cornerRadius(style == .count ? TastoryRadius.full : TastoryRadius.small)
    }

    private var foregroundColor: Color {
        switch style {
        case .default:
            return TastoryColors.primaryText
        case .primary, .tag:
            return TastoryColors.primaryGreen
        case .count:
            return .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default:
            return TastoryColors.border
        case .primary, .tag:
            return TastoryColors.lightGreenBg
        case .count:
            return TastoryColors.primaryGreen
        }
    }
}

// MARK: - TastoryNumberBadge (For step numbers)
struct TastoryNumberBadge: View {
    let number: Int
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: TastoryRadius.small)
                .fill(TastoryColors.primaryGreen)
                .frame(width: size, height: size)

            Text("\(number)")
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - TastoryBullet (For ingredients)
struct TastoryBullet: View {
    var size: CGFloat = 8
    var color: Color = TastoryColors.primaryGreen

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

// MARK: - TastoryRemovableBadge (For categories with remove button)
struct TastoryRemovableBadge: View {
    let text: String
    var icon: String? = nil
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: TastorySpacing.xxs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(text)
                .font(TastoryTypography.caption)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(TastoryColors.secondaryText)
            }
        }
        .padding(.leading, TastorySpacing.sm)
        .padding(.trailing, TastorySpacing.xs)
        .padding(.vertical, TastorySpacing.xxs)
        .foregroundColor(TastoryColors.primaryGreen)
        .background(TastoryColors.lightGreenBg)
        .cornerRadius(TastoryRadius.small)
    }
}

// MARK: - Preview
#Preview("Badge Styles") {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            TastoryBadge(text: "Default")
            TastoryBadge(text: "Primary", style: .primary)
            TastoryBadge(text: "12", style: .count)
        }

        HStack(spacing: 12) {
            TastoryBadge(text: "Breakfast", style: .tag, icon: "tag.fill")
            TastoryBadge(text: "Quick Meals", style: .tag, icon: "tag.fill")
        }

        HStack(spacing: 12) {
            TastoryRemovableBadge(text: "Dinner", icon: "tag.fill") {}
            TastoryRemovableBadge(text: "Vegetarian") {}
        }
    }
    .padding()
    .background(TastoryColors.background)
}

#Preview("Number Badges") {
    HStack(spacing: 16) {
        TastoryNumberBadge(number: 1)
        TastoryNumberBadge(number: 2)
        TastoryNumberBadge(number: 3)
        TastoryNumberBadge(number: 10, size: 32)
    }
    .padding()
}

#Preview("Bullets") {
    VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 12) {
            TastoryBullet()
            Text("2 cups flour")
        }
        HStack(spacing: 12) {
            TastoryBullet()
            Text("1 tsp salt")
        }
        HStack(spacing: 12) {
            TastoryBullet()
            Text("3 eggs")
        }
    }
    .padding()
}
