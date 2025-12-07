//
//  FilteredRecipesView.swift
//  TastoryAI
//
//  Displays recipes filtered by a specific category
//

import SwiftUI

struct FilteredRecipesView: View {
    let category: Category

    @StateObject private var storageManager = RecipeStorageManager.shared

    private var filteredRecipes: [Recipe] {
        storageManager.getRecipesForCategory(category.id)
    }

    var body: some View {
        Group {
            if filteredRecipes.isEmpty {
                emptyState
            } else {
                RecipeGridView(recipes: filteredRecipes)
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.secondaryText)

            Text("No recipes in this category yet")
                .font(Typography.Body.regular)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FilteredRecipesView(category: Category.sampleCategories[0])
    }
}
