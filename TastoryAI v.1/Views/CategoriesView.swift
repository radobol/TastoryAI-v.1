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

    // Edit/Delete state
    @State private var categoryToEdit: Category?
    @State private var showingEditCategorySheet = false
    @State private var editCategoryName = ""
    @State private var editCategoryError: String?
    @State private var categoryToDelete: Category?
    @State private var showingDeleteAlert = false
    @State private var deleteAffectedRecipeCount = 0

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
            .sheet(isPresented: $showingEditCategorySheet) {
                if let category = categoryToEdit {
                    EditCategorySheet(
                        category: category,
                        categoryName: $editCategoryName,
                        errorMessage: $editCategoryError,
                        onSave: { newName in
                            handleUpdateCategory(category: category, newName: newName)
                        },
                        onCancel: {
                            resetEditForm()
                        }
                    )
                }
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        handleDeleteCategory(category)
                    }
                }
                Button("Cancel", role: .cancel) {
                    resetDeleteState()
                }
            } message: {
                if let category = categoryToDelete {
                    if deleteAffectedRecipeCount > 0 {
                        Text("Are you sure you want to delete \"\(category.name)\"? \(deleteAffectedRecipeCount) recipe\(deleteAffectedRecipeCount == 1 ? "" : "s") will be moved to \"New recipes\". This action cannot be undone.")
                    } else {
                        Text("Are you sure you want to delete \"\(category.name)\"? This action cannot be undone.")
                    }
                }
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
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if !category.isSystem {
                        Button(role: .destructive) {
                            handleDeleteSwipe(for: category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            handleEditSwipe(for: category)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(Theme.Colors.accent)
                    }
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

    // MARK: - Edit/Delete Actions

    private func handleEditSwipe(for category: Category) {
        categoryToEdit = category
        editCategoryName = category.name
        editCategoryError = nil
        showingEditCategorySheet = true
    }

    private func handleDeleteSwipe(for category: Category) {
        categoryToDelete = category
        deleteAffectedRecipeCount = getRecipeCount(for: category.id)
        showingDeleteAlert = true
    }

    private func handleUpdateCategory(category: Category, newName: String) {
        let result = categoryManager.validateCategoryName(newName, excluding: category.id)

        switch result {
        case .success(let validName):
            var updatedCategory = category
            updatedCategory.name = validName
            updatedCategory.slug = Category.generateSlug(from: validName)
            categoryManager.updateCategory(updatedCategory)
            showingEditCategorySheet = false
            resetEditForm()

        case .failure(let error):
            editCategoryError = error.localizedDescription
        }
    }

    private func resetEditForm() {
        categoryToEdit = nil
        editCategoryName = ""
        editCategoryError = nil
    }

    private func handleDeleteCategory(_ category: Category) {
        let newRecipesCategory = categoryManager.getNewRecipesCategory()

        // Step 1: Reassign affected recipes to "New recipes"
        storageManager.reassignRecipesFromDeletedCategory(
            category.id,
            to: newRecipesCategory.id
        )

        // Step 2: Delete the category
        categoryManager.deleteCategory(withId: category.id)

        // Step 3: Clean up state
        resetDeleteState()
    }

    private func resetDeleteState() {
        categoryToDelete = nil
        deleteAffectedRecipeCount = 0
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
