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
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        recipesFileURL = documentsDirectory.appendingPathComponent("recipes.json")
        
        loadRecipes()
        
        // If no recipes exist, initialize with sample data
        if recipes.isEmpty {
            recipes = Recipe.sampleRecipes
            saveRecipes()
        }
    }
    
    // MARK: - CRUD Operations
    
    func loadRecipes() {
        do {
            let data = try Data(contentsOf: recipesFileURL)
            recipes = try JSONDecoder().decode([Recipe].self, from: data)
        } catch {
            print("Failed to load recipes: \(error)")
            recipes = []
        }
    }
    
    func saveRecipes() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(recipes)
            try data.write(to: recipesFileURL)
        } catch {
            print("Failed to save recipes: \(error)")
        }
    }
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
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
            tags: originalRecipe.tags,
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
            recipe.tags.contains { $0.localizedCaseInsensitiveContains(query) } ||
            recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func filterRecipes(by category: String) -> [Recipe] {
        return recipes.filter { $0.category?.lowercased() == category.lowercased() }
    }
}