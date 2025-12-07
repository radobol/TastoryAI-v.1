//
//  CategoriesView.swift
//  TastoryAI
//
//  Categories list view - displays all categories with recipe counts
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared

    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categoryErrorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if categoryManager.categories.isEmpty {
                    emptyState
                } else {
                    categoryList
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewCategorySheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.Colors.accent)
                    }
                }
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NewCategorySheet(
                    categoryName: $newCategoryName,
                    errorMessage: $categoryErrorMessage,
                    onSave: { name in
                        handleCreateCategory(name)
                    },
                    onCancel: {
                        resetCategoryForm()
                    }
                )
            }
        }
    }

    // MARK: - Category List

    private var categoryList: some View {
        List {
            ForEach(categoryManager.categories) { category in
                NavigationLink(destination: FilteredRecipesView(category: category)) {
                    CategoryRow(
                        category: category,
                        recipeCount: getRecipeCount(for: category.id)
                    )
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.secondaryText)

            Text("No categories yet")
                .font(Typography.Body.regular)
                .foregroundColor(Theme.Colors.secondaryText)

            Text("Tap + to create your first category")
                .font(Typography.Caption1.regular)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Methods

    private func getRecipeCount(for categoryId: UUID) -> Int {
        storageManager.recipes.filter { recipe in
            recipe.categoryIds.contains(categoryId)
        }.count
    }

    private func handleCreateCategory(_ name: String) {
        let result = categoryManager.createCategory(name: name)

        switch result {
        case .success:
            // Success - dismiss sheet
            showingNewCategorySheet = false
            resetCategoryForm()

        case .failure(let error):
            // Show error in sheet
            categoryErrorMessage = error.localizedDescription
        }
    }

    private func resetCategoryForm() {
        newCategoryName = ""
        categoryErrorMessage = nil
    }
}

// MARK: - Category Row Component

private struct CategoryRow: View {
    let category: Category
    let recipeCount: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.small) {
            Image(systemName: "folder.fill")
                .font(.system(size: 20))
                .foregroundColor(Theme.Colors.accent)

            Text(category.name)
                .font(Typography.Body.regular)
                .foregroundColor(Theme.Colors.text)

            Spacer()

            Text("\(recipeCount)")
                .font(Typography.Caption1.regular)
                .foregroundColor(Theme.Colors.secondaryText)
                .padding(.trailing, Theme.Spacing.small)
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}

// MARK: - Preview

#Preview {
    CategoriesView()
}
