//
//  HomeView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var storageManager = RecipeStorageManager.shared
    @StateObject private var categoryManager = CategoryManager.shared
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    @State private var debouncedSearchText = ""

    // Selection mode state
    @State private var isSelectionMode = false
    @State private var selectedRecipeIds: Set<UUID> = []

    // Bulk operation sheets
    @State private var showingBulkDeleteAlert = false
    @State private var showingAddCategorySheet = false
    @State private var showingSetPrimarySheet = false

    // Filtered recipes based on search
    private var filteredRecipes: [Recipe] {
        guard !debouncedSearchText.isEmpty else {
            return storageManager.recipes
        }

        // Split search text into tokens and normalize
        let searchTokens = debouncedSearchText
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .split(separator: " ")
            .map { String($0) }

        guard !searchTokens.isEmpty else {
            return storageManager.recipes
        }

        return storageManager.recipes.filter { recipe in
            // Get category names for this recipe
            let categoryNames = recipe.categoryIds.compactMap { categoryId in
                categoryManager.getCategory(withId: categoryId)?.name
            }.joined(separator: " ")

            // Combine all searchable fields
            let searchableContent = [
                recipe.title,
                recipe.ingredients.joined(separator: " "),
                recipe.steps.joined(separator: " "),
                categoryNames
            ]
            .joined(separator: " ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

            // AND logic: all tokens must match
            return searchTokens.allSatisfy { token in
                searchableContent.contains(token)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("My Recipes")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(TastoryColors.primaryText)

                    Spacer()

                    if !storageManager.recipes.isEmpty {
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
                .padding(.horizontal, TastorySpacing.md)
                .padding(.top, TastorySpacing.sm)
                .padding(.bottom, TastorySpacing.md)

                // Custom search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(TastoryColors.secondaryText)

                    TextField("Search recipes, ingredients, or categories", text: $searchText)
                        .font(TastoryTypography.body)
                }
                .padding(TastorySpacing.sm)
                .background(Color(.systemGray6))
                .cornerRadius(TastoryRadius.medium)
                .padding(.horizontal, TastorySpacing.md)
                .padding(.bottom, TastorySpacing.sm)

                // Main content
                ZStack {
                    TastoryColors.background
                        .ignoresSafeArea()

                    if storageManager.recipes.isEmpty {
                        TastoryEmptyState(
                            icon: "book.closed",
                            title: "No recipes yet",
                            message: "Add your first recipe by tapping the + button below."
                        )
                    } else if filteredRecipes.isEmpty && !debouncedSearchText.isEmpty {
                        TastoryEmptyState(
                            icon: "magnifyingglass",
                            title: "No results found",
                            message: "Try searching for different keywords or check your spelling."
                        )
                    } else {
                        RecipeGridView(
                            recipes: filteredRecipes,
                            isSelectionMode: isSelectionMode,
                            selectedRecipeIds: $selectedRecipeIds
                        )
                    }

                    VStack {
                        Spacer()

                        // Bulk actions toolbar (shown in selection mode)
                        if isSelectionMode && !selectedRecipeIds.isEmpty {
                            bulkActionsToolbar
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.bottom, TastorySpacing.sm)
                        }

                        HStack {
                            Spacer()
                            if !isSelectionMode {
                                AddRecipeButton(showingAddRecipe: $showingAddRecipe)
                                    .padding(.trailing, TastorySpacing.md)
                                    .padding(.bottom, TastorySpacing.md)
                            }
                        }
                    }
                }
            }
            .background(TastoryColors.background)
            .navigationBarHidden(true)
            .onChange(of: searchText) { _, newValue in
                // Debounce search with 250ms delay
                Task {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    if searchText == newValue {
                        debouncedSearchText = newValue
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .sheet(isPresented: $showingAddCategorySheet) {
                AddCategoryToBulkSheet(selectedRecipeIds: selectedRecipeIds) {
                    isSelectionMode = false
                    selectedRecipeIds.removeAll()
                }
            }
            .sheet(isPresented: $showingSetPrimarySheet) {
                SetPrimaryCategorySheet(selectedRecipeIds: selectedRecipeIds) {
                    isSelectionMode = false
                    selectedRecipeIds.removeAll()
                }
            }
            .alert("Delete Recipes", isPresented: $showingBulkDeleteAlert) {
                Button("Delete", role: .destructive) {
                    handleBulkDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \(selectedRecipeIds.count) recipe\(selectedRecipeIds.count == 1 ? "" : "s")? This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Refresh recipes when app becomes active (to show Share Extension additions)
            storageManager.loadRecipes()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh when app comes back from background (after Share Extension)
            storageManager.loadRecipes()
        }
    }

    // MARK: - Bulk Actions Toolbar

    private var bulkActionsToolbar: some View {
        TastoryCard(padding: TastorySpacing.md) {
            HStack(spacing: TastorySpacing.md) {
                // Delete button
                Button(action: {
                    showingBulkDeleteAlert = true
                }) {
                    VStack(spacing: TastorySpacing.xxs) {
                        Image(systemName: "trash")
                            .font(.system(size: TastoryIconSize.medium))
                        Text("Delete")
                            .font(TastoryTypography.caption)
                    }
                    .foregroundColor(TastoryColors.errorRed)
                }

                Spacer()

                // Add Category button
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

                // Set Primary button
                Button(action: {
                    showingSetPrimarySheet = true
                }) {
                    VStack(spacing: TastorySpacing.xxs) {
                        Image(systemName: "star")
                            .font(.system(size: TastoryIconSize.medium))
                        Text("Primary")
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

    private func handleBulkDelete() {
        selectedRecipeIds.forEach { recipeId in
            storageManager.deleteRecipe(withId: recipeId)
        }

        isSelectionMode = false
        selectedRecipeIds.removeAll()
    }
}

struct AddRecipeButton: View {
    @Binding var showingAddRecipe: Bool

    var body: some View {
        Button(action: { showingAddRecipe = true }) {
            ZStack {
                Circle()
                    .fill(TastoryColors.primaryGreen)
                    .frame(width: TastoryButtonHeight.primary, height: TastoryButtonHeight.primary)
                    .tastoryShadow(TastoryShadow.medium)

                Image(systemName: "plus")
                    .font(.system(size: TastoryIconSize.large, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    HomeView()
}