//
//  ScalingSystemTester.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 8/3/25.
//

import Foundation

struct ScalingSystemTester {
    
    static func runAllTests() {
        print("🧪 ENHANCED RECIPE SCALING SYSTEM TESTS")
        print("=====================================\n")
        
        testDatabaseIntegration()
        testBasicScaling()
        testDatabaseDrivenScaling()
        testNonScalableIngredients()
        testComplexScenarios()
        
        print("\n✅ All tests completed!")
        print("Check the results above to see if everything is working correctly.")
    }
    
    // MARK: - Database Integration Tests
    
    private static func testDatabaseIntegration() {
        print("🔍 Testing Database Integration...")
        print("--------------------------------")
        
        let database = IngredientDatabaseManager.shared
        
        let testIngredients = [
            "tomatoes",
            "flour",
            "eggs",
            "salt",
            "black pepper",
            "olive oil",
            "chicken breast",
            "unknown ingredient"
        ]
        
        for ingredient in testIngredients {
            if let result = database.findIngredient(for: ingredient) {
                print("✅ '\(ingredient)' → Found: '\(result.name)' (Category: \(result.category), Scalable: \(result.scalable))")
            } else {
                print("❌ '\(ingredient)' → Not found in database")
            }
        }
        
        print()
    }
    
    // MARK: - Basic Scaling Tests
    
    private static func testBasicScaling() {
        print("⚖️ Testing Basic Scaling Logic...")
        print("-------------------------------")
        
        let basicTests: [(String, Double, String)] = [
            ("2 cups flour", 1.5, "3 cups flour"),
            ("1/2 cup milk", 2.0, "1 cup milk"),
            ("3 tbsp olive oil", 0.5, "1 1/2 tbsp olive oil"),
            ("1 1/4 tsp vanilla", 2.0, "2 1/2 tsp vanilla"),
            ("4 large eggs", 1.5, "6 large eggs")
        ]
        
        for (ingredient, multiplier, expected) in basicTests {
            let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
            let status = result == expected ? "✅" : "❌"
            print("\(status) '\(ingredient)' × \(multiplier) = '\(result)'")
            if result != expected {
                print("   Expected: '\(expected)'")
            }
        }
        
        print()
    }
    
    // MARK: - Database-Driven Scaling Tests
    
    private static func testDatabaseDrivenScaling() {
        print("🗃️ Testing Database-Driven Scaling...")
        print("-----------------------------------")
        
        let databaseTests: [(String, Double, String)] = [
            ("2 cups all-purpose flour", 2.0, "4 cups all-purpose flour"),
            ("1 lb ground beef", 1.5, "1 1/2 lbs ground beef"),
            ("3 medium onions", 2.0, "6 medium onions"),
            ("1 cup cheddar cheese", 0.5, "1/2 cup cheddar cheese"),
            ("2 tbsp soy sauce", 3.0, "6 tbsp soy sauce")
        ]
        
        for (ingredient, multiplier, expected) in databaseTests {
            let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
            let status = result == expected ? "✅" : "❌"
            print("\(status) '\(ingredient)' × \(multiplier) = '\(result)'")
            if result != expected {
                print("   Expected: '\(expected)'")
            }
        }
        
        print()
    }
    
    // MARK: - Non-Scalable Ingredient Tests
    
