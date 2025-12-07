//
//  BulkCategorySheets.swift
//  TastoryAI
//
//  Bulk category operation sheets for multi-select mode
//

import SwiftUI

// MARK: - Add Category to Bulk

struct AddCategoryToBulkSheet: View {
    let selectedRecipeIds: Set<UUID>
    let onComplete: () -> Void

    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categoryErrorMessage: String?

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Secondary Category to Add")) {
                    ForEach(categoryManager.categories) { category in
                        Button(action: {
                            addCategoryToRecipes(category.id)
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(Theme.Colors.accent)

                                Text(category.name)
                                    .font(Typography.Body.regular)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "plus.circle")
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                    }
                }

                Section {
                    Button(action: {
                        showingNewCategorySheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Theme.Colors.accent)
                            Text("Create New Category")
                                .foregroundColor(Theme.Colors.accent)
                                .font(Typography.Body.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NewCategorySheet(
                    categoryName: $newCategoryName,
                    errorMessage: $categoryErrorMessage,
                    onSave: { name in
                        handleCreateAndAddCategory(name)
                    },
                    onCancel: {
                        newCategoryName = ""
                        categoryErrorMessage = nil
                    }
                )
            }
        }
    }

    private func addCategoryToRecipes(_ categoryId: UUID) {
        selectedRecipeIds.forEach { recipeId in
            if var recipe = storageManager.getRecipe(withId: recipeId) {
                if !recipe.categoryIds.contains(categoryId) {
                    recipe.addCategory(categoryId)
                    storageManager.updateRecipe(recipe)
                }
            }
        }

        dismiss()
        onComplete()
    }

    private func handleCreateAndAddCategory(_ name: String) {
        let result = categoryManager.createCategory(name: name)

        switch result {
        case .success(let category):
            showingNewCategorySheet = false
            newCategoryName = ""
            categoryErrorMessage = nil
            addCategoryToRecipes(category.id)

        case .failure(let error):
            categoryErrorMessage = error.localizedDescription
        }
    }
}

// MARK: - Remove Category from Bulk

struct RemoveCategoryFromBulkSheet: View {
    let selectedRecipeIds: Set<UUID>
    let onComplete: () -> Void

    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @Environment(\.dismiss) private var dismiss

