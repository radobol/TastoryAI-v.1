//
//  RecipeViewModel.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation
import SwiftUI

class RecipeViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var currentServings: Int
    @Published var checkedIngredients: Set<String> = []
    
    private let storageManager = RecipeStorageManager.shared
    private let originalServings: Int
    
    init(recipeId: UUID) {
        if let loadedRecipe = storageManager.getRecipe(withId: recipeId) {
            self.recipe = loadedRecipe
            self.currentServings = loadedRecipe.servings
            self.originalServings = loadedRecipe.servings
        } else {
            // Fallback to empty recipe
            self.recipe = Recipe(title: "Recipe not found")
            self.currentServings = 1
            self.originalServings = 1
        }
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.currentServings = recipe.servings
        self.originalServings = recipe.servings
    }
    
    // MARK: - Serving Size Management
    
    var servingMultiplier: Double {
        return Double(currentServings) / Double(originalServings)
    }
    
    func increaseServings() {
        if currentServings < 20 {
            currentServings += 1
        }
    }
    
    func decreaseServings() {
        if currentServings > 1 {
            currentServings -= 1
        }
    }
    
    // MARK: - Ingredient Management
    
    var scaledIngredients: [String] {
        return recipe.ingredients.map { ingredient in
            IngredientParser.scaleIngredient(ingredient, by: servingMultiplier)
        }
    }
    
    func toggleIngredientCheck(_ ingredient: String) {
        if checkedIngredients.contains(ingredient) {
            checkedIngredients.remove(ingredient)
        } else {
            checkedIngredients.insert(ingredient)
        }
    }
    
    func isIngredientChecked(_ ingredient: String) -> Bool {
        return checkedIngredients.contains(ingredient)
    }
    
    // MARK: - Recipe Actions
    
    func updateRecipe(_ updatedRecipe: Recipe) {
        recipe = updatedRecipe
        storageManager.updateRecipe(updatedRecipe)
    }
    
    func deleteRecipe() {
        storageManager.deleteRecipe(withId: recipe.id)
    }
    
    func duplicateRecipe() -> Recipe? {
        return storageManager.duplicateRecipe(withId: recipe.id)
    }
    
    func shareRecipeText() -> String {
        var shareText = "\(recipe.title)\n\n"
        
        if let category = recipe.category {
            shareText += "Category: \(category)\n"
        }
        
        shareText += "Servings: \(currentServings)\n\n"
        
        shareText += "Ingredients:\n"
        for ingredient in scaledIngredients {
            shareText += "• \(ingredient)\n"
        }
        
        shareText += "\nInstructions:\n"
        for (index, step) in recipe.steps.enumerated() {
            shareText += "\(index + 1). \(step)\n"
        }
        
        shareText += "\nShared from Tastory AI"
        
        return shareText
    }
}