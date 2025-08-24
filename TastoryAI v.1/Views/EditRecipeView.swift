//
//  EditRecipeView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @State private var title: String
    @State private var category: String
    @State private var servings: Int
    @State private var ingredients: [String]
    @State private var newIngredient: String = ""
    @State private var steps: [String]
    @State private var newStep: String = ""
    @State private var tips: [String]
    @State private var newTip: String = ""
    @State private var imageURL: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessingPhoto = false
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAddingIngredient: Bool
    @FocusState private var isAddingStep: Bool
    @FocusState private var isAddingTip: Bool
    
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
        _tips = State(initialValue: recipe.tips)
        _imageURL = State(initialValue: recipe.imageURL)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Image")) {
                    HStack {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            if let imageURL = imageURL, !imageURL.isEmpty {
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            )
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    case .failure(_):
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.secondary)
                                            )
                                    @unknown default:
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.secondary)
                                            )
                                    }
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 20))
                                                .foregroundColor(.secondary)
                                            
                                            Text("Tap to add photo")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                    )
                            }
                        }
                        .disabled(isProcessingPhoto)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recipe Photo")
                                .font(.headline)
                            
                            Text(imageURL != nil ? "Tap to replace photo" : "Tap to add a photo for this recipe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
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
                
                Section(header: Text("Tips & Notes")) {
                    ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .top) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.Colors.accent)
                                .frame(width: 20, alignment: .leading)
                                .padding(.top, 2)
                            
                            TextField("Tip", text: Binding(
                                get: { tips[index] },
                                set: { tips[index] = $0 }
                            ), axis: .vertical)
                            .font(Typography.Body.regular)
                            .lineLimit(2...6)
                            
                            Button(action: { tips.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.accent)
                            .frame(width: 20, alignment: .leading)
                            .padding(.top, 2)
                        
                        TextField("Add tip or note", text: $newTip, axis: .vertical)
                            .font(Typography.Body.regular)
                            .lineLimit(2...6)
                            .focused($isAddingTip)
                            .onSubmit {
                                addTip()
                            }
                        
                        Button("Add", action: addTip)
                            .disabled(newTip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem = newItem {
                        await loadPhoto(from: newItem)
                    }
                }
            }
        }
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
                    imageURL = dataURL
                    isProcessingPhoto = false
                }
            }
        } catch {
            await MainActor.run {
                isProcessingPhoto = false
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
    
    private func addTip() {
        let trimmedTip = newTip.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTip.isEmpty {
            tips.append(trimmedTip)
            newTip = ""
            isAddingTip = true
        }
    }
    
    private func saveRecipe() {
        let updatedRecipe = Recipe(
            id: originalRecipe.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            steps: steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            imageURL: imageURL,
            category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : category.trimmingCharacters(in: .whitespacesAndNewlines),
            servings: servings,
            sourceURL: originalRecipe.sourceURL,
            tips: tips.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            createdAt: originalRecipe.createdAt,
            updatedAt: Date()
        )
        
        onSave(updatedRecipe)
    }
}


#Preview {
    EditRecipeView(recipe: Recipe.sampleRecipes[0]) { _ in }
}