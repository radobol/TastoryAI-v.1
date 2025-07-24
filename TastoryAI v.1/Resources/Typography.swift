//
//  Typography.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct Typography {
    
    struct LargeTitle {
        static let regular = Font.system(size: 34, weight: .regular, design: .default)
        static let bold = Font.system(size: 34, weight: .bold, design: .default)
    }
    
    struct Title1 {
        static let regular = Font.system(size: 28, weight: .regular, design: .default)
        static let semibold = Font.system(size: 28, weight: .semibold, design: .default)
        static let bold = Font.system(size: 28, weight: .bold, design: .default)
    }
    
    struct Title2 {
        static let regular = Font.system(size: 22, weight: .regular, design: .default)
        static let semibold = Font.system(size: 22, weight: .semibold, design: .default)
        static let bold = Font.system(size: 22, weight: .bold, design: .default)
    }
    
    struct Title3 {
        static let regular = Font.system(size: 20, weight: .regular, design: .default)
        static let semibold = Font.system(size: 20, weight: .semibold, design: .default)
    }
    
    struct Headline {
        static let regular = Font.system(size: 17, weight: .semibold, design: .default)
    }
    
    struct Body {
        static let regular = Font.system(size: 17, weight: .regular, design: .default)
        static let semibold = Font.system(size: 17, weight: .semibold, design: .default)
        static let bold = Font.system(size: 17, weight: .bold, design: .default)
    }
    
    struct Callout {
        static let regular = Font.system(size: 16, weight: .regular, design: .default)
        static let semibold = Font.system(size: 16, weight: .semibold, design: .default)
    }
    
    struct Subheadline {
        static let regular = Font.system(size: 15, weight: .regular, design: .default)
        static let semibold = Font.system(size: 15, weight: .semibold, design: .default)
    }
    
    struct Footnote {
        static let regular = Font.system(size: 13, weight: .regular, design: .default)
        static let semibold = Font.system(size: 13, weight: .semibold, design: .default)
    }
    
    struct Caption1 {
        static let regular = Font.system(size: 12, weight: .regular, design: .default)
        static let medium = Font.system(size: 12, weight: .medium, design: .default)
    }
    
    struct Caption2 {
        static let regular = Font.system(size: 11, weight: .regular, design: .default)
        static let medium = Font.system(size: 11, weight: .medium, design: .default)
    }
}