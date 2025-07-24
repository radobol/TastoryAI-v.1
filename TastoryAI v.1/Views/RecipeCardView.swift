//
//  RecipeCardView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Theme.Colors.tertiaryBackground)
                    .aspectRatio(1.2, contentMode: .fit)
                
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.tertiaryText)
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(recipe.title)
                    .font(Typography.Callout.semibold)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let category = recipe.category {
                    HStack(spacing: Theme.Spacing.xxSmall) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                        Text(category)
                            .font(Typography.Caption1.medium)
                    }
                    .foregroundColor(Theme.Colors.secondaryText)
                }
                
                HStack(spacing: Theme.Spacing.small) {
                    Label("\(recipe.servings)", systemImage: "person.2.fill")
                        .font(Typography.Caption1.regular)
                        .foregroundColor(Theme.Colors.tertiaryText)
                    
                    Spacer()
                    
                    Text("\(recipe.ingredients.count) items")
                        .font(Typography.Caption1.regular)
                        .foregroundColor(Theme.Colors.tertiaryText)
                }
            }
            .padding(Theme.Spacing.small)
        }
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.medium)
        .shadow(
            color: Theme.Shadow.small.color,
            radius: Theme.Shadow.small.radius,
            x: Theme.Shadow.small.x,
            y: Theme.Shadow.small.y
        )
        .onTapGesture {
            
        }
    }
}

#Preview {
    RecipeCardView(recipe: Recipe.sampleRecipes[0])
        .padding()
        .background(Theme.Colors.background)
}