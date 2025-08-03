//
//  IngredientParserTests.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation

// Simple test structure for manual testing
struct IngredientParserTests {
    
    static func runTests() {
        print("🧪 Running Ingredient Parser Tests\n")
        
        let testCases: [(String, Double, String)] = [
            // (original, multiplier, expected)
            
            // Database ingredient tests - scalable
            ("2 cups all-purpose flour", 2.0, "4 cups all-purpose flour"),
            ("1 cup milk", 1.5, "1 1/2 cups milk"),
            ("4 large eggs", 3.0, "12 large eggs"),
            ("2 tbsp olive oil", 2.0, "4 tbsp olive oil"),
            ("1/2 cup butter", 3.0, "1 1/2 cups butter"),
            ("3 cups chicken broth", 0.5, "1 1/2 cups chicken broth"),
            ("1 lb ground beef", 2.0, "2 lbs ground beef"),
            ("500g spaghetti", 1.5, "750g spaghetti"),
            ("2 cups white rice", 2.0, "4 cups white rice"),
            ("1 cup cheddar cheese", 2.0, "2 cups cheddar cheese"),
            
            // Pattern-based non-scalable (only "to taste" patterns)
            ("Salt to taste", 3.0, "Salt to taste"),
            ("Black pepper to taste", 2.0, "Black pepper to taste"),
            
            // Specific quantities of salt/pepper SHOULD scale
            ("1 tsp salt", 2.0, "2 tsp salt"), // Salt with quantity should scale
            ("1/2 tsp black pepper", 2.0, "1 tsp black pepper"), // Pepper with quantity should scale
            ("1/2 teaspoon sea salt", 2.0, "1 teaspoon sea salt"), // Specific case from user's recipe
            
            // Pattern-based non-scalable
            ("Garlic powder as needed", 2.0, "Garlic powder as needed"),
            ("Olive oil for drizzling", 1.5, "Olive oil for drizzling"),
            ("A pinch of red pepper flakes", 2.0, "A pinch of red pepper flakes"),
            ("A dash of hot sauce", 3.0, "A dash of hot sauce"),
            
            // Scalable ingredients with quantities
            ("2 medium onions", 2.0, "4 medium onions"),
            ("3 cloves garlic", 1.5, "4 1/2 cloves garlic"),
            ("1 lb chicken breast", 0.5, "1/2 lb chicken breast"),
            ("2 cups fresh spinach", 3.0, "6 cups fresh spinach"),
            ("1/4 cup lemon juice", 4.0, "1 cup lemon juice"),
            ("3 tbsp soy sauce", 2.0, "6 tbsp soy sauce"),
            ("1 1/2 cups brown sugar", 2.0, "3 cups brown sugar"),
            
            // Mixed number and fraction tests
            ("1 1/2 cups flour", 2.0, "3 cups flour"),
            ("1 1/4 tsp vanilla", 2.0, "2 1/2 tsp vanilla"), // Fixed expectation
            ("1/2 cup coconut oil", 3.0, "1 1/2 cups coconut oil"),
            ("3/4 cup honey", 2.0, "1 1/2 cups honey"),
            ("1 1/2 cups brown sugar", 0.5, "3/4 cups brown sugar"), // Fixed expectation
            
            // Range handling (should take average)
            ("2-3 carrots", 2.0, "5 carrots"),
            ("1-2 tbsp vanilla extract", 3.0, "4 1/2 tbsp vanilla extract"),
            
            // Edge cases
            ("400g pasta", 1.5, "600g pasta"), // Fixed expectation  
            ("0.25 cups vegetable oil", 4.0, "1 cups vegetable oil"),
            ("0.5 cups water", 4.0, "2 cups water"),
            ("12 oz salmon fillet", 1.5, "18 oz salmon fillet"),
        ]
        
        var passedTests = 0
        let totalTests = testCases.count
        
        for (ingredient, multiplier, expected) in testCases {
            let result = IngredientParser.scaleIngredient(ingredient, by: multiplier)
            let passed = result == expected
            
            let status = passed ? "✅" : "❌"
            print("\(status) \(ingredient) × \(multiplier)")
            print("   Expected: \(expected)")
            print("   Got:      \(result)")
            
            if !passed {
                print("   ⚠️  Test failed!")
            }
            print("")
            
            if passed {
                passedTests += 1
            }
        }
        
        print("📊 Test Results: \(passedTests)/\(totalTests) passed")
        
        if passedTests == totalTests {
            print("🎉 All tests passed!")
        } else {
            print("🔧 Some tests failed - parser needs refinement")
        }
    }
}