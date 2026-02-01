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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.md) {
                        // Categories list
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            Text("Select Category to Add")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.secondaryText)
                                .padding(.horizontal, TastorySpacing.md)

                            VStack(spacing: 0) {
                                ForEach(categoryManager.categories) { category in
                                    Button(action: {
                                        addCategoryToRecipes(category.id)
                                    }) {
                                        HStack(spacing: TastorySpacing.sm) {
                                            ZStack {
                                                Circle()
                                                    .fill(TastoryColors.lightGreenBg)
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: "folder.fill")
                                                    .font(.system(size: TastoryIconSize.medium))
                                                    .foregroundColor(TastoryColors.primaryGreen)
                                            }

                                            Text(category.name)
                                                .font(TastoryTypography.body)
                                                .foregroundColor(TastoryColors.primaryText)

                                            Spacer()

                                            Image(systemName: "plus.circle")
                                                .foregroundColor(TastoryColors.primaryGreen)
                                        }
                                        .padding(.horizontal, TastorySpacing.md)
                                        .padding(.vertical, TastorySpacing.sm)
                                    }

                                    if category.id != categoryManager.categories.last?.id {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            }
                            .background(TastoryColors.cardBackground)
                            .cornerRadius(TastoryRadius.large)
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        TastoryButton(
                            title: "Create New Category",
                            style: .text,
                            icon: "plus.circle.fill"
                        ) {
                            showingNewCategorySheet = true
                        }
                        .padding(.horizontal, TastorySpacing.md)
                    }
                    .padding(.top, TastorySpacing.md)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.md) {
                        if commonCategories.isEmpty {
                            TastoryEmptyState(
                                icon: "folder.badge.questionmark",
                                title: "No common categories",
                                message: "Selected recipes don't share any common categories."
                            )
                            .padding(.top, TastorySpacing.xl)
                        } else {
                            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                                Text("Common Categories")
                                    .font(TastoryTypography.headline)
                                    .foregroundColor(TastoryColors.secondaryText)
                                    .padding(.horizontal, TastorySpacing.md)

                                VStack(spacing: 0) {
                                    ForEach(commonCategories) { category in
                                        Button(action: {
                                            removeCategoryFromRecipes(category.id)
                                        }) {
                                            HStack(spacing: TastorySpacing.sm) {
                                                ZStack {
                                                    Circle()
                                                        .fill(TastoryColors.lightGreenBg)
                                                        .frame(width: 40, height: 40)
                                                    Image(systemName: "folder.fill")
                                                        .font(.system(size: TastoryIconSize.medium))
                                                        .foregroundColor(TastoryColors.primaryGreen)
                                                }

                                                Text(category.name)
                                                    .font(TastoryTypography.body)
                                                    .foregroundColor(TastoryColors.primaryText)

                                                Spacer()

                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(TastoryColors.errorRed)
                                            }
                                            .padding(.horizontal, TastorySpacing.md)
                                            .padding(.vertical, TastorySpacing.sm)
                                        }

                                        if category.id != commonCategories.last?.id {
                                            Divider().padding(.leading, 56)
                                        }
                                    }
                                }
                                .background(TastoryColors.cardBackground)
                                .cornerRadius(TastoryRadius.large)
                                .padding(.horizontal, TastorySpacing.md)
                            }
                        }
                    }
                    .padding(.top, TastorySpacing.md)
                }
            }
            .navigationTitle("Remove Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.md) {
                        // Categories list
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            Text("Select Primary Category")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.secondaryText)
                                .padding(.horizontal, TastorySpacing.md)

                            VStack(spacing: 0) {
                                ForEach(categoryManager.categories) { category in
                                    Button(action: {
                                        selectedCategoryId = category.id
                                        selectedCategoryName = category.name
                                        showingConfirmAlert = true
                                    }) {
                                        HStack(spacing: TastorySpacing.sm) {
                                            ZStack {
                                                Circle()
                                                    .fill(TastoryColors.lightGreenBg)
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: TastoryIconSize.medium))
                                                    .foregroundColor(TastoryColors.primaryGreen)
                                            }

                                            Text(category.name)
                                                .font(TastoryTypography.body)
                                                .foregroundColor(TastoryColors.primaryText)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(TastoryColors.secondaryText)
                                                .font(.system(size: 14, weight: .semibold))
                                        }
                                        .padding(.horizontal, TastorySpacing.md)
                                        .padding(.vertical, TastorySpacing.sm)
                                    }

                                    if category.id != categoryManager.categories.last?.id {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            }
                            .background(TastoryColors.cardBackground)
                            .cornerRadius(TastoryRadius.large)
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        TastoryButton(
                            title: "Create New Category",
                            style: .text,
                            icon: "plus.circle.fill"
                        ) {
                            showingNewCategorySheet = true
                        }
                        .padding(.horizontal, TastorySpacing.md)
                    }
                    .padding(.top, TastorySpacing.md)
                }
            }
            .navigationTitle("Set Primary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                VStack(spacing: TastorySpacing.lg) {
                    // Warning icon
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                    }
                    .padding(.top, TastorySpacing.xl)

                    // Message
                    VStack(spacing: TastorySpacing.sm) {
                        Text("Remove from \"\(category.name)\"?")
                            .font(TastoryTypography.title)
                            .foregroundColor(TastoryColors.primaryText)
                            .multilineTextAlignment(.center)

                        Text("Remove \(selectedRecipeIds.count) recipe\(selectedRecipeIds.count == 1 ? "" : "s") from this category? Recipes will remain in other categories.")
                            .font(TastoryTypography.body)
                            .foregroundColor(TastoryColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, TastorySpacing.lg)
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: TastorySpacing.sm) {
                        TastoryButton(
                            title: "Remove from Category",
                            style: .destructive
                        ) {
                            removeFromCategory()
                        }

                        TastoryButton(
                            title: "Cancel",
                            style: .secondary
                        ) {
                            dismiss()
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    .padding(.bottom, TastorySpacing.lg)
                }
            }
            .navigationBarHidden(true)
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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.md) {
                        // Categories list
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            Text("Select Destination Category")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.secondaryText)
                                .padding(.horizontal, TastorySpacing.md)

                            VStack(spacing: 0) {
                                ForEach(availableCategories) { category in
                                    Button(action: {
                                        moveToCategory(category.id)
                                    }) {
                                        HStack(spacing: TastorySpacing.sm) {
                                            ZStack {
                                                Circle()
                                                    .fill(TastoryColors.lightGreenBg)
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: "folder.fill")
                                                    .font(.system(size: TastoryIconSize.medium))
                                                    .foregroundColor(TastoryColors.primaryGreen)
                                            }

                                            Text(category.name)
                                                .font(TastoryTypography.body)
                                                .foregroundColor(TastoryColors.primaryText)

                                            Spacer()

                                            Image(systemName: "arrow.right")
                                                .foregroundColor(TastoryColors.primaryGreen)
                                        }
                                        .padding(.horizontal, TastorySpacing.md)
                                        .padding(.vertical, TastorySpacing.sm)
                                    }

                                    if category.id != availableCategories.last?.id {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            }
                            .background(TastoryColors.cardBackground)
                            .cornerRadius(TastoryRadius.large)
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        TastoryButton(
                            title: "Create New Category",
                            style: .text,
                            icon: "plus.circle.fill"
                        ) {
                            showingNewCategorySheet = true
                        }
                        .padding(.horizontal, TastorySpacing.md)
                    }
                    .padding(.top, TastorySpacing.md)
                }
            }
            .navigationTitle("Move to Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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
