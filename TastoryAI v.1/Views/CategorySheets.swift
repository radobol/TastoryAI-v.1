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
            Form {
                Section {
                    TextField("Category Name", text: $categoryName)
                        .font(Typography.Body.regular)
                        .focused($isNameFieldFocused)
                        .onChange(of: categoryName) { _, _ in
                            errorMessage = nil // Clear error when typing
                        }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Enter a name for the new category")
                } footer: {
                    Text("Category names must be 1-32 characters")
                        .font(.caption)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(categoryName)
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
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
            List {
                if !categories.isEmpty {
                    Section(header: Text("Available Categories")) {
                        ForEach(categories, id: \.id) { category in
                            Button(action: {
                                onSelectCategory(category.id)
                                dismiss()
                            }) {
                                HStack {
                                    Text(category.name)
                                        .font(Typography.Body.regular)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(Theme.Colors.accent)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        dismiss()
                        onCreateNew()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Theme.Colors.accent)
                            Text("Create New Category")
                                .foregroundColor(Theme.Colors.accent)
                                .font(Typography.Body.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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