//
//  HomeView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var storageManager = RecipeStorageManager.shared
    @State private var showingAddRecipe = false
    @State private var showingAPITest = false
    @State private var apiTestResult = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                if storageManager.recipes.isEmpty {
                    EmptyStateView()
                } else {
                    RecipeGridView(recipes: storageManager.recipes)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        // Add API Test Button
                        Button("🧪 Test API") {
                            testAPI()
                        }
                        .padding()
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(8)
                        .padding(.leading, Theme.Spacing.medium)
                        
                        // Add Scaling Test Button
                        Button("⚖️ Test Scaling") {
                            print("🧪 Starting scaling tests...")
                            ScalingSystemTester.runAllTests()
                        }
                        .padding()
                        .background(Theme.Colors.accent.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.leading, Theme.Spacing.small)
                        
                        Spacer()
                        AddRecipeButton(showingAddRecipe: $showingAddRecipe)
                            .padding(.trailing, Theme.Spacing.medium)
                            .padding(.bottom, Theme.Spacing.medium)
                    }
                }
            }
            .navigationTitle("My Recipes")
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .alert("API Test Result", isPresented: $showingAPITest) {
                Button("OK") {}
            } message: {
                Text(apiTestResult)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Refresh recipes when app becomes active (to show Share Extension additions)
            storageManager.loadRecipes()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh when app comes back from background (after Share Extension)
            storageManager.loadRecipes()
        }
    }
    
    private func testAPI() {
        Task {
            do {
                print("🧪 Testing OpenAI API...")
                let openAIService = OpenAIService.shared
                
                let testPrompt = """
                Extract recipe information from this text and return it in JSON format:
                
                "Chocolate Chip Cookies
                Ingredients: 2 cups flour, 1 cup sugar, 1/2 cup butter, 2 eggs, 1 cup chocolate chips
                Instructions: Mix dry ingredients. Add wet ingredients. Fold in chocolate chips. Bake at 350°F for 12 minutes."
                """
                
                let result = try await openAIService.generateRecipeFromText(testPrompt)
                
                await MainActor.run {
                    apiTestResult = "✅ API Test Successful!\n\nResponse:\n\(String(result.prefix(200)))..."
                    showingAPITest = true
                }
                
            } catch {
                await MainActor.run {
                    apiTestResult = "❌ API Test Failed:\n\n\(error.localizedDescription)"
                    showingAPITest = true
                }
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(Theme.Colors.tertiaryText)
            
            VStack(spacing: Theme.Spacing.small) {
                Text("No recipes yet")
                    .font(Typography.Title2.semibold)
                    .foregroundColor(Theme.Colors.text)
                
                Text("Start by adding your first recipe")
                    .font(Typography.Body.regular)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.xLarge)
    }
}

struct AddRecipeButton: View {
    @Binding var showingAddRecipe: Bool
    
    var body: some View {
        Button(action: { showingAddRecipe = true }) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: Theme.Shadow.medium.color,
                        radius: Theme.Shadow.medium.radius,
                        x: Theme.Shadow.medium.x,
                        y: Theme.Shadow.medium.y
                    )
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    HomeView()
}