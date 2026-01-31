import SwiftUI

// MARK: - TastoryCard Component
struct TastoryCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = TastorySpacing.md
    var showShadow: Bool = true
    var backgroundColor: Color = TastoryColors.cardBackground

    init(
        padding: CGFloat = TastorySpacing.md,
        showShadow: Bool = true,
        backgroundColor: Color = TastoryColors.cardBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.showShadow = showShadow
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(TastoryRadius.large)
            .if(showShadow) { view in
                view.tastoryShadow(TastoryShadow.medium)
            }
    }
}

// MARK: - View Extension for Conditional Modifier
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview
#Preview("Card Variants") {
    ScrollView {
        VStack(spacing: 20) {
            TastoryCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Card")
                        .font(TastoryTypography.headline)
                    Text("This is a white card with shadow and default padding.")
                        .font(TastoryTypography.body)
                        .foregroundColor(TastoryColors.secondaryText)
                }
            }

            TastoryCard(padding: TastorySpacing.lg) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Large Padding Card")
                        .font(TastoryTypography.headline)
                    Text("This card has larger padding (20pt).")
                        .font(TastoryTypography.body)
                        .foregroundColor(TastoryColors.secondaryText)
                }
            }

            TastoryCard(showShadow: false) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No Shadow Card")
                        .font(TastoryTypography.headline)
                    Text("This card has no shadow.")
                        .font(TastoryTypography.body)
                        .foregroundColor(TastoryColors.secondaryText)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: TastoryRadius.large)
                    .stroke(TastoryColors.border, lineWidth: 1)
            )

            TastoryCard(backgroundColor: TastoryColors.lightGreenBg) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(TastoryColors.primaryGreen)
                    Text("Tip: This is a card with green background for tips!")
                        .font(TastoryTypography.body)
                        .foregroundColor(TastoryColors.primaryText)
                }
            }
        }
        .padding()
    }
    .background(TastoryColors.background)
}
