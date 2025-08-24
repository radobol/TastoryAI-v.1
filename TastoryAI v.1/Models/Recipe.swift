//
//  Recipe.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var ingredients: [String]
    var steps: [String]
    var imageURL: String?
    var category: String?
    var servings: Int
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        ingredients: [String] = [],
        steps: [String] = [],
        imageURL: String? = nil,
        category: String? = nil,
        servings: Int = 4,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.imageURL = imageURL
        self.category = category
        self.servings = servings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
            category: "Italian",
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
            category: "Asian",
            servings: 4
        )
    ]
}