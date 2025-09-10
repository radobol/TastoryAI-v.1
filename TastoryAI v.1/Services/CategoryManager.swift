//
//  CategoryManager.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 8/30/25.
//

import Foundation

class CategoryManager: ObservableObject {
    static let shared = CategoryManager()
    
    @Published var categories: [Category] = []
    
    private let documentsDirectory: URL
    private let categoriesFileURL: URL
    
    private init() {
        // Use App Group container if available, fallback to documents directory
        if let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tastoryai.app") {
            documentsDirectory = groupContainer
            print("✅ CategoryManager using App Groups container")
        } else {
            documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            print("⚠️ CategoryManager falling back to documents directory")
        }
        
        categoriesFileURL = documentsDirectory.appendingPathComponent("categories.json")
        print("📁 Categories file: \(categoriesFileURL.path)")
        
        loadCategories()
        
        // Initialize with system categories if empty
        if categories.isEmpty {
            initializeSystemCategories()
        }
    }
    
    // MARK: - Category CRUD Operations
    
    func loadCategories() {
        do {
            print("📖 Loading categories from: \(categoriesFileURL.path)")
            let data = try Data(contentsOf: categoriesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            categories = try decoder.decode([Category].self, from: data)
            print("📖 Successfully loaded \(categories.count) categories")
        } catch {
            print("📖 Failed to load categories: \(error)")
            categories = []
        }
    }
    
    func saveCategories() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(categories)
            try data.write(to: categoriesFileURL)
            print("💾 Successfully saved \(categories.count) categories")
        } catch {
            print("💾 Failed to save categories: \(error)")
        }
    }
    
    func addCategory(_ category: Category) {
        // Check for duplicate names (case-insensitive)
        if !isDuplicateName(category.name, excluding: nil) {
            categories.append(category)
            sortCategories()
            saveCategories()
            print("➕ Added category: \(category.name)")
        } else {
            print("❌ Category name already exists: \(category.name)")
        }
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            var updatedCategory = category
            updatedCategory.updatedAt = Date()
            categories[index] = updatedCategory
            sortCategories()
            saveCategories()
            print("✏️ Updated category: \(category.name)")
        }
    }
    
    func deleteCategory(withId id: UUID) {
        guard let category = getCategory(withId: id) else { return }
        
        // Prevent deletion of system categories
        if category.isSystem {
            print("❌ Cannot delete system category: \(category.name)")
            return
        }
        
        categories.removeAll { $0.id == id }
        saveCategories()
        print("🗑️ Deleted category: \(category.name)")
        
        // Note: Recipe reassignment will be handled by RecipeStorageManager
    }
    
    func getCategory(withId id: UUID) -> Category? {
        return categories.first { $0.id == id }
    }
    
    func getCategoryName(for id: UUID) -> String? {
        return getCategory(withId: id)?.name
    }
    
    // MARK: - Category Queries
    
    func getCategoryByName(_ name: String) -> Category? {
        let searchName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return categories.first { $0.name.lowercased() == searchName }
    }
    
    func getCategoryBySlug(_ slug: String) -> Category? {
        return categories.first { $0.slug == slug }
    }
    
    func getNewRecipesCategory() -> Category {
        if let existingCategory = categories.first(where: { $0.isNewRecipesCategory }) {
            return existingCategory
        }
        
        // If "New recipes" doesn't exist, create it
        let newRecipesCategory = Category.newRecipesCategory
        addCategory(newRecipesCategory)
        return newRecipesCategory
    }
    
    func getNonSystemCategories() -> [Category] {
        return categories.filter { !$0.isSystem }
    }
    
    // MARK: - Validation
    
    func isDuplicateName(_ name: String, excluding categoryId: UUID? = nil) -> Bool {
        let searchName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        
        return categories.contains { category in
            category.id != categoryId && 
            category.name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current) == searchName
        }
    }
    
    func isValidCategoryName(_ name: String) -> Bool {
        return Category.isValidName(name) && !isDuplicateName(name, excluding: nil)
    }
    
    enum CategoryError: LocalizedError {
        case duplicateName
        case invalidLength
        case emptyName
        
        var errorDescription: String? {
            switch self {
            case .duplicateName:
                return "A category with this name already exists"
            case .invalidLength:
                return "Category name must be 1-32 characters"
            case .emptyName:
                return "Category name cannot be empty"
            }
        }
    }
    
    func validateCategoryName(_ name: String, excluding categoryId: UUID? = nil) -> Result<String, CategoryError> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return .failure(.emptyName)
        }
        
        if trimmed.count > 32 {
            return .failure(.invalidLength)
        }
        
        if isDuplicateName(trimmed, excluding: categoryId) {
            return .failure(.duplicateName)
        }
        
        return .success(trimmed)
    }
    
    func createCategory(name: String) -> Result<Category, CategoryError> {
        switch validateCategoryName(name) {
        case .success(let validName):
            let newCategory = Category(name: validName)
            addCategory(newCategory)
            return .success(newCategory)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Migration & Initialization
    
    private func initializeSystemCategories() {
        let newRecipesCategory = Category.newRecipesCategory
        categories = [newRecipesCategory]
        saveCategories()
        print("🔧 Initialized system categories")
    }
    
    /// Convert a legacy category string to Category UUID
    func migrateStringCategory(_ categoryString: String?) -> UUID? {
        guard let categoryString = categoryString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryString.isEmpty else {
            return getNewRecipesCategory().id
        }
        
        // Check if category already exists
        if let existingCategory = getCategoryByName(categoryString) {
            return existingCategory.id
        }
        
        // Create new category from string
        if Category.isValidName(categoryString) {
            let newCategory = Category(name: categoryString)
            addCategory(newCategory)
            return newCategory.id
        }
        
        // Fallback to "New recipes"
        return getNewRecipesCategory().id
    }
    
    // MARK: - Sorting
    
    private func sortCategories() {
        categories.sort { (cat1, cat2) in
            // System categories first
            if cat1.isSystem && !cat2.isSystem {
                return true
            }
            if cat2.isSystem && !cat1.isSystem {
                return false
            }
            
            // "New recipes" always first among system categories
            if cat1.isNewRecipesCategory {
                return true
            }
            if cat2.isNewRecipesCategory {
                return false
            }
            
            // Alphabetical for the rest
            return cat1.name.localizedCaseInsensitiveCompare(cat2.name) == .orderedAscending
        }
    }
}