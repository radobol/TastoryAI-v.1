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
        }
        .navigationViewStyle(StackNavigationViewStyle())
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