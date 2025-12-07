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
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                if storageManager.recipes.isEmpty {
                    EmptyStateView()
                } else if filteredRecipes.isEmpty && !debouncedSearchText.isEmpty {
                    SearchEmptyStateView(searchText: debouncedSearchText)
                } else {
                    RecipeGridView(recipes: filteredRecipes)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AddRecipeButton(showingAddRecipe: $showingAddRecipe)
                            .padding(.trailing, Theme.Spacing.medium)
                            .padding(.bottom, Theme.Spacing.medium)
                    }
                }
            }
            .navigationTitle("My Recipes")
            .searchable(text: $searchText, prompt: "Search recipes, ingredients, or categories")
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
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(Theme.Colors.tertiaryText)
            
            VStack(spacing: Theme.Spacing.small) {
                Text("No recipes yet")
                    .font(Typography.Title2.semibold)
                    .foregroundColor(Theme.Colors.text)
                
                Text("Start by adding your first recipe")
                    .font(Typography.Body.regular)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.xLarge)
    }
}

struct AddRecipeButton: View {
    @Binding var showingAddRecipe: Bool

    var body: some View {
        Button(action: { showingAddRecipe = true }) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: Theme.Shadow.medium.color,
                        radius: Theme.Shadow.medium.radius,
                        x: Theme.Shadow.medium.x,
                        y: Theme.Shadow.medium.y
                    )

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct SearchEmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.secondaryText)

            VStack(spacing: Theme.Spacing.small) {
                Text("No results found")
                    .font(Typography.Title2.semibold)
                    .foregroundColor(Theme.Colors.text)

                Text("Try searching for different keywords")
                    .font(Typography.Body.regular)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.xLarge)
    }
}

#Preview {
    HomeView()
}