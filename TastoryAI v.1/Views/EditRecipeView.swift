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
    @State private var primaryCategoryId: UUID
    @State private var additionalCategoryIds: [UUID]
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
    
    // Category creation
    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categoryCreationError: String?
    @State private var newCategoryForPrimary = false
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAddingIngredient: Bool
    @FocusState private var isAddingStep: Bool
    @FocusState private var isAddingTip: Bool
    
    @StateObject private var categoryManager = CategoryManager.shared
    
    let originalRecipe: Recipe
    let onSave: (Recipe) -> Void
    
    init(recipe: Recipe, onSave: @escaping (Recipe) -> Void) {
        self.originalRecipe = recipe
        self.onSave = onSave
        
        _title = State(initialValue: recipe.title)
        // Ensure primary category is set - fallback to "New recipes" if nil
        _primaryCategoryId = State(initialValue: recipe.primaryCategoryId ?? Category.newRecipesCategoryId)
        // Get additional categories (all except primary)
        _additionalCategoryIds = State(initialValue: recipe.getAdditionalCategoryIds())
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
                        .font(TastoryTypography.body)

                    // Primary Category Picker
                    HStack {
                        Text("Primary Category")
                            .font(TastoryTypography.body)
                        Spacer()
                        Menu {
                            ForEach(categoryManager.categories, id: \.id) { category in
                                Button(category.name) {
                                    primaryCategoryId = category.id
                                    // Remove from additional if it was there
                                    additionalCategoryIds.removeAll { $0 == category.id }
                                }
                            }
                            Divider()
                            Button(action: {
                                newCategoryForPrimary = true
                                showingNewCategorySheet = true
                            }) {
                                Label("New Category", systemImage: "plus.circle")
                            }
                        } label: {
                            HStack {
                                Text(categoryManager.getCategoryName(for: primaryCategoryId) ?? "Select")
                                    .foregroundColor(TastoryColors.primaryGreen)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundColor(TastoryColors.secondaryText)
                            }
                        }
                    }

                    HStack {
                        Text("Servings")
                            .font(TastoryTypography.body)
                        Spacer()
                        Stepper(value: $servings, in: 1...20) {
                            Text("\(servings)")
                                .font(TastoryTypography.headline)
                        }
                    }
                }
                
                // Additional Categories Section
                Section(header: Text("Additional Categories")) {
                    ForEach(additionalCategoryIds, id: \.self) { categoryId in
                        HStack {
                            TastoryBadge(
                                text: categoryManager.getCategoryName(for: categoryId) ?? "Unknown",
                                style: .tag,
                                icon: "tag.fill"
                            )
                            Spacer()
                            Button(action: {
                                additionalCategoryIds.removeAll { $0 == categoryId }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(TastoryColors.secondaryText)
                            }
                        }
                    }

                    // Use same Menu style as primary category for consistency
                    HStack {
                        Text("Add Category")
                            .font(TastoryTypography.body)
                        Spacer()
                        Menu {
                            // Show all categories except primary and already added
                            ForEach(categoryManager.categories.filter { category in
                                category.id != primaryCategoryId && !additionalCategoryIds.contains(category.id)
                            }, id: \.id) { category in
                                Button(category.name) {
                                    additionalCategoryIds.append(category.id)
                                }
                            }

                            if categoryManager.categories.filter({ category in
                                category.id != primaryCategoryId && !additionalCategoryIds.contains(category.id)
                            }).isEmpty {
                                Text("All categories already added")
                                    .foregroundColor(TastoryColors.secondaryText)
                            }

                            Divider()
                            Button(action: {
                                newCategoryForPrimary = false
                                showingNewCategorySheet = true
                            }) {
                                Label("New Category", systemImage: "plus.circle")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(TastoryColors.primaryGreen)
                                Text("Select")
                                    .foregroundColor(TastoryColors.primaryGreen)
                            }
                        }
                        .disabled(categoryManager.categories.filter { category in
                            category.id != primaryCategoryId && !additionalCategoryIds.contains(category.id)
                        }.isEmpty && !showingNewCategorySheet)
                    }
                }
                
                
                Section(header: Text("Ingredients")) {
                    ForEach(Array(ingredients.enumerated()), id: \.offset) { index, _ in
                        HStack {
                            TastoryBullet()
                            TextField("Ingredient", text: Binding(
                                get: { ingredients[index] },
                                set: { ingredients[index] = $0 }
                            ))
                            .font(TastoryTypography.bodyRegular)

                            Button(action: { ingredients.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(TastoryColors.errorRed)
                            }
                        }
                    }

                    HStack {
                        TastoryBullet(color: TastoryColors.tertiaryText)
                        TextField("Add ingredient", text: $newIngredient)
                            .font(TastoryTypography.bodyRegular)
                            .focused($isAddingIngredient)
                            .onSubmit {
                                addIngredient()
                            }

                        Button("Add", action: addIngredient)
                            .foregroundColor(TastoryColors.primaryGreen)
                            .disabled(newIngredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, _ in
                        HStack(alignment: .top) {
                            TastoryNumberBadge(number: index + 1, size: 24)

                            TextField("Step", text: Binding(
                                get: { steps[index] },
                                set: { steps[index] = $0 }
                            ), axis: .vertical)
                            .font(TastoryTypography.bodyRegular)
                            .lineLimit(3...6)

                            Button(action: { steps.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(TastoryColors.errorRed)
                            }
                        }
                    }

                    HStack(alignment: .top) {
                        ZStack {
                            RoundedRectangle(cornerRadius: TastoryRadius.small)
                                .fill(TastoryColors.tertiaryText)
                                .frame(width: 24, height: 24)
                            Text("\(steps.count + 1)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        TextField("Add step", text: $newStep, axis: .vertical)
                            .font(TastoryTypography.bodyRegular)
                            .lineLimit(3...6)
                            .focused($isAddingStep)
                            .onSubmit {
                                addStep()
                            }

                        Button("Add", action: addStep)
                            .foregroundColor(TastoryColors.primaryGreen)
                            .disabled(newStep.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                Section(header: Text("Tips & Notes")) {
                    ForEach(Array(tips.enumerated()), id: \.offset) { index, _ in
                        HStack(alignment: .top) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: TastoryIconSize.small))
                                .foregroundColor(TastoryColors.primaryGreen)
                                .frame(width: 20, alignment: .leading)
                                .padding(.top, 2)

                            TextField("Tip", text: Binding(
                                get: { tips[index] },
                                set: { tips[index] = $0 }
                            ), axis: .vertical)
                            .font(TastoryTypography.bodyRegular)
                            .lineLimit(2...6)

                            Button(action: { tips.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(TastoryColors.errorRed)
                            }
                        }
                    }

                    HStack(alignment: .top) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: TastoryIconSize.small))
                            .foregroundColor(TastoryColors.tertiaryText)
                            .frame(width: 20, alignment: .leading)
                            .padding(.top, 2)

                        TextField("Add tip or note", text: $newTip, axis: .vertical)
                            .font(TastoryTypography.bodyRegular)
                            .lineLimit(2...6)
                            .focused($isAddingTip)
                            .onSubmit {
                                addTip()
                            }

                        Button("Add", action: addTip)
                            .foregroundColor(TastoryColors.primaryGreen)
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
            .onAppear {
                // Ensure "New recipes" category exists in CategoryManager
                let _ = categoryManager.getNewRecipesCategory()
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NewCategorySheet(
                    categoryName: $newCategoryName,
                    errorMessage: $categoryCreationError,
                    onSave: { name in
                        createNewCategory(name: name, setPrimary: newCategoryForPrimary)
                    },
                    onCancel: {
                        newCategoryName = ""
                        categoryCreationError = nil
                        showingNewCategorySheet = false
                    }
                )
            }
        }
    }
    
    private func createNewCategory(name: String, setPrimary: Bool = false) {
        switch categoryManager.createCategory(name: name) {
        case .success(let category):
            if setPrimary {
                // If setting as primary, remove from additional if present
                primaryCategoryId = category.id
                additionalCategoryIds.removeAll { $0 == category.id }
            } else {
                // Only add to additional if not already primary
                if category.id != primaryCategoryId && !additionalCategoryIds.contains(category.id) {
                    additionalCategoryIds.append(category.id)
                }
            }
            newCategoryName = ""
            categoryCreationError = nil
            showingNewCategorySheet = false
        case .failure(let error):
            categoryCreationError = error.localizedDescription
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
        // Combine primary and additional categories
        var allCategoryIds = additionalCategoryIds
        if !allCategoryIds.contains(primaryCategoryId) {
            allCategoryIds.insert(primaryCategoryId, at: 0)
        }
        
        var updatedRecipe = Recipe(
            id: originalRecipe.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            steps: steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            imageURL: imageURL,
            categoryIds: allCategoryIds,
            primaryCategoryId: primaryCategoryId,
            category: nil, // Clear legacy field
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