//
//  AddRecipeView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingManualEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.xLarge) {
                    VStack(spacing: Theme.Spacing.large) {
                        Text("Add a Recipe")
                            .font(Typography.Title1.bold)
                            .foregroundColor(Theme.Colors.text)
                        
                        Text("Choose how you'd like to add your recipe")
                            .font(Typography.Body.regular)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.Spacing.xLarge)
                    
                    VStack(spacing: Theme.Spacing.medium) {
                        AddOptionButton(
                            icon: "link",
                            title: "From URL",
                            subtitle: "Paste a link from any website",
                            action: {  }
                        )
                        
                        AddOptionButton(
                            icon: "camera.fill",
                            title: "From Photo",
                            subtitle: "Take or select a photo",
                            action: {  }
                        )
                        
                        AddOptionButton(
                            icon: "square.and.pencil",
                            title: "Manual Entry",
                            subtitle: "Type or paste your recipe",
                            action: { showingManualEntry = true }
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.large)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualRecipeEntryView()
        }
    }
}

struct ManualRecipeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = RecipeStorageManager.shared
    
    @State private var title = ""
    @State private var category = ""
    @State private var servings = 4
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    @State private var tags: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Recipe Title", text: $title)
                        .font(Typography.Body.regular)
                    
                    TextField("Category (optional)", text: $category)
                        .font(Typography.Body.regular)
                    
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                        .font(Typography.Body.regular)
                }
                
                Section("Ingredients") {
                    ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                        TextField("Ingredient \(index + 1)", text: Binding(
                            get: { ingredients[index] },
                            set: { ingredients[index] = $0 }
                        ))
                        .font(Typography.Body.regular)
                    }
                    .onDelete(perform: deleteIngredient)
                    
                    Button("Add Ingredient") {
                        ingredients.append("")
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
                
                Section("Instructions") {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(alignment: .leading) {
                            Text("Step \(index + 1)")
                                .font(Typography.Subheadline.semibold)
                                .foregroundColor(Theme.Colors.accent)
                            
                            TextField("Instruction", text: Binding(
                                get: { steps[index] },
                                set: { steps[index] = $0 }
                            ), axis: .vertical)
                            .font(Typography.Body.regular)
                            .lineLimit(3, reservesSpace: true)
                        }
                    }
                    .onDelete(perform: deleteStep)
                    
                    Button("Add Step") {
                        steps.append("")
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .foregroundColor(Theme.Colors.accent)
                    .disabled(title.isEmpty || ingredients.allSatisfy { $0.isEmpty } || steps.allSatisfy { $0.isEmpty })
                }
            }
        }
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        if ingredients.isEmpty {
            ingredients.append("")
        }
    }
    
    private func deleteStep(at offsets: IndexSet) {
        steps.remove(atOffsets: offsets)
        if steps.isEmpty {
            steps.append("")
        }
    }
    
    private func saveRecipe() {
        let filteredIngredients = ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let filteredSteps = steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        let newRecipe = Recipe(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: filteredIngredients,
            steps: filteredSteps,
            category: category.isEmpty ? nil : category.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags,
            servings: servings
        )
        
        storageManager.addRecipe(newRecipe)
        dismiss()
    }
}

struct AddOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(Theme.Colors.accent.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                    Text(title)
                        .font(Typography.Headline.regular)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text(subtitle)
                        .font(Typography.Subheadline.regular)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.tertiaryText)
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(
                color: Theme.Shadow.small.color,
                radius: Theme.Shadow.small.radius,
                x: Theme.Shadow.small.x,
                y: Theme.Shadow.small.y
            )
        }
    }
}

#Preview {
    AddRecipeView()
}