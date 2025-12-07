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
    @StateObject private var categoryManager = CategoryManager.shared

    // Selection mode state
    @State private var isSelectionMode = false
    @State private var selectedRecipeIds: Set<UUID> = []

    // Bulk operation sheets
    @State private var showingRemoveFromCategorySheet = false
    @State private var showingAddCategorySheet = false
    @State private var showingMoveToCategorySheet = false

    private var filteredRecipes: [Recipe] {
        storageManager.getRecipesForCategory(category.id)
    }

    var body: some View {
        ZStack {
            Group {
                if filteredRecipes.isEmpty {
                    emptyState
                } else {
                    RecipeGridView(
                        recipes: filteredRecipes,
                        isSelectionMode: isSelectionMode,
                        selectedRecipeIds: $selectedRecipeIds
                    )
                }
            }

            VStack {
                Spacer()

                // Bulk actions toolbar (shown in selection mode)
                if isSelectionMode && !selectedRecipeIds.isEmpty {
                    bulkActionsToolbar
                        .padding(.horizontal, Theme.Spacing.medium)
                        .padding(.bottom, Theme.Spacing.small)
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !filteredRecipes.isEmpty {
                    Button(isSelectionMode ? "Cancel" : "Select") {
                        toggleSelectionMode()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingRemoveFromCategorySheet) {
            RemoveFromCategorySheet(
                category: category,
                selectedRecipeIds: selectedRecipeIds
            ) {
                isSelectionMode = false
                selectedRecipeIds.removeAll()
            }
        }
        .sheet(isPresented: $showingAddCategorySheet) {
            AddCategoryToBulkSheet(selectedRecipeIds: selectedRecipeIds) {
                isSelectionMode = false
                selectedRecipeIds.removeAll()
            }
        }
        .sheet(isPresented: $showingMoveToCategorySheet) {
            MoveToCategorySheet(
                fromCategory: category,
                selectedRecipeIds: selectedRecipeIds
            ) {
                isSelectionMode = false
                selectedRecipeIds.removeAll()
            }
        }
    }

    // MARK: - Bulk Actions Toolbar

    private var bulkActionsToolbar: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Remove from current category
            Button(action: {
                showingRemoveFromCategorySheet = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "folder.badge.minus")
                        .font(.system(size: 20))
                    Text("Remove")
                        .font(Typography.Caption1.regular)
                }
                .foregroundColor(.red)
            }

            Spacer()

            // Add to another category
            Button(action: {
                showingAddCategorySheet = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 20))
                    Text("Add")
                        .font(Typography.Caption1.regular)
                }
                .foregroundColor(Theme.Colors.accent)
            }

            Spacer()

            // Move to another category
            Button(action: {
                showingMoveToCategorySheet = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "folder.fill.badge.gearshape")
                        .font(.system(size: 20))
                    Text("Move")
                        .font(Typography.Caption1.regular)
                }
                .foregroundColor(Theme.Colors.accent)
            }
        }
        .padding(Theme.Spacing.medium)
        .background(Theme.Colors.background)
        .cornerRadius(12)
        .shadow(
            color: Theme.Shadow.medium.color,
            radius: Theme.Shadow.medium.radius,
            x: Theme.Shadow.medium.x,
            y: Theme.Shadow.medium.y
        )
    }

    // MARK: - Helper Methods

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedRecipeIds.removeAll()
        }
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
