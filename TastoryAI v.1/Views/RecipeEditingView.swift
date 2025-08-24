//
//  RecipeEditingView.swift
//  TastoryAI
//
//  Created by Claude on 7/25/25.
//

import SwiftUI
import PhotosUI

struct RecipeEditingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var recipe: Recipe
    @State private var ingredients: [String]
    @State private var steps: [String]
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessingPhoto = false
    
    let onSave: (Recipe) -> Void
    let onCancel: () -> Void
    
    init(recipe: Recipe, onSave: @escaping (Recipe) -> Void, onCancel: @escaping () -> Void) {
        self._recipe = State(initialValue: recipe)
        self._ingredients = State(initialValue: recipe.ingredients.isEmpty ? [""] : recipe.ingredients)
        self._steps = State(initialValue: recipe.steps.isEmpty ? [""] : recipe.steps)
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                    // Recipe Header
                    HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                        // Recipe Image
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.Colors.secondaryBackground)
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            )
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    case .failure(_):
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.Colors.secondaryBackground)
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(Theme.Colors.tertiaryText)
                                            )
                                    @unknown default:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.Colors.secondaryBackground)
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(Theme.Colors.tertiaryText)
                                            )
                                    }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.Colors.secondaryBackground)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 24))
                                                .foregroundColor(Theme.Colors.tertiaryText)
                                            
                                            Text("Tap to add")
                                                .font(.system(size: 10))
                                                .foregroundColor(Theme.Colors.tertiaryText)
                                        }
                                    )
                            }
                        }
                        .disabled(isProcessingPhoto)
                        
                        // Recipe Title
                        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                            TextField("Recipe Title", text: $recipe.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Theme.Colors.text)
                                .textFieldStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, Theme.Spacing.medium)
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        HStack {
                            Text("INGREDIENTS")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.secondaryLabel))
                                .padding(.horizontal, Theme.Spacing.medium)
                            
                            Spacer()
                            
                            Button(action: addIngredient) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.Colors.accent)
                                    .font(.system(size: 20))
                            }
                            .padding(.trailing, Theme.Spacing.medium)
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                                RecipeIngredientRow(
                                    text: $ingredients[index],
                                    onDelete: ingredients.count > 1 ? { deleteIngredient(at: index) } : nil
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    // Steps Section
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        HStack {
                            Text("INSTRUCTIONS")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.secondaryLabel))
                                .padding(.horizontal, Theme.Spacing.medium)
                            
                            Spacer()
                            
                            Button(action: addStep) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Theme.Colors.accent)
                                    .font(.system(size: 20))
                            }
                            .padding(.trailing, Theme.Spacing.medium)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                RecipeStepRow(
                                    number: index + 1,
                                    text: $steps[index],
                                    onDelete: steps.count > 1 ? { deleteStep(at: index) } : nil
                                )
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                    
                    // Add some bottom padding for the save button
                    Spacer(minLength: 80)
                }
                .padding(.vertical, Theme.Spacing.medium)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(Theme.Colors.secondaryText)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.medium)
                    .padding(.vertical, Theme.Spacing.small)
                    .background(Theme.Colors.accent)
                    .cornerRadius(8)
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem = newItem {
                        await loadPhoto(from: newItem)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func addIngredient() {
        ingredients.append("")
    }
    
    private func deleteIngredient(at index: Int) {
        ingredients.remove(at: index)
    }
    
    private func addStep() {
        steps.append("")
    }
    
    private func deleteStep(at index: Int) {
        steps.remove(at: index)
    }
    
    private func saveRecipe() {
        let updatedRecipe = Recipe(
            id: recipe.id,
            title: recipe.title.isEmpty ? "Untitled Recipe" : recipe.title,
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            steps: steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            imageURL: recipe.imageURL,
            category: recipe.category,
            servings: recipe.servings,
            createdAt: recipe.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedRecipe)
    }
    
    private func loadPhoto(from item: PhotosPickerItem) async {
        await MainActor.run {
            isProcessingPhoto = true
        }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let dataURL = ImageDataURL.create(from: image) {
                
                await MainActor.run {
                    recipe.imageURL = dataURL
                    isProcessingPhoto = false
                }
            }
        } catch {
            await MainActor.run {
                isProcessingPhoto = false
            }
        }
    }
}

// MARK: - Supporting Views

struct RecipeIngredientRow: View {
    @Binding var text: String
    let onDelete: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle")
                .foregroundColor(Color(.systemGray3))
                .font(.system(size: 16))
                .frame(width: 20, height: 20)
            
            TextField("Ingredient", text: $text)
                .font(.system(size: 16))
                .foregroundColor(Color(.label))
                .textFieldStyle(.plain)
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
            }
        }
        .frame(height: 44)
    }
}

struct RecipeStepRow: View {
    let number: Int
    @Binding var text: String
    let onDelete: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            Circle()
                .fill(Color(.systemOrange))
                .frame(width: 30, height: 30)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                TextField("Step description", text: $text, axis: .vertical)
                    .font(.system(size: 16))
                    .foregroundColor(Color(.label))
                    .textFieldStyle(.plain)
                    .lineLimit(3...10)
                
                if let onDelete = onDelete {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Text("Remove Step")
                                .font(Typography.Caption1.regular)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.vertical, Theme.Spacing.small)
    }
}

#Preview {
    RecipeEditingView(
        recipe: Recipe.sampleRecipes[0],
        onSave: { _ in },
        onCancel: { }
    )
}