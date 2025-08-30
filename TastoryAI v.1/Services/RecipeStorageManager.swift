//
//  RecipeStorageManager.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation

class RecipeStorageManager: ObservableObject {
    static let shared = RecipeStorageManager()
    
    @Published var recipes: [Recipe] = []
    
    private let documentsDirectory: URL
    private let recipesFileURL: URL
    
    private init() {
        // Use App Group container if available, fallback to documents directory
        if let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tastoryai.app") {
            documentsDirectory = groupContainer
            print("✅ Main app using App Groups container: \(groupContainer.path)")
        } else {
            documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            print("⚠️ Main app falling back to documents directory")
        }
        
        recipesFileURL = documentsDirectory.appendingPathComponent("recipes.json")
        print("📁 Main app recipes file: \(recipesFileURL.path)")
        
        loadRecipes()
        
        // If no recipes exist, initialize with sample data
        if recipes.isEmpty {
            print("📖 No recipes found in main app, loading sample data")
            recipes = Recipe.sampleRecipes
            assignNewRecipesCategoryToRecipesWithoutCategories()
            saveRecipes()
        } else {
            print("📖 Main app loaded \(recipes.count) existing recipes")
            assignNewRecipesCategoryToRecipesWithoutCategories()
        }
    }
    
    // MARK: - CRUD Operations
    
    func loadRecipes() {
        do {
            print("📖 Main app attempting to load recipes from: \(recipesFileURL.path)")
            let data = try Data(contentsOf: recipesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            recipes = try decoder.decode([Recipe].self, from: data)
            print("📖 Main app successfully loaded \(recipes.count) recipes")
        } catch {
            print("📖 Main app failed to load recipes: \(error)")
            recipes = []
        }
    }
    
    func saveRecipes() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(recipes)
            try data.write(to: recipesFileURL)
            print("💾 Main app successfully saved \(recipes.count) recipes to: \(recipesFileURL.path)")
        } catch {
            print("💾 Main app failed to save recipes: \(error)")
        }
    }
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        print("➕ Main app adding recipe: \(recipe.title)")
        saveRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            var updatedRecipe = recipe
            updatedRecipe.updatedAt = Date()
            recipes[index] = updatedRecipe
            saveRecipes()
        }
    }
    
    func deleteRecipe(withId id: UUID) {
        recipes.removeAll { $0.id == id }
        saveRecipes()
    }
    
    func getRecipe(withId id: UUID) -> Recipe? {
        return recipes.first { $0.id == id }
    }
    
    func duplicateRecipe(withId id: UUID) -> Recipe? {
        guard let originalRecipe = getRecipe(withId: id) else { return nil }
        
        var duplicatedRecipe = Recipe(
            title: "\(originalRecipe.title) (Copy)",
            ingredients: originalRecipe.ingredients,
            steps: originalRecipe.steps,
            imageURL: originalRecipe.imageURL,
            categoryIds: originalRecipe.categoryIds,
            primaryCategoryId: originalRecipe.primaryCategoryId,
            servings: originalRecipe.servings,
            sourceURL: originalRecipe.sourceURL,
            tips: originalRecipe.tips
        )
        
        // If the original recipe has no categories, assign to "New recipes"
        if duplicatedRecipe.categoryIds.isEmpty || duplicatedRecipe.primaryCategoryId == nil {
            let newRecipesId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
            duplicatedRecipe.addCategory(newRecipesId, asPrimary: true)
        }
        
        addRecipe(duplicatedRecipe)
        return duplicatedRecipe
    }
    
    // MARK: - Search and Filter
    
    func searchRecipes(query: String) -> [Recipe] {
        if query.isEmpty {
            return recipes
        }
        
        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(query) ||
            recipe.category?.localizedCaseInsensitiveContains(query) == true ||
            recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func filterRecipes(by category: String) -> [Recipe] {
        return recipes.filter { $0.category?.lowercased() == category.lowercased() }
    }
    
    // MARK: - Category-based filtering
    
    func filterRecipes(by categoryId: UUID) -> [Recipe] {
        return recipes.filter { $0.categoryIds.contains(categoryId) }
    }
    
    func getRecipesForCategory(_ categoryId: UUID) -> [Recipe] {
        return recipes.filter { $0.hasCategory(categoryId) }
    }
    
    
    // MARK: - Category Management Integration
    
    /// Reassign recipes when a category is deleted
    func reassignRecipesFromDeletedCategory(_ deletedCategoryId: UUID, to newCategoryId: UUID) {
        var hasChanges = false
        
        for i in 0..<recipes.count {
            var recipe = recipes[i]
            
            if recipe.hasCategory(deletedCategoryId) {
                recipe.removeCategory(deletedCategoryId)
                recipe.addCategory(newCategoryId)
                recipes[i] = recipe
                hasChanges = true
                print("🔄 Reassigned recipe '\(recipe.title)' from deleted category")
            }
        }
        
        if hasChanges {
            saveRecipes()
        }
    }
    
    /// Assign "New recipes" category to any recipes without categories
    private func assignNewRecipesCategoryToRecipesWithoutCategories() {
        let newRecipesId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        var hasChanges = false
        
        for i in 0..<recipes.count {
            var recipe = recipes[i]
            
            if recipe.categoryIds.isEmpty || recipe.primaryCategoryId == nil {
                recipe.addCategory(newRecipesId, asPrimary: true)
                recipes[i] = recipe
                hasChanges = true
                print("🆕 Assigned '\(recipe.title)' to New recipes category")
            }
        }
        
        if hasChanges {
            saveRecipes()
        }
    }
}