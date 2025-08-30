//
//  Category.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 8/30/25.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var slug: String
    var isSystem: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        slug: String? = nil,
        isSystem: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.slug = slug ?? Category.generateSlug(from: name)
        self.isSystem = isSystem
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Utility Functions
    
    /// Generate URL-safe slug from category name
    static func generateSlug(from name: String) -> String {
        return name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
    }
    
    /// Validate category name meets requirements
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count >= 1 && trimmed.count <= 32
    }
    
    // MARK: - System Categories
    
    /// Fixed UUID for the "New recipes" system category - shared between main app and extensions
    static let newRecipesCategoryId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
    /// The default "New recipes" system category
    static let newRecipesCategory = Category(
        id: newRecipesCategoryId,
        name: "New recipes",
        isSystem: true
    )
    
    /// Check if this category is the system "New recipes" category
    var isNewRecipesCategory: Bool {
        return id == Category.newRecipesCategoryId
    }
}

extension Category {
    /// Sample categories for development/testing
    static let sampleCategories: [Category] = [
        Category.newRecipesCategory,
        Category(name: "Italian"),
        Category(name: "Asian"),
        Category(name: "Desserts"),
        Category(name: "Quick & Easy")
    ]
}