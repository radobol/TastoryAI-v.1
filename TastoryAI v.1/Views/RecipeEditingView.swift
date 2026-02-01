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
    @State private var tips: [String]
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessingPhoto = false
    
    // Category management
    @State private var primaryCategoryId: UUID
    @State private var additionalCategoryIds: [UUID]
    @State private var showingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var categoryCreationError: String?
    @State private var newCategoryForPrimary = false
    
    @StateObject private var categoryManager = CategoryManager.shared
    
    let onSave: (Recipe) -> Void
    let onCancel: () -> Void
    
    init(recipe: Recipe, onSave: @escaping (Recipe) -> Void, onCancel: @escaping () -> Void) {
        self._recipe = State(initialValue: recipe)
        self._ingredients = State(initialValue: recipe.ingredients.isEmpty ? [""] : recipe.ingredients)
        self._steps = State(initialValue: recipe.steps.isEmpty ? [""] : recipe.steps)
        self._tips = State(initialValue: recipe.tips.isEmpty ? [""] : recipe.tips)
        
        // Initialize category fields
        self._primaryCategoryId = State(initialValue: recipe.primaryCategoryId ?? Category.newRecipesCategoryId)
        self._additionalCategoryIds = State(initialValue: recipe.getAdditionalCategoryIds())
        
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: TastorySpacing.lg) {
                    // Recipe Header Card
                    TastoryCard {
                        HStack(alignment: .top, spacing: TastorySpacing.md) {
                            // Recipe Image
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                                    AsyncImage(url: URL(string: imageURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            RoundedRectangle(cornerRadius: TastoryRadius.medium)
                                                .fill(TastoryColors.border)
                                                .frame(width: 100, height: 100)
                                                .overlay(ProgressView().scaleEffect(0.8))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: TastoryRadius.medium))
                                        case .failure(_):
                                            photoPlaceholder
                                        @unknown default:
                                            photoPlaceholder
                                        }
                                    }
                                } else {
                                    photoPlaceholder
                                }
                            }
                            .disabled(isProcessingPhoto)

                            // Recipe Title
                            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                                TextField("Recipe Title", text: $recipe.title)
                                    .font(TastoryTypography.title)
                                    .foregroundColor(TastoryColors.primaryText)
                                    .textFieldStyle(.plain)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    
                    // Categories Section
                    TastoryCard {
                        VStack(alignment: .leading, spacing: TastorySpacing.md) {
                            Text("Categories")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.primaryText)

                            VStack(spacing: TastorySpacing.sm) {
                                // Primary Category
                                HStack {
                                    Text("Primary:")
                                        .font(TastoryTypography.body)
                                        .foregroundColor(TastoryColors.secondaryText)
                                        .frame(width: 80, alignment: .leading)

                                    Menu {
                                        ForEach(categoryManager.categories, id: \.id) { category in
                                            Button(category.name) {
                                                primaryCategoryId = category.id
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
                                                .font(TastoryTypography.body)
                                                .foregroundColor(TastoryColors.primaryText)
                                            Spacer()
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption)
                                                .foregroundColor(TastoryColors.secondaryText)
                                        }
                                        .padding(.horizontal, TastorySpacing.sm)
                                        .padding(.vertical, TastorySpacing.xs)
                                        .background(TastoryColors.border)
                                        .cornerRadius(TastoryRadius.small)
                                    }
                                }

                                // Additional Categories as badges
                                if !additionalCategoryIds.isEmpty {
                                    HStack(alignment: .top) {
                                        Text("Also in:")
                                            .font(TastoryTypography.body)
                                            .foregroundColor(TastoryColors.secondaryText)
                                            .frame(width: 80, alignment: .leading)

                                        FlowLayout(spacing: TastorySpacing.xs) {
                                            ForEach(additionalCategoryIds, id: \.self) { categoryId in
                                                TastoryRemovableBadge(
                                                    text: categoryManager.getCategoryName(for: categoryId) ?? "Unknown",
                                                    icon: "tag.fill"
                                                ) {
                                                    additionalCategoryIds.removeAll { $0 == categoryId }
                                                }
                                            }
                                        }

                                        Spacer()
                                    }
                                }

                                // Add Category Menu
                                HStack {
                                    Text("Add:")
                                        .font(TastoryTypography.body)
                                        .foregroundColor(TastoryColors.secondaryText)
                                        .frame(width: 80, alignment: .leading)

                                    Menu {
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
                                            Text("Select category")
                                                .font(TastoryTypography.body)
                                                .foregroundColor(TastoryColors.primaryGreen)
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(TastoryColors.primaryGreen)
                                        }
                                    }
                                    .disabled(categoryManager.categories.filter { category in
                                        category.id != primaryCategoryId && !additionalCategoryIds.contains(category.id)
                                    }.isEmpty)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    
                    // Ingredients Section
                    TastoryCard {
                        VStack(alignment: .leading, spacing: TastorySpacing.md) {
                            HStack {
                                Text("Ingredients")
                                    .font(TastoryTypography.headline)
                                    .foregroundColor(TastoryColors.primaryText)

                                Spacer()

                                Button(action: addIngredient) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(TastoryColors.primaryGreen)
                                        .font(.system(size: TastoryIconSize.medium))
                                }
                            }

                            VStack(spacing: TastorySpacing.xs) {
                                ForEach(Array(ingredients.enumerated()), id: \.offset) { index, _ in
                                    RecipeIngredientRow(
                                        text: $ingredients[index],
                                        onDelete: ingredients.count > 1 ? { deleteIngredient(at: index) } : nil
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    
                    // Steps Section
                    TastoryCard {
                        VStack(alignment: .leading, spacing: TastorySpacing.md) {
                            HStack {
                                Text("Instructions")
                                    .font(TastoryTypography.headline)
                                    .foregroundColor(TastoryColors.primaryText)

                                Spacer()

                                Button(action: addStep) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(TastoryColors.primaryGreen)
                                        .font(.system(size: TastoryIconSize.medium))
                                }
                            }

                            VStack(spacing: TastorySpacing.sm) {
                                ForEach(Array(steps.enumerated()), id: \.offset) { index, _ in
                                    RecipeStepRow(
                                        number: index + 1,
                                        text: $steps[index],
                                        onDelete: steps.count > 1 ? { deleteStep(at: index) } : nil
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    
                    // Tips Section with light green background
                    TastoryCard(backgroundColor: TastoryColors.lightGreenBg) {
                        VStack(alignment: .leading, spacing: TastorySpacing.md) {
                            HStack {
                                Text("Tips & Notes")
                                    .font(TastoryTypography.headline)
                                    .foregroundColor(TastoryColors.primaryText)

                                Spacer()

                                Button(action: addTip) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(TastoryColors.primaryGreen)
                                        .font(.system(size: TastoryIconSize.medium))
                                }
                            }

                            VStack(spacing: TastorySpacing.sm) {
                                ForEach(Array(tips.enumerated()), id: \.offset) { index, _ in
                                    RecipeTipRow(
                                        text: $tips[index],
                                        onDelete: tips.count > 1 ? { deleteTip(at: index) } : nil
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)

                    // Save/Cancel Buttons
                    VStack(spacing: TastorySpacing.sm) {
                        TastoryButton(
                            title: "Save Recipe",
                            style: .primary,
                            icon: "checkmark",
                            action: saveRecipe
                        )

                        TastoryButton(
                            title: "Cancel",
                            style: .secondary,
                            action: onCancel
                        )
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    .padding(.bottom, TastorySpacing.lg)
                }
                .padding(.vertical, TastorySpacing.md)
            }
            .background(TastoryColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(TastoryColors.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, TastorySpacing.md)
                    .padding(.vertical, TastorySpacing.sm)
                    .background(TastoryColors.primaryGreen)
                    .cornerRadius(TastoryRadius.small)
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
                primaryCategoryId = category.id
                additionalCategoryIds.removeAll { $0 == category.id }
            } else {
                if category.id != primaryCategoryId {
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
    
    private func addTip() {
        tips.append("")
    }
    
    private func deleteTip(at index: Int) {
        tips.remove(at: index)
    }
    
    private func saveRecipe() {
        // Combine primary and additional categories
        var allCategoryIds = additionalCategoryIds
        if !allCategoryIds.contains(primaryCategoryId) {
            allCategoryIds.insert(primaryCategoryId, at: 0)
        }
        
        let updatedRecipe = Recipe(
            id: recipe.id,
            title: recipe.title.isEmpty ? "Untitled Recipe" : recipe.title,
            ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            steps: steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            imageURL: recipe.imageURL,
            categoryIds: allCategoryIds,
            primaryCategoryId: primaryCategoryId,
            category: nil, // Clear legacy field
            servings: recipe.servings,
            sourceURL: recipe.sourceURL,
            tips: tips.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
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

    // MARK: - Private Views

    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: TastoryRadius.medium)
            .fill(TastoryColors.border)
            .frame(width: 100, height: 100)
            .overlay(
                VStack(spacing: TastorySpacing.xxs) {
                    Image(systemName: "photo")
                        .font(.system(size: TastoryIconSize.large))
                        .foregroundColor(TastoryColors.tertiaryText)

                    Text("Tap to add")
                        .font(TastoryTypography.caption)
                        .foregroundColor(TastoryColors.tertiaryText)
                }
            )
    }
}

// MARK: - FlowLayout for category badges

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }

            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Supporting Views

struct RecipeIngredientRow: View {
    @Binding var text: String
    let onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: TastorySpacing.sm) {
            // Green bullet
            TastoryBullet()

            TextField("Ingredient", text: $text)
                .font(TastoryTypography.bodyRegular)
                .foregroundColor(TastoryColors.primaryText)
                .textFieldStyle(.plain)

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(TastoryColors.errorRed)
                        .font(.system(size: TastoryIconSize.small))
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
        HStack(alignment: .top, spacing: TastorySpacing.md) {
            // Green number badge
            TastoryNumberBadge(number: number, size: 30)

            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                TextField("Step description", text: $text, axis: .vertical)
                    .font(TastoryTypography.bodyRegular)
                    .foregroundColor(TastoryColors.primaryText)
                    .textFieldStyle(.plain)
                    .lineLimit(3...10)

                if let onDelete = onDelete {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Text("Remove Step")
                                .font(TastoryTypography.caption)
                                .foregroundColor(TastoryColors.errorRed)
                        }
                    }
                }
            }
        }
        .padding(.vertical, TastorySpacing.sm)
    }
}

struct RecipeTipRow: View {
    @Binding var text: String
    let onDelete: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: TastorySpacing.sm) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(TastoryColors.primaryGreen)
                .font(.system(size: TastoryIconSize.small))
                .frame(width: 20, height: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                TextField("Tip or note", text: $text, axis: .vertical)
                    .font(TastoryTypography.bodyRegular)
                    .foregroundColor(TastoryColors.primaryText)
                    .textFieldStyle(.plain)
                    .lineLimit(2...8)

                if let onDelete = onDelete {
                    HStack {
                        Spacer()
                        Button(action: onDelete) {
                            Text("Remove Tip")
                                .font(TastoryTypography.caption)
                                .foregroundColor(TastoryColors.errorRed)
                        }
                    }
                }
            }
        }
        .padding(.vertical, TastorySpacing.sm)
    }
}

#Preview {
    RecipeEditingView(
        recipe: Recipe.sampleRecipes[0],
        onSave: { _ in },
        onCancel: { }
    )
}