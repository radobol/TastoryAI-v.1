//
//  RecipeCardView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    var isSelectionMode: Bool = false
    var isSelected: Bool = false

    var body: some View {
        let cardContent = VStack(alignment: .leading, spacing: 0) {
            // Image section with top corners only rounded
            if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(TastoryColors.border)
                                .aspectRatio(1.2, contentMode: .fit)

                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(1.2, contentMode: .fill)
                            .clipped()
                    case .failure(_):
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            // Content section
            VStack(alignment: .leading, spacing: TastorySpacing.xs) {
                Text(recipe.title)
                    .font(TastoryTypography.body)
                    .foregroundColor(TastoryColors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Display primary category using TastoryBadge
                let categoryName = getCategoryDisplayName(for: recipe)
                TastoryBadge(text: categoryName, style: .tag, icon: "tag.fill")

                HStack(spacing: TastorySpacing.sm) {
                    Label("\(recipe.servings)", systemImage: "person.2.fill")
                        .font(TastoryTypography.caption)
                        .foregroundColor(TastoryColors.tertiaryText)

                    Spacer()

                    Text("\(recipe.ingredients.count) items")
                        .font(TastoryTypography.caption)
                        .foregroundColor(TastoryColors.tertiaryText)
                }
            }
            .padding(TastorySpacing.sm)
        }
        .background(TastoryColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: TastoryRadius.large))
        .tastoryShadow(TastoryShadow.small)
        .overlay(alignment: .topTrailing) {
            if isSelectionMode {
                ZStack {
                    Circle()
                        .fill(isSelected ? TastoryColors.primaryGreen : TastoryColors.cardBackground)
                        .frame(width: 28, height: 28)
                        .tastoryShadow(TastoryShadow.small)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(TastorySpacing.xs)
            }
        }

        return Group {
            if isSelectionMode {
                cardContent
                    .buttonStyle(PlainButtonStyle())
            } else {
                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // MARK: - Private Views

    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(TastoryColors.border)
                .aspectRatio(1.2, contentMode: .fit)

            Image(systemName: "photo")
                .font(.system(size: TastoryIconSize.xLarge))
                .foregroundColor(TastoryColors.tertiaryText)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCategoryDisplayName(for recipe: Recipe) -> String {
        guard let primaryCategoryId = recipe.primaryCategoryId else {
            return "New recipes" // Default fallback
        }
        
        return CategoryManager.shared.getCategoryName(for: primaryCategoryId) ?? "New recipes"
    }
}

#Preview {
    RecipeCardView(recipe: Recipe.sampleRecipes[0])
        .padding()
        .background(TastoryColors.background)
}