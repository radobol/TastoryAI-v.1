//
//  CategorySheets.swift
//  TastoryAI
//
//  Helper sheets for category creation and selection
//

import SwiftUI

// MARK: - New Category Creation Sheet
struct NewCategorySheet: View {
    @Binding var categoryName: String
    @Binding var errorMessage: String?
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                VStack(spacing: TastorySpacing.lg) {
                    // Title
                    Text("New Category")
                        .font(TastoryTypography.title)
                        .foregroundColor(TastoryColors.primaryText)
                        .padding(.top, TastorySpacing.lg)

                    // Input Card
                    TastoryCard {
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            Text("Category Name")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.primaryText)

                            TextField("Enter category name", text: $categoryName)
                                .font(TastoryTypography.body)
                                .padding(TastorySpacing.md)
                                .background(TastoryColors.background)
                                .cornerRadius(TastoryRadius.medium)
                                .focused($isNameFieldFocused)
                                .onChange(of: categoryName) { _, _ in
                                    errorMessage = nil
                                }

                            if let error = errorMessage {
                                Text(error)
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.errorRed)
                            }

                            Text("Category names must be 1-32 characters")
                                .font(TastoryTypography.caption)
                                .foregroundColor(TastoryColors.secondaryText)
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)

                    Spacer()

                    // Buttons
                    VStack(spacing: TastorySpacing.sm) {
                        TastoryButton(
                            title: "Create Category",
                            style: .primary,
                            icon: "plus",
                            isDisabled: categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ) {
                            onSave(categoryName)
                        }

                        TastoryButton(
                            title: "Cancel",
                            style: .secondary
                        ) {
                            onCancel()
                            dismiss()
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    .padding(.bottom, TastorySpacing.lg)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
}

// MARK: - Edit Category Sheet
struct EditCategorySheet: View {
    let category: Category
    @Binding var categoryName: String
    @Binding var errorMessage: String?
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                VStack(spacing: TastorySpacing.lg) {
                    // Title
                    Text("Edit Category")
                        .font(TastoryTypography.title)
                        .foregroundColor(TastoryColors.primaryText)
                        .padding(.top, TastorySpacing.lg)

                    // Input Card
                    TastoryCard {
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            Text("Category Name")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.primaryText)

                            TextField("Enter category name", text: $categoryName)
                                .font(TastoryTypography.body)
                                .padding(TastorySpacing.md)
                                .background(TastoryColors.background)
                                .cornerRadius(TastoryRadius.medium)
                                .focused($isNameFieldFocused)
                                .onChange(of: categoryName) { _, _ in
                                    errorMessage = nil
                                }

                            if let error = errorMessage {
                                Text(error)
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.errorRed)
                            }

                            Text("Category names must be 1-32 characters and unique")
                                .font(TastoryTypography.caption)
                                .foregroundColor(TastoryColors.secondaryText)
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)

                    Spacer()

                    // Buttons
                    VStack(spacing: TastorySpacing.sm) {
                        TastoryButton(
                            title: "Save Changes",
                            style: .primary,
                            icon: "checkmark",
                            isDisabled: categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ) {
                            onSave(categoryName)
                        }

                        TastoryButton(
                            title: "Cancel",
                            style: .secondary
                        ) {
                            onCancel()
                            dismiss()
                        }
                    }
                    .padding(.horizontal, TastorySpacing.md)
                    .padding(.bottom, TastorySpacing.lg)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
}

// MARK: - Add Category Selection Sheet
struct AddCategorySheet: View {
    let categories: [Category]
    let onSelectCategory: (UUID) -> Void
    let onCreateNew: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.md) {
                        // Categories list
                        if !categories.isEmpty {
                            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                                Text("Available Categories")
                                    .font(TastoryTypography.headline)
                                    .foregroundColor(TastoryColors.secondaryText)
                                    .padding(.horizontal, TastorySpacing.md)

                                VStack(spacing: 0) {
                                    ForEach(categories, id: \.id) { category in
                                        Button(action: {
                                            onSelectCategory(category.id)
                                            dismiss()
                                        }) {
                                            HStack(spacing: TastorySpacing.sm) {
                                                ZStack {
                                                    Circle()
                                                        .fill(TastoryColors.lightGreenBg)
                                                        .frame(width: 40, height: 40)
                                                    Image(systemName: "folder.fill")
                                                        .font(.system(size: TastoryIconSize.medium))
                                                        .foregroundColor(TastoryColors.primaryGreen)
                                                }

                                                Text(category.name)
                                                    .font(TastoryTypography.body)
                                                    .foregroundColor(TastoryColors.primaryText)

                                                Spacer()

                                                Image(systemName: "plus.circle")
                                                    .foregroundColor(TastoryColors.primaryGreen)
                                            }
                                            .padding(.horizontal, TastorySpacing.md)
                                            .padding(.vertical, TastorySpacing.sm)
                                        }

                                        if category.id != categories.last?.id {
                                            Divider()
                                                .padding(.leading, 56)
                                        }
                                    }
                                }
                                .background(TastoryColors.cardBackground)
                                .cornerRadius(TastoryRadius.large)
                                .padding(.horizontal, TastorySpacing.md)
                            }
                        }

                        // Create new button
                        TastoryButton(
                            title: "Create New Category",
                            style: .text,
                            icon: "plus.circle.fill"
                        ) {
                            dismiss()
                            onCreateNew()
                        }
                        .padding(.horizontal, TastorySpacing.md)
                    }
                    .padding(.top, TastorySpacing.md)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
                }
            }
        }
    }
}

#Preview("New Category Sheet") {
    NewCategorySheet(
        categoryName: .constant(""),
        errorMessage: .constant(nil),
        onSave: { _ in },
        onCancel: {}
    )
}

#Preview("Add Category Sheet") {
    AddCategorySheet(
        categories: Category.sampleCategories,
        onSelectCategory: { _ in },
        onCreateNew: {}
    )
}