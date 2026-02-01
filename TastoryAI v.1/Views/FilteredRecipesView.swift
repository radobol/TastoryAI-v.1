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
            TastoryColors.background
                .ignoresSafeArea()

            Group {
                if filteredRecipes.isEmpty {
                    TastoryEmptyState(
                        icon: "tray",
                        title: "No recipes yet",
                        message: "No recipes in this category yet. Add recipes from the main screen."
                    )
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
                        .padding(.horizontal, TastorySpacing.md)
                        .padding(.bottom, TastorySpacing.sm)
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
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(TastoryColors.primaryGreen)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.gray)
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
        TastoryCard(padding: TastorySpacing.md) {
            HStack(spacing: TastorySpacing.md) {
                // Remove from current category
                Button(action: {
                    showingRemoveFromCategorySheet = true
                }) {
                    VStack(spacing: TastorySpacing.xxs) {
                        Image(systemName: "folder.badge.minus")
                            .font(.system(size: TastoryIconSize.medium))
                        Text("Remove")
                            .font(TastoryTypography.caption)
                    }
                    .foregroundColor(TastoryColors.errorRed)
                }

                Spacer()

                // Add to another category
                Button(action: {
                    showingAddCategorySheet = true
                }) {
                    VStack(spacing: TastorySpacing.xxs) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: TastoryIconSize.medium))
                        Text("Add")
                            .font(TastoryTypography.caption)
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
                }

                Spacer()

                // Move to another category
                Button(action: {
                    showingMoveToCategorySheet = true
                }) {
                    VStack(spacing: TastorySpacing.xxs) {
                        Image(systemName: "folder.fill.badge.gearshape")
                            .font(.system(size: TastoryIconSize.medium))
                        Text("Move")
                            .font(TastoryTypography.caption)
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            selectedRecipeIds.removeAll()
        }
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        FilteredRecipesView(category: Category.sampleCategories[0])
    }
}
