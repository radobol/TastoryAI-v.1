//
//  IngredientDatabase.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 8/3/25.
//

import Foundation

// MARK: - Data Models

struct IngredientData: Codable {
    let id: Int
    let name: String
    let aliases: [String]
    let category: String
    let subcategory: String
    let scalable: Bool
}

struct IngredientDatabase: Codable {
    let ingredients: [IngredientData]
}

// MARK: - Database Manager

class IngredientDatabaseManager {
    static let shared = IngredientDatabaseManager()
    
    private var ingredients: [IngredientData] = []
    private var nameIndex: [String: IngredientData] = [:]
    
    private init() {
        loadDatabase()
    }
    
    // MARK: - Database Loading
    
    private func loadDatabase() {
        guard let url = Bundle.main.url(forResource: "cooking_ingredients", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let database = try? JSONDecoder().decode(IngredientDatabase.self, from: data) else {
            print("⚠️ Failed to load ingredient database")
            return
        }
        
        ingredients = database.ingredients
        buildIndex()
        print("✅ Loaded \(ingredients.count) ingredients from database")
    }
    
    private func buildIndex() {
        nameIndex.removeAll()
        
        for ingredient in ingredients {
            // Index main name
            let mainName = ingredient.name.lowercased()
            nameIndex[mainName] = ingredient
            
            // Index all aliases
            for alias in ingredient.aliases {
                let aliasKey = alias.lowercased()
                nameIndex[aliasKey] = ingredient
            }
        }
    }
    
    // MARK: - Ingredient Lookup
    
    func findIngredient(for text: String) -> IngredientData? {
        let searchText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct match first
        if let ingredient = nameIndex[searchText] {
            return ingredient
        }
        
        // Fuzzy matching for partial matches
        return fuzzyMatch(for: searchText)
    }
    
    private func fuzzyMatch(for searchText: String) -> IngredientData? {
        var bestMatch: IngredientData?
        var bestScore: Double = 0.6 // Minimum similarity threshold
        
        for ingredient in ingredients {
            // Check main name
            let mainNameScore = similarity(between: searchText, and: ingredient.name.lowercased())
            if mainNameScore > bestScore {
                bestScore = mainNameScore
                bestMatch = ingredient
            }
            
            // Check aliases
            for alias in ingredient.aliases {
                let aliasScore = similarity(between: searchText, and: alias.lowercased())
                if aliasScore > bestScore {
                    bestScore = aliasScore
                    bestMatch = ingredient
                }
            }
            
            // Check if search text contains ingredient name or vice versa
            if searchText.contains(ingredient.name.lowercased()) || 
               ingredient.name.lowercased().contains(searchText) {
                if ingredient.name.count >= 3 && searchText.count >= 3 { // Avoid matching very short words
                    return ingredient
                }
            }
            
            // Check aliases for contains match
            for alias in ingredient.aliases {
                if searchText.contains(alias.lowercased()) || 
                   alias.lowercased().contains(searchText) {
                    if alias.count >= 3 && searchText.count >= 3 {
                        return ingredient
                    }
                }
            }
        }
        
        return bestMatch
    }
    
    // MARK: - String Similarity
    
    private func similarity(between string1: String, and string2: String) -> Double {
        let longer = string1.count > string2.count ? string1 : string2
        let shorter = string1.count > string2.count ? string2 : string1
        
        if longer.count == 0 {
            return 1.0
        }
        
        let editDistance = levenshteinDistance(string1, string2)
        return (Double(longer.count) - Double(editDistance)) / Double(longer.count)
    }
    
    private func levenshteinDistance(_ string1: String, _ string2: String) -> Int {
        let array1 = Array(string1)
        let array2 = Array(string2)
        let length1 = array1.count
        let length2 = array2.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: length2 + 1), count: length1 + 1)
        
        for i in 0...length1 {
            matrix[i][0] = i
        }
        
        for j in 0...length2 {
            matrix[0][j] = j
        }
        
        for i in 1...length1 {
            for j in 1...length2 {
                let cost = array1[i - 1] == array2[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,      // deletion
                    matrix[i][j - 1] + 1,      // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }
        
        return matrix[length1][length2]
    }
    
    // MARK: - Utility Methods
    
    func isIngredientScalable(_ text: String) -> Bool {
        return findIngredient(for: text)?.scalable ?? true // Default to scalable if not found
    }
    
    func getIngredientInfo(_ text: String) -> (name: String, category: String, scalable: Bool)? {
        guard let ingredient = findIngredient(for: text) else { return nil }
        return (ingredient.name, ingredient.category, ingredient.scalable)
    }
    
    // MARK: - Debug Methods
    
    func getAllIngredients() -> [IngredientData] {
        return ingredients
    }
    
    func searchIngredients(containing query: String) -> [IngredientData] {
        let searchQuery = query.lowercased()
        return ingredients.filter { ingredient in
            ingredient.name.lowercased().contains(searchQuery) ||
            ingredient.aliases.contains { $0.lowercased().contains(searchQuery) }
        }
    }
}