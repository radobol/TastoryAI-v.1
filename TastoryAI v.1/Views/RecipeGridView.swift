//
//  RecipeGridView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct RecipeGridView: View {
    let recipes: [Recipe]
    var isSelectionMode: Bool = false
    @Binding var selectedRecipeIds: Set<UUID>

    @Environment(\.horizontalSizeClass) var sizeClass

    var columns: [GridItem] {
        let count = sizeClass == .compact ? 2 : 4
        return Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.medium), count: count)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                ForEach(recipes) { recipe in
                    RecipeCardView(
                        recipe: recipe,
                        isSelectionMode: isSelectionMode,
                        isSelected: selectedRecipeIds.contains(recipe.id)
                    )
                    .onTapGesture {
                        if isSelectionMode {
                            toggleSelection(for: recipe.id)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.medium)
        }
        .background(Theme.Colors.background)
    }

    private func toggleSelection(for recipeId: UUID) {
        if selectedRecipeIds.contains(recipeId) {
            selectedRecipeIds.remove(recipeId)
        } else {
            selectedRecipeIds.insert(recipeId)
        }
    }
}

// Default values for preview and non-selection contexts
extension RecipeGridView {
    init(recipes: [Recipe]) {
        self.recipes = recipes
        self.isSelectionMode = false
        self._selectedRecipeIds = .constant([])
    }
}

#Preview {
    RecipeGridView(recipes: Recipe.sampleRecipes)
}