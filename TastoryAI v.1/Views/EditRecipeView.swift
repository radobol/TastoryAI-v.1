//
//  EditRecipeView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import SwiftUI

struct EditRecipeView: View {
    @State private var title: String
    @State private var category: String
    @State private var servings: Int
    @State private var ingredients: [String]
    @State private var newIngredient: String = ""
    @State private var steps: [String]
    @State private var newStep: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAddingIngredient: Bool
    @FocusState private var isAddingStep: Bool
    
    let originalRecipe: Recipe
    let onSave: (Recipe) -> Void
    
    init(recipe: Recipe, onSave: @escaping (Recipe) -> Void) {
        self.originalRecipe = recipe
        self.onSave = onSave
        
        _title = State(initialValue: recipe.title)
        _category = State(initialValue: recipe.category ?? "")
        _servings = State(initialValue: recipe.servings)
        _ingredients = State(initialValue: recipe.ingredients)
        _steps = State(initialValue: recipe.steps)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Title", text: $title)
                        .font(Typography.Body.regular)
                    
                    TextField("Category (optional)", text: $category)
                        .font(Typography.Body.regular)
                    
                    HStack {
                        Text("Servings")
                            .font(Typography.Body.regular)
                        Spacer()
                        Stepper(value: $servings, in: 1...20) {
                            Text("\(servings)")
                                .font(Typography.Body.semibold)
                        }
                    }
                }
                
                
                Section(header: Text("Ingredients")) {
                    ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                        HStack {
                            TextField("Ingredient", text: Binding(
                                get: { ingredients[index] },
                                set: { ingredients[index] = $0 }
                            ))
                            .font(Typography.Body.regular)
                            
                            Button(action: { ingredients.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Add ingredient", text: $newIngredient)
                            .font(Typography.Body.regular)
                            .focused($isAddingIngredient)
                            .onSubmit {
                                addIngredient()
                            }
                        
                        Button("Add", action: addIngredient)
                            .disabled(newIngredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .font(Typography.Body.semibold)
                                .foregroundColor(Theme.Colors.accent)
                                .frame(width: 20, alignment: .leading)
                            
                            TextField("Step", text: Binding(
                                get: { steps[index] },
                                set: { steps[index] = $0 }
                            ), axis: .vertical)
                            .font(Typography.Body.regular)
                            .lineLimit(3...6)
                            
                            Button(action: { steps.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Text("\(steps.count + 1).")
                            .font(Typography.Body.semibold)
                            .foregroundColor(Theme.Colors.accent)
                            .frame(width: 20, alignment: .leading)
                        
                        TextField("Add step", text: $newStep, axis: .vertical)
                            .font(Typography.Body.regular)
                            .lineLimit(3...6)
                            .focused($isAddingStep)
                            .onSubmit {
                                addStep()
                            }
                        
                        Button("Add", action: addStep)
                            .disabled(newStep.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    
    private func addIngredient() {
        let trimmedIngredient = newIngredient.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedIngredient.isEmpty {
            ingredients.append(trimmedIngredient)
            newIngredient = ""
            isAddingIngredient = true
        }
    }
    
    private func addStep() {
        let trimmedStep = newStep.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedStep.isEmpty {
            steps.append(trimmedStep)
            newStep = ""
            isAddingStep = true
        }
    }
    
    private func saveRecipe() {
        let updatedRecipe = Recipe(
            id: originalRecipe.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            steps: steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            imageURL: originalRecipe.imageURL,
            category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : category.trimmingCharacters(in: .whitespacesAndNewlines),
            servings: servings,
            createdAt: originalRecipe.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedRecipe)
    }
}


#Preview {
    EditRecipeView(recipe: Recipe.sampleRecipes[0]) { _ in }
}