    // Get common categories across all selected recipes
    private var commonCategories: [Category] {
        guard !selectedRecipeIds.isEmpty else { return [] }

        let selectedRecipes = selectedRecipeIds.compactMap { storageManager.getRecipe(withId: $0) }

        guard let firstRecipe = selectedRecipes.first else { return [] }

        var common = Set(firstRecipe.categoryIds)

        for recipe in selectedRecipes.dropFirst() {
            common = common.intersection(recipe.categoryIds)
        }

        return common.compactMap { categoryManager.getCategory(withId: $0) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationView {
            List {
                if commonCategories.isEmpty {
                    Section {
                        Text("No common categories found")
                            .font(Typography.Body.regular)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                } else {
                    Section(header: Text("Common Categories")) {
                        ForEach(commonCategories) { category in
                            Button(action: {
                                removeCategoryFromRecipes(category.id)
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(Theme.Colors.accent)

                                    Text(category.name)
                                        .font(Typography.Body.regular)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Remove Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func removeCategoryFromRecipes(_ categoryId: UUID) {
        selectedRecipeIds.forEach { recipeId in
            if var recipe = storageManager.getRecipe(withId: recipeId) {
                recipe.removeCategory(categoryId)
                // Ensure recipe has at least "New recipes" category
                if recipe.categoryIds.isEmpty {
                    let newRecipesCategory = categoryManager.getNewRecipesCategory()
                    recipe.addCategory(newRecipesCategory.id, asPrimary: true)
                }
                storageManager.updateRecipe(recipe)
            }
        }

        dismiss()
        onComplete()
    }
}

// MARK: - Set Primary Category for Bulk

struct SetPrimaryCategorySheet: View {
    let selectedRecipeIds: Set<UUID>
    let onComplete: () -> Void

    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingConfirmAlert = false
    @State private var selectedCategoryId: UUID?
    @State private var selectedCategoryName: String = ""
    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categoryErrorMessage: String?

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Primary Category")) {
                    ForEach(categoryManager.categories) { category in
                        Button(action: {
                            selectedCategoryId = category.id
                            selectedCategoryName = category.name
                            showingConfirmAlert = true
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Theme.Colors.accent)

                                Text(category.name)
                                    .font(Typography.Body.regular)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                        }
                    }
                }

                Section {
                    Button(action: {
                        showingNewCategorySheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Theme.Colors.accent)
                            Text("Create New Category")
                                .foregroundColor(Theme.Colors.accent)
                                .font(Typography.Body.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Set Primary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Set Primary Category", isPresented: $showingConfirmAlert) {
                Button("Set Primary", role: .none) {
                    if let categoryId = selectedCategoryId {
                        setPrimaryCategory(categoryId)
                    }
                }
                Button("Cancel", role: .cancel) {
                    selectedCategoryId = nil
                    selectedCategoryName = ""
                }
            } message: {
                Text("Set \"\(selectedCategoryName)\" as primary category for \(selectedRecipeIds.count) recipe\(selectedRecipeIds.count == 1 ? "" : "s")? This category will be added to recipes that don't have it yet.")
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NewCategorySheet(
                    categoryName: $newCategoryName,
                    errorMessage: $categoryErrorMessage,
                    onSave: { name in
                        handleCreateAndSetPrimary(name)
                    },
                    onCancel: {
                        newCategoryName = ""
                        categoryErrorMessage = nil
                    }
                )
            }
        }
    }

    private func setPrimaryCategory(_ categoryId: UUID) {
        selectedRecipeIds.forEach { recipeId in
            if var recipe = storageManager.getRecipe(withId: recipeId) {
                // Add category if not present
                if !recipe.categoryIds.contains(categoryId) {
                    recipe.addCategory(categoryId)
                }
                // Set as primary
                recipe.setPrimaryCategory(categoryId)
                storageManager.updateRecipe(recipe)
            }
        }

        dismiss()
        onComplete()
    }

    private func handleCreateAndSetPrimary(_ name: String) {
        let result = categoryManager.createCategory(name: name)

        switch result {
        case .success(let category):
            showingNewCategorySheet = false
            newCategoryName = ""
            categoryErrorMessage = nil
            selectedCategoryId = category.id
            selectedCategoryName = category.name
            showingConfirmAlert = true

        case .failure(let error):
            categoryErrorMessage = error.localizedDescription
        }
    }
}

#Preview("Add Category") {
    AddCategoryToBulkSheet(
        selectedRecipeIds: [UUID()],
        onComplete: {}
    )
}

#Preview("Remove Category") {
    RemoveCategoryFromBulkSheet(
        selectedRecipeIds: [UUID()],
        onComplete: {}
    )
}

// MARK: - Remove from Category Sheet (for FilteredRecipesView)

struct RemoveFromCategorySheet: View {
    let category: Category
    let selectedRecipeIds: Set<UUID>
    let onComplete: () -> Void

    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingConfirmAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.large) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding(.top, Theme.Spacing.xLarge)

                VStack(spacing: Theme.Spacing.small) {
                    Text("Remove from \"\(category.name)\"?")
                        .font(Typography.Title2.semibold)
                        .foregroundColor(Theme.Colors.text)
                        .multilineTextAlignment(.center)

                    Text("Remove \(selectedRecipeIds.count) recipe\(selectedRecipeIds.count == 1 ? "" : "s") from this category? Recipes will remain in other categories.")
                        .font(Typography.Body.regular)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                }

                Spacer()

                VStack(spacing: Theme.Spacing.medium) {
                    Button(action: {
                        removeFromCategory()
                    }) {
                        Text("Remove from Category")
                            .font(Typography.Body.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(Typography.Body.regular)
                            .foregroundColor(Theme.Colors.accent)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.bottom, Theme.Spacing.medium)
            }
            .navigationTitle("Remove from Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func removeFromCategory() {
        selectedRecipeIds.forEach { recipeId in
            if var recipe = storageManager.getRecipe(withId: recipeId) {
                recipe.removeCategory(category.id)
                // Ensure recipe has at least "New recipes" category
                if recipe.categoryIds.isEmpty {
                    let newRecipesCategory = categoryManager.getNewRecipesCategory()
                    recipe.addCategory(newRecipesCategory.id, asPrimary: true)
                }
                storageManager.updateRecipe(recipe)
            }
        }

        dismiss()
        onComplete()
    }
}

// MARK: - Move to Category Sheet (for FilteredRecipesView)

struct MoveToCategorySheet: View {
    let fromCategory: Category
    let selectedRecipeIds: Set<UUID>
    let onComplete: () -> Void

    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categoryErrorMessage: String?

    // Get all categories except the current one
    private var availableCategories: [Category] {
        categoryManager.categories.filter { $0.id != fromCategory.id }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select Destination Category")) {
                    ForEach(availableCategories) { category in
                        Button(action: {
                            moveToCategory(category.id)
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(Theme.Colors.accent)

                                Text(category.name)
                                    .font(Typography.Body.regular)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .foregroundColor(Theme.Colors.accent)
                            }
                        }
                    }
                }

                Section {
                    Button(action: {
                        showingNewCategorySheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Theme.Colors.accent)
                            Text("Create New Category")
                                .foregroundColor(Theme.Colors.accent)
                                .font(Typography.Body.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Move to Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NewCategorySheet(
                    categoryName: $newCategoryName,
                    errorMessage: $categoryErrorMessage,
                    onSave: { name in
                        handleCreateAndMoveToCategory(name)
                    },
                    onCancel: {
                        newCategoryName = ""
                        categoryErrorMessage = nil
                    }
                )
            }
        }
    }

    private func moveToCategory(_ toCategoryId: UUID) {
        selectedRecipeIds.forEach { recipeId in
            if var recipe = storageManager.getRecipe(withId: recipeId) {
                // Remove from current category
                recipe.removeCategory(fromCategory.id)

                // Add to new category (as primary if it's the only one)
                if !recipe.categoryIds.contains(toCategoryId) {
                    let asPrimary = recipe.categoryIds.isEmpty
                    recipe.addCategory(toCategoryId, asPrimary: asPrimary)
                }

                storageManager.updateRecipe(recipe)
            }
        }

        dismiss()
        onComplete()
    }

    private func handleCreateAndMoveToCategory(_ name: String) {
        let result = categoryManager.createCategory(name: name)

        switch result {
        case .success(let category):
            showingNewCategorySheet = false
            newCategoryName = ""
            categoryErrorMessage = nil
            moveToCategory(category.id)

        case .failure(let error):
            categoryErrorMessage = error.localizedDescription
        }
    }
}

#Preview("Set Primary") {
    SetPrimaryCategorySheet(
        selectedRecipeIds: [UUID()],
        onComplete: {}
    )
}
