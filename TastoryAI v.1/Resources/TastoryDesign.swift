import SwiftUI

// MARK: - Tastory Design System
// This file defines the design tokens for the entire Tastory AI app.
// All UI components should reference these values for consistency.

// MARK: - Colors
struct TastoryColors {
    // Primary
    static let primaryGreen = Color(hex: "1B6D3F")
    static let lightGreenBg = Color(hex: "E8F5EF")

    // Backgrounds
    static let background = Color(hex: "F5F5F5")
    static let cardBackground = Color.white

    // Text
    static let primaryText = Color(hex: "1A1A1A")
    static let secondaryText = Color(hex: "6B7280")
    static let tertiaryText = Color(hex: "9CA3AF")

    // Borders & Dividers
    static let border = Color(hex: "E5E7EB")

    // Buttons
    static let secondaryButtonBg = Color(hex: "E8E8E8")

    // Status
    static let errorRed = Color(hex: "DC2626")
    static let warningOrange = Color(hex: "F59E0B")
    static let successGreen = Color(hex: "10B981")
}

// MARK: - UIKit Colors (for Share Extension)
struct TastoryUIColors {
    static let primaryGreen = UIColor(red: 27/255, green: 109/255, blue: 63/255, alpha: 1)
    static let lightGreenBg = UIColor(red: 232/255, green: 245/255, blue: 239/255, alpha: 1)
    static let background = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    static let cardBackground = UIColor.white
    static let primaryText = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
    static let secondaryText = UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1)
    static let tertiaryText = UIColor(red: 156/255, green: 163/255, blue: 175/255, alpha: 1)
    static let border = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1)
    static let secondaryButtonBg = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
    static let errorRed = UIColor(red: 220/255, green: 38/255, blue: 38/255, alpha: 1)
    static let warningOrange = UIColor(red: 245/255, green: 158/255, blue: 11/255, alpha: 1)
    static let successGreen = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1)
}

// MARK: - Typography
struct TastoryTypography {
    // Large Title - 32pt Bold
    static let largeTitle = Font.system(size: 32, weight: .bold)

    // Title - 22pt Semibold
    static let title = Font.system(size: 22, weight: .semibold)

    // Headline - 17pt Semibold
    static let headline = Font.system(size: 17, weight: .semibold)

    // Body - 16pt Medium
    static let body = Font.system(size: 16, weight: .medium)
    static let bodyRegular = Font.system(size: 16, weight: .regular)

    // Callout - 14pt Medium
    static let callout = Font.system(size: 14, weight: .medium)

    // Caption - 12pt Medium
    static let caption = Font.system(size: 12, weight: .medium)
}

// MARK: - UIKit Typography (for Share Extension)
struct TastoryUITypography {
    static let largeTitle = UIFont.systemFont(ofSize: 32, weight: .bold)
    static let title = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let body = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let bodyRegular = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let callout = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let caption = UIFont.systemFont(ofSize: 12, weight: .medium)
}

// MARK: - Spacing
struct TastorySpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius
struct TastoryRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Shadows
struct TastoryShadow {
    static let small = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    static let large = Shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Button Heights
struct TastoryButtonHeight {
    static let primary: CGFloat = 56
    static let secondary: CGFloat = 48
    static let small: CGFloat = 40
}

// MARK: - Icon Sizes
struct TastoryIconSize {
    static let small: CGFloat = 16
    static let medium: CGFloat = 20
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 40
    static let xxLarge: CGFloat = 60
}

// MARK: - View Extensions for Shadows
// Note: Color(hex:) extension is defined in Theme.swift
extension View {
    func tastoryShadow(_ shadow: TastoryShadow.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
