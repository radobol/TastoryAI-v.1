//
//  RecipeGridView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct RecipeGridView: View {
    let recipes: [Recipe]
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var columns: [GridItem] {
        let count = sizeClass == .compact ? 2 : 4
        return Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.medium), count: count)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                ForEach(recipes) { recipe in
                    RecipeCardView(recipe: recipe)
                }
            }
            .padding(Theme.Spacing.medium)
        }
        .background(Theme.Colors.background)
    }
}

#Preview {
    RecipeGridView(recipes: Recipe.sampleRecipes)
}