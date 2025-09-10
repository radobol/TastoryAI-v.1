//
//  Recipe.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//Great. Now let's return to the previous task and start implementation of categories. Let's first repeat our to-do plan implementation plan first and after that start implementation to do by to do face by face. If we have implemented during some phase enough features to testing in the app let's pause implementation let's prepare build let know me that some capabilities and what exactly are ready for testing I will finish app installation and everything and test it and let you know if it's worked correctly and if yes we will move on on the next task and face if something not working as expected we will try to fix the issue first and only after we will move forward. I agree with this approach and let's maybe incorporated to the plan.

import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var ingredients: [String]
    var steps: [String]
    var imageURL: String?
    
    // MARK: - Category System (New)
    var categoryIds: [UUID]
    var primaryCategoryId: UUID?
    
    // MARK: - Legacy category field (for migration)
    var category: String?
    
    var servings: Int
    var sourceURL: String?
    var tips: [String]
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        ingredients: [String] = [],
        steps: [String] = [],
        imageURL: String? = nil,
        categoryIds: [UUID] = [],
        primaryCategoryId: UUID? = nil,
        category: String? = nil, // Legacy field for migration
        servings: Int = 4,
        sourceURL: String? = nil,
        tips: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.imageURL = imageURL
        self.categoryIds = categoryIds
        self.primaryCategoryId = primaryCategoryId
        self.category = category
        self.servings = servings
        self.sourceURL = sourceURL
        self.tips = tips
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Category Helper Methods
    
    /// Check if recipe has a specific category
    func hasCategory(_ categoryId: UUID) -> Bool {
        return categoryIds.contains(categoryId)
    }
    
    /// Add a category to this recipe
    mutating func addCategory(_ categoryId: UUID, asPrimary: Bool = false) {
        if !categoryIds.contains(categoryId) {
            categoryIds.append(categoryId)
        }
        
        if asPrimary {
            primaryCategoryId = categoryId
        } else if primaryCategoryId == nil {
            // If no primary category set, make this the primary
            primaryCategoryId = categoryId
        }
    }
    
    /// Remove a category from this recipe
    mutating func removeCategory(_ categoryId: UUID) {
        categoryIds.removeAll { $0 == categoryId }
        
        // If removing the primary category, assign a new primary
        if primaryCategoryId == categoryId {
            primaryCategoryId = categoryIds.first
        }
    }
    
    /// Set the primary category (ensures it's also in categoryIds)
    mutating func setPrimaryCategory(_ categoryId: UUID) {
        primaryCategoryId = categoryId
        if !categoryIds.contains(categoryId) {
            categoryIds.append(categoryId)
        }
    }
    
    /// Get additional categories (all categories except primary)
    func getAdditionalCategoryIds() -> [UUID] {
        return categoryIds.filter { $0 != primaryCategoryId }
    }
    
}

extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(
            title: "Classic Spaghetti Carbonara",
            ingredients: [
                "400g spaghetti",
                "200g guanciale or pancetta",
                "4 large eggs",
                "100g Pecorino Romano cheese, grated",
                "2 cloves garlic",
                "1/2 cup white wine",
                "Black pepper to taste",
                "Salt as needed"
            ],
            steps: [
                "Cook spaghetti in salted water until al dente",
                "Dice and crisp the guanciale in a large pan",
                "Beat eggs with grated cheese and black pepper",
                "Toss hot pasta with guanciale and fat",
                "Remove from heat and add egg mixture, stirring quickly"
            ],
            servings: 4
        ),
        Recipe(
            title: "Chicken Stir Fry",
            ingredients: [
                "500g chicken breast, cubed",
                "2 cups mixed vegetables",
                "3 cloves garlic, minced",
                "1 medium onion, sliced",
                "2 tbsp soy sauce",
                "1 tbsp sesame oil",
                "1 tsp cornstarch",
                "1/4 cup chicken broth",
                "Salt to taste",
                "2 green onions, chopped"
            ],
            steps: [
                "Cut chicken into bite-sized pieces",
                "Heat oil in wok over high heat",
                "Stir fry chicken until golden",
                "Add vegetables and garlic",
                "Season with soy sauce and sesame oil"
            ],
            servings: 4
        )
    ]
}
