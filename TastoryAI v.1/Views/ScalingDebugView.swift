//
//  ScalingDebugView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 8/3/25.
//

import SwiftUI

struct ScalingDebugView: View {
    @State private var testIngredient = "2 cups flour"
    @State private var multiplier = "1.5"
    @State private var testResults = ""
    @State private var showingFullTests = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipe Scaling System")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Test the enhanced ingredient scaling and database")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Quick Tests Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Tests")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            
                            Button("Test Database") {
                                testDatabase()
                            }
                            .buttonStyle(DebugButtonStyle())
                            
                            Button("Test Basic Scaling") {
                                testBasicScaling()
                            }
                            .buttonStyle(DebugButtonStyle())
                            
                            Button("Test Non-Scalable") {
                                testNonScalable()
                            }
                            .buttonStyle(DebugButtonStyle())
                            
                            Button("Run All Tests") {
                                runAllTests()
                            }
                            .buttonStyle(DebugButtonStyle(isPrimary: true))
                        }
                    }
                    
                    // Custom Test Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Custom Test")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ingredient:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter ingredient (e.g., '2 cups flour')", text: $testIngredient)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Multiplier:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter multiplier (e.g., '1.5')", text: $multiplier)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            Button("Test This Ingredient") {
                                testCustomIngredient()
                            }
                            .buttonStyle(DebugButtonStyle())
                        }
                    }
                    
                    // Results Section
                    if !testResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Test Results")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(testResults)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Test Functions
    
    private func testDatabase() {
        testResults = "🔍 Database Test Results:\n\n"
        ScalingSystemTester.quickDatabaseTest()
        
        let database = IngredientDatabaseManager.shared
        let testIngredients = ["tomatoes", "flour", "salt", "eggs"]
        
        for ingredient in testIngredients {
            if let result = database.findIngredient(for: ingredient) {
                testResults += "✅ '\(ingredient)' → '\(result.name)' (scalable: \(result.scalable))\n"
            } else {
                testResults += "❌ '\(ingredient)' → Not found\n"
            }
        }
    }
    
    private func testBasicScaling() {
        testResults = "⚖️ Basic Scaling Test Results:\n\n"
        
        let tests = [
            ("2 cups flour", 1.5),
            ("1 tsp salt", 2.0),
            ("3 tbsp olive oil", 0.5)
        ]
        
        for (ingredient, mult) in tests {
            let result = IngredientParser.scaleIngredient(ingredient, by: mult)
            testResults += "'\(ingredient)' × \(mult) = '\(result)'\n"
        }
    }
    
    private func testNonScalable() {
        testResults = "🚫 Non-Scalable Test Results:\n\n"
        
        let tests = [
            ("Salt to taste", 2.0),
            ("Black pepper to taste", 3.0),
            ("1 tsp salt", 2.0)
        ]
        
        for (ingredient, mult) in tests {
            let result = IngredientParser.scaleIngredient(ingredient, by: mult)
            let unchanged = result == ingredient
            let status = unchanged ? "✅" : "❌"
            testResults += "\(status) '\(ingredient)' × \(mult) = '\(result)'\n"
        }
    }
    
    private func testCustomIngredient() {
        guard let mult = Double(multiplier) else {
            testResults = "❌ Invalid multiplier. Please enter a number."
            return
        }
        
        testResults = "🧪 Custom Test Results:\n\n"
        testResults += "Ingredient: '\(testIngredient)'\n"
        testResults += "Multiplier: \(mult)\n\n"
        
        // Check database
        let database = IngredientDatabaseManager.shared
        if let dbResult = database.findIngredient(for: testIngredient) {
            testResults += "📝 Database: Found '\(dbResult.name)' (scalable: \(dbResult.scalable))\n"
        } else {
            testResults += "📝 Database: Not found\n"
        }
        
        // Test scaling
        let result = IngredientParser.scaleIngredient(testIngredient, by: mult)
        testResults += "📏 Result: '\(result)'\n"
        
        // Should it scale?
        let shouldScale = IngredientParser.isIngredientScalable(testIngredient)
        testResults += "🔍 Should scale: \(shouldScale)"
    }
    
    private func runAllTests() {
        testResults = "🧪 Running all comprehensive tests...\n\n"
        
        // Capture print statements (this won't work in real iOS, but shows intent)
        testResults += "Check Xcode Console for detailed test results.\n\n"
        
        // Run the comprehensive tests
        ScalingSystemTester.runAllTests()
        
        testResults += "✅ All tests completed!\nSee Xcode Console for detailed output."
    }
}

// MARK: - Custom Button Style

struct DebugButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    init(isPrimary: Bool = false) {
        self.isPrimary = isPrimary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .medium))
            .foregroundColor(isPrimary ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPrimary ? Color.orange : Color(.systemGray5))
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct ScalingDebugView_Previews: PreviewProvider {
    static var previews: some View {
        ScalingDebugView()
    }
}