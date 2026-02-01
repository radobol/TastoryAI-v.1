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
                VStack(alignment: .leading, spacing: TastorySpacing.lg) {
                    // Title and Category
                    titleSection

                    // Servings Control
                    servingsSection

                    // Ingredients
                    ingredientsSection

                    // Instructions
                    instructionsSection

                    // Tips & Notes
                    tipsSection

                    // Source URL
                    sourceURLSection
                }
                .padding(TastorySpacing.md)
            }
        }
        .background(TastoryColors.background)
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
                        .foregroundColor(TastoryColors.primaryGreen)
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
        Group {
            if let imageURL = viewModel.recipe.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(TastoryColors.border)
                                .frame(height: 250)

                            ProgressView()
                                .scaleEffect(1.2)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    case .failure(_):
                        heroPlaceholder
                    @unknown default:
                        heroPlaceholder
                    }
                }
            } else {
                heroPlaceholder
            }
        }
    }

    private var heroPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(TastoryColors.border)
                .frame(height: 250)

            Image(systemName: "photo")
                .font(.system(size: TastoryIconSize.xxLarge))
                .foregroundColor(TastoryColors.tertiaryText)
        }
    }
    
    private var titleSection: some View {
        TastoryCard {
            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                Text(viewModel.recipe.title)
                    .font(TastoryTypography.title)
                    .foregroundColor(TastoryColors.primaryText)

                // Display primary category from new category system
                let categoryName = getCategoryDisplayName(for: viewModel.recipe)
                TastoryBadge(text: categoryName, style: .tag, icon: "tag.fill")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var servingsSection: some View {
        TastoryCard {
            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                Text("Servings")
                    .font(TastoryTypography.headline)
                    .foregroundColor(TastoryColors.primaryText)

                HStack(spacing: TastorySpacing.md) {
                    Button(action: viewModel.decreaseServings) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: TastoryIconSize.large))
                            .foregroundColor(viewModel.currentServings > 1 ? TastoryColors.primaryGreen : TastoryColors.tertiaryText)
                    }
                    .disabled(viewModel.currentServings <= 1)

                    Text("\(viewModel.currentServings)")
                        .font(TastoryTypography.title)
                        .foregroundColor(TastoryColors.primaryText)
                        .frame(minWidth: 40)

                    Button(action: viewModel.increaseServings) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: TastoryIconSize.large))
                            .foregroundColor(viewModel.currentServings < 20 ? TastoryColors.primaryGreen : TastoryColors.tertiaryText)
                    }
                    .disabled(viewModel.currentServings >= 20)

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var ingredientsSection: some View {
        TastoryCard {
            VStack(alignment: .leading, spacing: TastorySpacing.md) {
                Text("Ingredients")
                    .font(TastoryTypography.headline)
                    .foregroundColor(TastoryColors.primaryText)

                VStack(alignment: .leading, spacing: TastorySpacing.sm) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var instructionsSection: some View {
        TastoryCard {
            VStack(alignment: .leading, spacing: TastorySpacing.md) {
                Text("Instructions")
                    .font(TastoryTypography.headline)
                    .foregroundColor(TastoryColors.primaryText)

                VStack(alignment: .leading, spacing: TastorySpacing.md) {
                    ForEach(Array(viewModel.recipe.steps.enumerated()), id: \.offset) { index, step in
                        InstructionStep(number: index + 1, instruction: step)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var tipsSection: some View {
        Group {
            if !viewModel.recipe.tips.isEmpty {
                TastoryCard(backgroundColor: TastoryColors.lightGreenBg) {
                    VStack(alignment: .leading, spacing: TastorySpacing.md) {
                        Text("Tips & Notes")
                            .font(TastoryTypography.headline)
                            .foregroundColor(TastoryColors.primaryText)

                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            ForEach(viewModel.recipe.tips, id: \.self) { tip in
                                HStack(alignment: .top, spacing: TastorySpacing.sm) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: TastoryIconSize.small))
                                        .foregroundColor(TastoryColors.primaryGreen)
                                        .padding(.top, 2)

                                    Text(tip)
                                        .font(TastoryTypography.bodyRegular)
                                        .foregroundColor(TastoryColors.primaryText)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var sourceURLSection: some View {
        Group {
            if let sourceURL = viewModel.recipe.sourceURL, !sourceURL.isEmpty {
                if let url = URL(string: sourceURL) {
                    Link(destination: url) {
                        TastoryListItem(
                            title: "Original recipe",
                            leadingIcon: "link",
                            showChevron: true
                        )
                    }
                } else {
                    TastoryListItem(
                        title: "Original recipe",
                        leadingIcon: "link",
                        showChevron: false
                    )
                }
            }
        }
    }
    
    private func duplicateRecipe() {
        _ = viewModel.duplicateRecipe()
    }
    
    private func getCategoryDisplayName(for recipe: Recipe) -> String {
        guard let primaryCategoryId = recipe.primaryCategoryId else {
            return "New recipes" // Default fallback
        }
        
        return CategoryManager.shared.getCategoryName(for: primaryCategoryId) ?? "New recipes"
    }
}


struct IngredientRow: View {
    let ingredient: String
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: TastorySpacing.sm) {
                // Green bullet or checkmark
                if isChecked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: TastoryIconSize.medium))
                        .foregroundColor(TastoryColors.successGreen)
                } else {
                    TastoryBullet()
                }

                Text(ingredient)
                    .font(TastoryTypography.bodyRegular)
                    .foregroundColor(isChecked ? TastoryColors.secondaryText : TastoryColors.primaryText)
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
        HStack(alignment: .top, spacing: TastorySpacing.sm) {
            TastoryNumberBadge(number: number)

            Text(instruction)
                .font(TastoryTypography.bodyRegular)
                .foregroundColor(TastoryColors.primaryText)
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
