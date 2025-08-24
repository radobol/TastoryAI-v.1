//
//  RecipeDetailView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeViewModel
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @Environment(\.dismiss) private var dismiss
    
    init(recipeId: UUID) {
        _viewModel = StateObject(wrappedValue: RecipeViewModel(recipeId: recipeId))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Section
                heroImageSection
                
                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    // Title and Category
                    titleSection
                    
                    // Servings Control
                    servingsSection
                    
                    // Ingredients
                    ingredientsSection
                    
                    // Instructions
                    instructionsSection
                }
                .padding(Theme.Spacing.medium)
            }
        }
        .background(Theme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditView = true }) {
                        Label("Edit Recipe", systemImage: "pencil")
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Label("Share Recipe", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: duplicateRecipe) {
                        Label("Duplicate Recipe", systemImage: "doc.on.doc")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete Recipe", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditRecipeView(recipe: viewModel.recipe) { updatedRecipe in
                viewModel.updateRecipe(updatedRecipe)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [viewModel.shareRecipeText()])
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteRecipe()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.recipe.title)\"? This action cannot be undone.")
        }
    }
    
    private var heroImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Theme.Colors.tertiaryBackground)
                .frame(height: 250)
            
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.tertiaryText)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text(viewModel.recipe.title)
                .font(Typography.Title1.bold)
                .foregroundColor(Theme.Colors.text)
            
            if let category = viewModel.recipe.category {
                HStack(spacing: Theme.Spacing.xSmall) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 12))
                    Text(category)
                        .font(Typography.Subheadline.semibold)
                }
                .foregroundColor(Theme.Colors.accent)
            }
            
        }
    }
    
    private var servingsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Servings")
                .font(Typography.Headline.regular)
                .foregroundColor(Theme.Colors.text)
            
            HStack(spacing: Theme.Spacing.medium) {
                Button(action: viewModel.decreaseServings) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.currentServings > 1 ? Theme.Colors.accent : Theme.Colors.tertiaryText)
                }
                .disabled(viewModel.currentServings <= 1)
                
                Text("\(viewModel.currentServings)")
                    .font(Typography.Title2.bold)
                    .foregroundColor(Theme.Colors.text)
                    .frame(minWidth: 40)
                
                Button(action: viewModel.increaseServings) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.currentServings < 20 ? Theme.Colors.accent : Theme.Colors.tertiaryText)
                }
                .disabled(viewModel.currentServings >= 20)
                
                Spacer()
            }
        }
        .padding(Theme.Spacing.medium)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Ingredients")
                .font(Typography.Headline.regular)
                .foregroundColor(Theme.Colors.text)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                ForEach(viewModel.scaledIngredients, id: \.self) { ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        isChecked: viewModel.isIngredientChecked(ingredient)
                    ) {
                        viewModel.toggleIngredientCheck(ingredient)
                    }
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Instructions")
                .font(Typography.Headline.regular)
                .foregroundColor(Theme.Colors.text)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                ForEach(Array(viewModel.recipe.steps.enumerated()), id: \.offset) { index, step in
                    InstructionStep(number: index + 1, instruction: step)
                }
            }
        }
    }
    
    private func duplicateRecipe() {
        _ = viewModel.duplicateRecipe()
    }
}


struct IngredientRow: View {
    let ingredient: String
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isChecked ? Theme.Colors.success : Theme.Colors.tertiaryText)
                
                Text(ingredient)
                    .font(Typography.Body.regular)
                    .foregroundColor(isChecked ? Theme.Colors.secondaryText : Theme.Colors.text)
                    .strikethrough(isChecked)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InstructionStep: View {
    let number: Int
    let instruction: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.small) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(Typography.Caption1.medium)
                    .foregroundColor(.white)
            }
            
            Text(instruction)
                .font(Typography.Body.regular)
                .foregroundColor(Theme.Colors.text)
                .multilineTextAlignment(.leading)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        RecipeDetailView(recipeId: Recipe.sampleRecipes[0].id)
    }
}