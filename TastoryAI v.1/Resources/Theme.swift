//
//  Theme.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct Theme {
    
    struct Colors {
        static let primary = Color(hex: "1C1C1E")
        static let secondary = Color(hex: "8E8E93")
        static let accent = Color(hex: "007AFF")
        
        static let background = Color(hex: "F2F2F7")
        static let secondaryBackground = Color.white
        static let tertiaryBackground = Color(hex: "EFEFF4")
        
        static let text = Color(hex: "1C1C1E")
        static let secondaryText = Color(hex: "8E8E93")
        static let tertiaryText = Color(hex: "C7C7CC")
        
        static let separator = Color(hex: "E5E5EA")
        static let border = Color(hex: "D1D1D6")
        
        static let success = Color(hex: "34C759")
        static let warning = Color(hex: "FF9500")
        static let error = Color(hex: "FF3B30")
    }
    
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
    }
    
    struct Shadow {
        static let small = (color: Color.black.opacity(0.05), radius: 4.0, x: 0.0, y: 2.0)
        static let medium = (color: Color.black.opacity(0.08), radius: 8.0, x: 0.0, y: 4.0)
        static let large = (color: Color.black.opacity(0.1), radius: 16.0, x: 0.0, y: 8.0)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}