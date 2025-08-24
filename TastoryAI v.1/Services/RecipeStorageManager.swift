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
            saveRecipes()
        } else {
            print("📖 Main app loaded \(recipes.count) existing recipes")
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
        
        let duplicatedRecipe = Recipe(
            title: "\(originalRecipe.title) (Copy)",
            ingredients: originalRecipe.ingredients,
            steps: originalRecipe.steps,
            imageURL: originalRecipe.imageURL,
            category: originalRecipe.category,
            servings: originalRecipe.servings
        )
        
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
}