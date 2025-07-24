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
            ("400g spaghetti", 2.0, "800g spaghetti"),
            ("200g guanciale or pancetta", 0.5, "100g guanciale or pancetta"),
            ("4 large eggs", 3.0, "12 large eggs"),
            ("100g Pecorino Romano cheese, grated", 1.5, "150g Pecorino Romano cheese, grated"),
            ("2 cloves garlic", 2.0, "2 cloves garlic"), // Should NOT scale
            ("1/2 cup white wine", 2.0, "1 cup white wine"),
            ("Black pepper to taste", 3.0, "Black pepper to taste"), // Should NOT scale
            ("Salt as needed", 2.0, "Salt as needed"), // Should NOT scale
            ("500g chicken breast, cubed", 2.0, "1000g chicken breast, cubed"),
            ("2 cups mixed vegetables", 0.5, "1 cup mixed vegetables"),
            ("1 medium onion, sliced", 2.0, "1 medium onion, sliced"), // Debatable
            ("2 tbsp soy sauce", 1.5, "3 tbsp soy sauce"),
            ("1 tbsp sesame oil", 3.0, "3 tbsp sesame oil"),
            ("1 tsp cornstarch", 2.0, "2 tsp cornstarch"),
            ("1/4 cup chicken broth", 4.0, "1 cup chicken broth"),
            ("2 green onions, chopped", 2.0, "2 green onions, chopped"), // Should NOT scale
            ("1 1/2 cups flour", 2.0, "3 cups flour"),
            ("2-3 carrots", 2.0, "5 carrots"), // Takes average of range
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