    private static func testNonScalableIngredients() {
        print("🚫 Testing Non-Scalable Ingredients...")
        print("------------------------------------")
        
        let nonScalableTests: [(String, Double, String)] = [
            ("Salt to taste", 2.0, "Salt to taste"),
            ("Black pepper to taste", 3.0, "Black pepper to taste"),
            ("Olive oil as needed", 2.0, "Olive oil as needed"),
            ("A pinch of red pepper flakes", 3.0, "A pinch of red pepper flakes"),
            ("Fresh herbs for garnish", 2.0, "Fresh herbs for garnish")
        ]
        
        let scalableSeasoningTests: [(String, Double, String)] = [
            ("1 tsp salt", 2.0, "2 tsp salt"), // Salt with quantity SHOULD scale
            ("1/2 tsp black pepper", 2.0, "1 tsp black pepper"), // Pepper with quantity SHOULD scale
            ("1/2 teaspoon sea salt", 2.0, "1 teaspoon sea salt") // Your specific case
        ]
        
        for (ingredient, multiplier, expected) in nonScalableTests {
            let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
            let status = result == expected ? "✅" : "❌"
            print("\(status) '\(ingredient)' × \(multiplier) = '\(result)'")
            if result != expected {
                print("   Expected: '\(expected)' (should not scale)")
            }
        }
        
        print()
        print("⚖️ Testing Scalable Seasonings with Quantities...")
        print("-----------------------------------------------")
        
        for (ingredient, multiplier, expected) in scalableSeasoningTests {
            let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
            let status = result == expected ? "✅" : "❌"
            print("\(status) '\(ingredient)' × \(multiplier) = '\(result)'")
            if result != expected {
                print("   Expected: '\(expected)' (should scale)")
            }
        }
        
        print()
    }
    
    // MARK: - Complex Scenarios
    
    private static func testComplexScenarios() {
        print("🧮 Testing Complex Scenarios...")
        print("-----------------------------")
        
        let complexTests: [(String, Double, String)] = [
            ("2-3 carrots", 2.0, "5 carrots"), // Range handling
            ("1 1/2 cups brown sugar", 0.5, "3/4 cups brown sugar"), // Mixed numbers
            ("0.25 cups vegetable oil", 4.0, "1 cups vegetable oil"), // Decimals
            ("400g pasta", 1.5, "600g pasta"), // Grams
            ("12 oz salmon fillet", 2.0, "24 oz salmon fillet") // Ounces
        ]
        
        for (ingredient, multiplier, expected) in complexTests {
            let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
            let status = result == expected ? "✅" : "❌"
            print("\(status) '\(ingredient)' × \(multiplier) = '\(result)'")
            if result != expected {
                print("   Expected: '\(expected)'")
            }
        }
        
        print()
    }
    
    // MARK: - Quick Test Functions
    
    static func quickDatabaseTest() {
        print("🔍 Quick Database Test:")
        let database = IngredientDatabaseManager.shared
        let result = database.findIngredient(for: "tomatoes")
        print("Looking for 'tomatoes': \(result?.name ?? "Not found")")
    }
    
    static func quickScalingTest() {
        print("⚖️ Quick Scaling Test:")
        let result1 = IngredientParser.scaleIngredient("2 cups flour", by: 1.5)
        let result2 = IngredientParser.scaleIngredient("salt to taste", by: 2.0)
        print("2 cups flour × 1.5 = \(result1)")
        print("salt to taste × 2.0 = \(result2)")
    }
    
    static func testSpecificIngredient(_ ingredient: String, multiplier: Double) {
        print("🧪 Testing: '\(ingredient)' × \(multiplier)")
        
        // Check database first
        let database = IngredientDatabaseManager.shared
        if let dbResult = database.findIngredient(for: ingredient) {
            print("📝 Database info: \(dbResult.name) (scalable: \(dbResult.scalable))")
        } else {
            print("📝 Not found in database")
        }
        
        // Test scaling
        let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
        print("📏 Scaling result: '\(result)'")
        
        // Check if it should be scalable
        let shouldScale = IngredientParser.isIngredientScalable(ingredient)
        print("🔍 Should scale: \(shouldScale)")
    }
    
    static func debugDecimalIssue() {
        print("🔍 Debugging 0.25 × 4.0 issue...")
        let testValue = 0.25 * 4.0
        print("Math result: \(testValue)")
        print("Should be 1.0: \(testValue == 1.0)")
        
        // Test the specific case
        testSpecificIngredient("0.25 cups vegetable oil", multiplier: 4.0)
    }
}