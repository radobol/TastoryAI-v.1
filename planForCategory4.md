Category System Implementation Plan (Final Revision)

---
## Phase 1: Data Models & Recipe Editing ✅ COMPLETED

**Status**: ✅ Fully implemented and tested

### Completed Components

#### 1. Category Model (Category.swift)
**Location**: `/TastoryAI v.1/Models/Category.swift`

**Implementation Details**:
- Full `Category` struct: `id: UUID`, `name: String`, `slug: String`, `isSystem: Bool`, `createdAt: Date`, `updatedAt: Date`
- Fixed system category UUID: `00000000-0000-0000-0000-000000000001` for "New recipes"
- Validation methods: `isValidName()`, slug generation from name
- Helper properties: `isNewRecipesCategory` computed property
- Sample category generation for testing

#### 2. Recipe Model Updates (Recipe.swift)
**Location**: `/TastoryAI v.1/Models/Recipe.swift`

**Implementation Details**:
- New fields: `categoryIds: [UUID]`, `primaryCategoryId: UUID?`
- Legacy field maintained: `category: String?` (for backward compatibility)
- Helper methods implemented:
  - `hasCategory(_ categoryId: UUID) -> Bool`
  - `addCategory(_ categoryId: UUID, asPrimary: Bool = false)`
  - `removeCategory(_ categoryId: UUID)`
  - `setPrimaryCategory(_ categoryId: UUID)`
  - `getAdditionalCategoryIds() -> [UUID]` (returns all except primary)

#### 3. CategoryManager Service (CategoryManager.swift)
**Location**: `/TastoryAI v.1/Services/CategoryManager.swift`

**Implementation Details**:
- Singleton pattern: `CategoryManager.shared`
- App Groups support for Share Extension sync
- CRUD operations:
  - `loadCategories()` - Loads from JSON with "New recipes" auto-creation
  - `saveCategories()` - Persists to JSON
  - `addCategory(_ name: String) throws -> Category`
  - `updateCategory(_ category: Category) throws`
  - `deleteCategory(_ id: UUID) throws`
- Query methods:
  - `getCategory(withId: UUID) -> Category?`
  - `getCategoryByName(_ name: String) -> Category?`
  - `getCategoryBySlug(_ slug: String) -> Category?`
  - `getNewRecipesCategory() -> Category`
- Validation:
  - `isDuplicateName(_ name: String, excluding: UUID?) -> Bool`
  - `isValidCategoryName(_ name: String) -> Bool`
  - `validateCategoryName(_ name: String, excluding: UUID?) throws`
- Auto-sorting: System categories first, "New recipes" always first, then alphabetical
- System category protection: Cannot delete categories with `isSystem: true`

#### 4. RecipeStorageManager Enhancements
**Location**: `/TastoryAI v.1/Services/RecipeStorageManager.swift`

**Implementation Details**:
- Category filtering methods:
  - `filterRecipes(by categoryId: UUID) -> [Recipe]`
  - `getRecipesForCategory(_ categoryId: UUID) -> [Recipe]`
- Recipe reassignment:
  - `reassignRecipesFromDeletedCategory(categoryId: UUID, newCategoryId: UUID)`
  - `assignNewRecipesCategoryToRecipesWithoutCategories()`
- Auto-initialization on app launch
- Duplicate recipe support (preserves category assignments)

#### 5. UI Components - Category Sheets (CategorySheets.swift)
**Location**: `/TastoryAI v.1/Views/CategorySheets.swift`

**Implementation Details**:
- `NewCategorySheet`:
  - Name input with focus
  - Character limit: 1-32
  - Validation with error display
  - Save/Cancel buttons
- `AddCategorySheet`:
  - Category list picker
  - "Create New Category" button
  - Cancel action

#### 6. Recipe Editing UI Updates
**Files Modified**:
- `/TastoryAI v.1/Views/EditRecipeView.swift`
- `/TastoryAI v.1/Views/RecipeEditingView.swift` (Share Extension)

**Implementation Details**:
- Primary category dropdown (Menu-based)
- Additional categories section
- Remove buttons for secondary categories
- Prevents duplicate assignments
- Category creation overlay integration

#### 7. RecipeCardView Display
**Location**: `/TastoryAI v.1/Views/RecipeCardView.swift`

**Implementation Details**:
- Displays primary category with tag icon
- Helper method: `getCategoryDisplayName()` with fallback to "New recipes"

#### 8. Share Extension Integration
**Location**: `/TastoryShare/ShareViewController.swift`

**Implementation Details**:
- Category fields preserved in recipe extraction (lines 738-739)
- Full integration with category system

---
## Phase 2: Categories Tab Implementation (Replace Search Tab) ✅ **COMPLETED & TESTED**

**Goal**: Replace Search tab with Categories tab showing unified category list (3 tabs total: Recipes, Categories, Profile)

**Status**: All sub-phases completed and tested successfully by user

### Sub-Phase 2.1: Create CategoriesView ✅ COMPLETED

**File Created**: `/TastoryAI v.1/Views/CategoriesView.swift`

**Technical Requirements**:
- SwiftUI List displaying all categories
- @StateObject integration with CategoryManager.shared
- @StateObject integration with RecipeStorageManager.shared for recipe counts
- @State var showingNewCategorySheet for category creation modal
- NavigationStack with "Categories" title
- Toolbar with "+ New Category" button (placement: .navigationBarTrailing)

**UI Structure**:
```swift
NavigationStack {
    List {
        ForEach(sortedCategories) { category in
            NavigationLink(destination: FilteredRecipesView(category: category)) {
                CategoryRow(category: category, recipeCount: getRecipeCount(for: category.id))
            }
        }
    }
    .navigationTitle("Categories")
    .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingNewCategorySheet = true }) {
                Image(systemName: "plus")
            }
        }
    }
    .sheet(isPresented: $showingNewCategorySheet) {
        NewCategorySheet()
    }
}
```

**Sorting Logic**:
- "New recipes" always first (check `category.isNewRecipesCategory`)
- Other categories sorted alphabetically using locale-aware comparison
- Use `category.name.localizedStandardCompare()` for proper sorting

**Recipe Count Calculation**:
```swift
private func getRecipeCount(for categoryId: UUID) -> Int {
    storageManager.recipes.filter { $0.categoryIds.contains(categoryId) }.count
}
```

**Category Row Component**:
```swift
private struct CategoryRow: View {
    let category: Category
    let recipeCount: Int

    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundColor(Theme.Colors.accent)
            Text(category.name)
                .font(Typography.Body.regular)
            Spacer()
            Text("\(recipeCount)")
                .font(Typography.Caption.regular)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}
```

**Empty State**:
- Show message "No custom categories yet" if only "New recipes" exists
- Encourage user to create first category with + button

**Testing Checklist**:
- ✅ Categories list displays all categories
- ✅ "New recipes" appears first
- ✅ Other categories sorted A-Z (locale-aware)
- ✅ Recipe counts accurate for each category
- ✅ + button in navigation bar
- ✅ Tapping + opens NewCategorySheet
- ✅ Empty state shows when no custom categories
- ✅ No compilation errors

**Implementation Notes**:
- Used `Theme.Colors.secondaryText` (not textSecondary)
- Used `Typography.Caption1.regular` (not Caption.regular)
- Used `Theme.Spacing.xSmall` for vertical padding
- Category creation with full validation working correctly

---

### Sub-Phase 2.2: Update MainTabView ✅ COMPLETED

**File Modified**: `/TastoryAI v.1/Views/MainTabView.swift`

**Current State**:
- 3 tabs: Recipes (HomeView), Search (SearchView placeholder), Profile (ProfileView)
- Search tab uses "magnifyingglass" icon
- Search tab at index 1 (middle position)

**Changes Required**:
1. Import CategoriesView (will be created in Sub-Phase 2.1)
2. Replace `SearchView()` with `CategoriesView()` at tab index 1
3. Change label from "Search" to "Categories"
4. Change icon from "magnifyingglass" to "folder.fill"
5. Remove SearchView struct definition (approximately lines 37-49)

**Code Changes**:
```swift
// Before:
SearchView()
    .tabItem {
        Label("Search", systemImage: "magnifyingglass")
    }
    .tag(1)

// After:
CategoriesView()
    .tabItem {
        Label("Categories", systemImage: "folder.fill")
    }
    .tag(1)
```

**Testing Checklist**:
- ✅ Tab bar shows "Categories" instead of "Search"
- ✅ Tab icon is folder.fill (folder icon)
- ✅ Tab remains in middle position (index 1)
- ✅ Tapping tab navigates to CategoriesView
- ✅ No compilation errors
- ✅ App launches successfully
- ✅ SearchView struct removed completely

**Implementation Notes**:
- Successfully replaced SearchView() with CategoriesView()
- Changed icon to "folder.fill"
- Removed unused SearchView struct (previously lines 37-49)

---

### Sub-Phase 2.3: Create FilteredRecipesView ✅ COMPLETED & TESTED

**File Created**: `/TastoryAI v.1/Views/FilteredRecipesView.swift`

**Technical Requirements**:
- Accept `category: Category` as init parameter
- @StateObject integration with RecipeStorageManager.shared
- Filter recipes using `storageManager.getRecipesForCategory(category.id)`
- Reuse existing RecipeGridView component from HomeView
- NavigationTitle showing category name
- Handle empty state when category has no recipes

**UI Structure**:
```swift
struct FilteredRecipesView: View {
    let category: Category
    @StateObject private var storageManager = RecipeStorageManager.shared

    private var filteredRecipes: [Recipe] {
        storageManager.getRecipesForCategory(category.id)
    }

    var body: some View {
        Group {
            if filteredRecipes.isEmpty {
                // Empty state
                VStack(spacing: Theme.Spacing.medium) {
                    Image(systemName: "tray")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.Colors.textSecondary)
                    Text("No recipes in this category yet")
                        .font(Typography.Body.regular)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            } else {
                // Recipe grid
                RecipeGridView(recipes: filteredRecipes)
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
```

**Recipe Grid Integration**:
- Check if RecipeGridView exists in HomeView.swift
- If it's a private component, extract to separate file or duplicate
- Ensure consistent recipe card styling with HomeView

**Multi-Category Support**:
- Recipes can belong to multiple categories via `categoryIds` array
- Same recipe will appear in FilteredRecipesView for ALL its categories
- Example: Recipe with `categoryIds: [breakfast-id, quick-meals-id]` appears in both "Breakfast" and "Quick Meals" filtered views

**Empty State Design**:
- Icon: "tray" system image (large, muted color)
- Text: "No recipes in this category yet"
- Positioned centered in screen

**Testing Checklist**:
- ✅ Tapping category from list navigates to filtered view
- ✅ Navigation title shows correct category name
- ✅ Only recipes with matching categoryId are shown
- ✅ Recipe cards match HomeView design
- ✅ Empty state displays when category has 0 recipes
- ✅ Back button returns to categories list
- ✅ Recipes appear in ALL categories they're assigned to
- ✅ Recipe grid scrolls smoothly
- ✅ All user testing completed without issues

**Implementation Notes**:
- Successfully reused RecipeGridView component
- Empty state uses "tray" icon with secondaryText color
- Navigation title set to category.name with .large display mode
- Uses storageManager.getRecipesForCategory() for filtering

---

### Sub-Phase 2.4: Category Creation Flow Integration ✅ COMPLETED

**File Modified**: `/TastoryAI v.1/Views/CategoriesView.swift` (created in 2.1)

**Current State** (from Sub-Phase 2.1):
- + button in navigation bar opens NewCategorySheet
- Sheet uses existing NewCategorySheet from CategorySheets.swift

**Enhancements Required**:
1. Category list refresh after creation
2. Error handling for validation failures
3. Success feedback after category created
4. Sheet dismissal on success

**Implementation**:
```swift
@State private var showingNewCategorySheet = false
@State private var errorMessage: String?

// In toolbar button:
.sheet(isPresented: $showingNewCategorySheet) {
    NewCategorySheet(onCategoryCreated: {
        // Refresh is automatic via @StateObject CategoryManager
        showingNewCategorySheet = false
    }, onError: { error in
        errorMessage = error.localizedDescription
    })
}

// Error alert:
.alert("Error Creating Category", isPresented: .constant(errorMessage != nil)) {
    Button("OK") {
        errorMessage = nil
    }
} message: {
    if let errorMessage = errorMessage {
        Text(errorMessage)
    }
}
```

**NewCategorySheet Integration**:
- Verify NewCategorySheet exists in CategorySheets.swift
- Check if it needs callbacks for success/error
- Ensure validation uses CategoryManager.validateCategoryName()
- Display validation errors: duplicate name, character limits, empty name

**Validation Error Messages**:
- Empty name: "Category name cannot be empty"
- Too long: "Category name must be 32 characters or less"
- Duplicate: "A category with this name already exists"
- Invalid characters: Handled by CategoryManager validation

**Testing Checklist**:
- ✅ + button opens category creation sheet
- ✅ Can enter category name
- ✅ Validation prevents duplicate names (case-insensitive)
- ✅ Validation prevents names > 32 characters
- ✅ Validation prevents empty names
- ✅ Error messages display correctly
- ✅ New category appears in list after creation
- ✅ New category sorted correctly (alphabetically)
- ✅ Sheet dismisses after successful creation
- ✅ Can create multiple categories in sequence

**Implementation Notes**:
- Integrated with CategoryManager.createCategory() method
- Full validation working: duplicates, empty names, character limits
- Sheet dismisses automatically on success
- Error messages displayed in sheet when validation fails
- Category list refreshes automatically via @StateObject

---

### Sub-Phase 2.5: Verify RecipeStorageManager Method ✅ COMPLETED

**File Verified**: `/TastoryAI v.1/Services/RecipeStorageManager.swift`

**Required Method**:
```swift
func getRecipesForCategory(_ categoryId: UUID) -> [Recipe] {
    return recipes.filter { recipe in
        recipe.categoryIds.contains(categoryId)
    }
}
```

**Verification Steps**:
1. Read RecipeStorageManager.swift
2. Search for `getRecipesForCategory` method
3. If exists: verify implementation matches requirement
4. If missing: add method to RecipeStorageManager

**Expected Behavior**:
- Returns all recipes where `categoryIds` array contains the given `categoryId`
- Handles recipes with multiple categories correctly
- Same recipe can be returned by multiple category IDs
- Empty array if no recipes match

**Testing Checklist**:
- ✅ Method exists in RecipeStorageManager
- ✅ Method signature matches: `func getRecipesForCategory(_ categoryId: UUID) -> [Recipe]`
- ✅ Returns correct recipes for given category
- ✅ Handles empty categories (returns empty array)
- ✅ Handles recipes with multiple categories
- ✅ No side effects (read-only operation)

**Implementation Notes**:
- Method found at line 146-148 in RecipeStorageManager.swift
- Implementation: `return recipes.filter { $0.hasCategory(categoryId) }`
- Uses Recipe.hasCategory() helper method for cleaner code
- Properly handles multi-category recipes

---

## Phase 2 Success Criteria ✅ **FULLY COMPLETED & TESTED**

All sub-phases completed and tested successfully:

### Functional Requirements:
- ✅ Search tab replaced with Categories tab
- ✅ Categories tab shows folder.fill icon
- ✅ "New recipes" appears first in list
- ✅ Other categories sorted alphabetically (locale-aware)
- ✅ Recipe counts accurate for each category
- ✅ Tapping category navigates to filtered recipes view
- ✅ Filtered view shows correct recipes
- ✅ Recipes appear in ALL their assigned categories
- ✅ + New Category button works
- ✅ Category creation with full validation
- ✅ Empty states display correctly

### Technical Requirements:
- ✅ No compilation errors
- ✅ No runtime crashes
- ✅ App launches successfully in simulator
- ✅ Smooth navigation transitions
- ✅ Consistent Theme.swift and Typography.swift usage
- ✅ Proper @StateObject usage for managers

### User Testing Results:
- ✅ **Sub-Phase 2.1 + 2.2**: Categories tab appears, list displays correctly - TESTED AND CONFIRMED
- ✅ **Sub-Phase 2.3**: Tapping categories navigates to filtered recipes - TESTED WITHOUT ISSUES
- ✅ **Sub-Phase 2.4**: Creating new categories works with validation - TESTED AND CONFIRMED
- ✅ **Sub-Phase 2.5**: Recipe filtering logic is correct - VERIFIED AND TESTED

### User Testing Completed:
1. ✅ Tapped on different categories from the Categories list
2. ✅ Verified navigation to FilteredRecipesView works smoothly
3. ✅ Checked that correct recipes appear for each category
4. ✅ Verified recipes with multiple categories appear in all relevant filtered views
5. ✅ Tested empty state for categories with 0 recipes
6. ✅ Verified back navigation returns to Categories list

**Final Result**: Phase 2 completed successfully with zero issues reported during user testing.

---

## UI/UX Design Specifications

**Category List Row Design**:
- Left: Folder icon (folder.fill) + Category name
- Right: Recipe count (muted color) + Chevron
- Height: Default List row height (44-50pt)
- Tap area: Full row width

**"New recipes" Category Styling**:
- Same row design as other categories
- Position: Always first in list
- Icon: folder.fill (same as others)
- No special badge/styling (simplicity)

**Empty State Design**:
- Center-aligned vertically and horizontally
- Icon: "tray" system image, size 60, muted color
- Text: Typography.Body.regular, muted color
- Message: "No recipes in this category yet"

**Navigation Flow**:
```
Tab Bar → Categories Tab
    ↓
Categories List (CategoriesView)
    ↓ (tap category)
Filtered Recipes (FilteredRecipesView)
    ↓ (tap recipe)
Recipe Detail (existing RecipeDetailView)
```

---

## File Structure Summary

### New Files to Create:
1. `/TastoryAI v.1/Views/CategoriesView.swift` - Main categories list view
2. `/TastoryAI v.1/Views/FilteredRecipesView.swift` - Category-filtered recipe grid

### Files to Modify:
1. `/TastoryAI v.1/Views/MainTabView.swift` - Replace Search tab with Categories tab
2. `/TastoryAI v.1/Services/RecipeStorageManager.swift` - Verify/add getRecipesForCategory method

### Files Referenced (no changes):
1. `/TastoryAI v.1/Services/CategoryManager.swift` - Existing CRUD operations
2. `/TastoryAI v.1/Views/CategorySheets.swift` - Existing NewCategorySheet
3. `/TastoryAI v.1/Views/RecipeGridView.swift` - Reuse in FilteredRecipesView (if exists as separate component)
4. `/TastoryAI v.1/Design/Theme.swift` - UI styling constants
5. `/TastoryAI v.1/Design/Typography.swift` - Font definitions

---
## Phase 3: Category Management (Edit, Delete, Rename) ✅ **COMPLETED & TESTED**

**Goal**: Add edit/rename and delete functionality to Categories tab with iOS-standard swipe actions, validation, and smart recipe reassignment.

**Status**: All sub-phases completed and tested successfully by user

### Sub-Phase 3.1: Add Swipe Actions to CategoriesView ✅ COMPLETED

**File Modified**: `/TastoryAI v.1/Views/CategoriesView.swift`

**Implementation Details**:
- Added state variables for edit/delete UI management
- Implemented iOS-standard swipe actions on category rows
- Edit action (blue) and Delete action (red) on trailing edge
- System category protection: "New recipes" shows NO swipe actions
- allowsFullSwipe: false to prevent accidental deletion

**Code Added**:
```swift
// State variables (after line 16)
@State private var categoryToEdit: Category?
@State private var showingEditCategorySheet = false
@State private var editCategoryName = ""
@State private var editCategoryError: String?
@State private var categoryToDelete: Category?
@State private var showingDeleteAlert = false
@State private var deleteAffectedRecipeCount = 0

// Swipe actions on ForEach
.swipeActions(edge: .trailing, allowsFullSwipe: false) {
    if !category.isSystem {
        Button(role: .destructive) {
            handleDeleteSwipe(for: category)
        } label: {
            Label("Delete", systemImage: "trash")
        }

        Button {
            handleEditSwipe(for: category)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(Theme.Colors.accent)
    }
}

// Handler methods
private func handleEditSwipe(for category: Category)
private func handleDeleteSwipe(for category: Category)
```

**Testing Checklist**:
- ✅ Swipe actions appear on custom categories
- ✅ NO swipe actions on "New recipes" system category
- ✅ Edit shows blue, Delete shows red
- ✅ Full swipe doesn't immediately delete
- ✅ Tapping actions triggers correct behavior

---

### Sub-Phase 3.2: Create EditCategorySheet ✅ COMPLETED

**File Modified**: `/TastoryAI v.1/Views/CategorySheets.swift`

**Implementation Details**:
- Created EditCategorySheet following NewCategorySheet pattern
- Form-based UI with TextField for category name
- Auto-focus on text field when sheet appears
- Inline error display for validation failures
- Validation using CategoryManager.validateCategoryName(excluding:)
- Save/Cancel buttons with proper state management

**Code Added**:
```swift
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
            Form {
                Section {
                    TextField("Category Name", text: $categoryName)
                        .font(Typography.Body.regular)
                        .focused($isNameFieldFocused)
                        .onChange(of: categoryName) { _, _ in
                            errorMessage = nil
                        }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                } header: {
                    Text("Rename category")
                } footer: {
                    Text("Category names must be 1-32 characters and unique")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Category")
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
```

**CategoriesView Integration**:
- Sheet presentation triggered by showingEditCategorySheet
- handleUpdateCategory() validates and updates category
- Uses validateCategoryName(excluding:) to prevent false duplicate errors
- Auto-regenerates slug from new name
- Only dismisses sheet on success

**Testing Checklist**:
- ✅ Edit sheet opens with current name pre-filled
- ✅ Keyboard auto-focuses on text field
- ✅ Empty names disable Save button
- ✅ Duplicate names show validation error
- ✅ Names >32 characters show error
- ✅ Valid renames succeed and update list
- ✅ Cancel discards changes
- ✅ Sheet remains open on validation error

---

### Sub-Phase 3.3: Implement Delete Confirmation ✅ COMPLETED

**File Modified**: `/TastoryAI v.1/Views/CategoriesView.swift`

**Implementation Details**:
- Delete confirmation alert with destructive action
- Shows affected recipe count in alert message
- Proper singular/plural handling ("1 recipe" vs "N recipes")
- Recipe reassignment to "New recipes" before deletion
- Primary category reassignment handled automatically

**Code Added**:
```swift
.alert("Delete Category", isPresented: $showingDeleteAlert) {
    Button("Delete", role: .destructive) {
        if let category = categoryToDelete {
            handleDeleteCategory(category)
        }
    }
    Button("Cancel", role: .cancel) {
        resetDeleteState()
    }
} message: {
    if let category = categoryToDelete {
        if deleteAffectedRecipeCount > 0 {
            Text("Are you sure you want to delete \"\(category.name)\"? \(deleteAffectedRecipeCount) recipe\(deleteAffectedRecipeCount == 1 ? "" : "s") will be moved to \"New recipes\". This action cannot be undone.")
        } else {
            Text("Are you sure you want to delete \"\(category.name)\"? This action cannot be undone.")
        }
    }
}

private func handleDeleteCategory(_ category: Category) {
    let newRecipesCategory = categoryManager.getNewRecipesCategory()

    // Step 1: Reassign affected recipes to "New recipes"
    storageManager.reassignRecipesFromDeletedCategory(
        category.id,
        to: newRecipesCategory.id
    )

    // Step 2: Delete the category
    categoryManager.deleteCategory(withId: category.id)

    // Step 3: Clean up state
    resetDeleteState()
}

private func resetDeleteState() {
    categoryToDelete = nil
    deleteAffectedRecipeCount = 0
}
```

**Recipe Reassignment Flow**:
1. RecipeStorageManager.reassignRecipesFromDeletedCategory() removes category from all recipes
2. Recipe.removeCategory() auto-sets primary to first remaining category
3. If no categories remain, "New recipes" is added as fallback
4. CategoryManager.deleteCategory() removes category from list (with system category protection)

**Testing Checklist**:
- ✅ Alert shows before deletion
- ✅ Correct recipe count displayed in alert message
- ✅ Cancel button prevents deletion
- ✅ Delete removes category from list
- ✅ Recipes move to "New recipes" category
- ✅ Primary category reassignment works correctly
- ✅ System category cannot be deleted
- ✅ Delete with 0 recipes works properly
- ✅ Proper singular/plural grammar in messages

---

## Phase 3 Success Criteria ✅ **FULLY COMPLETED & TESTED**

### Functional Requirements:
- ✅ Swipe actions on custom categories (Edit + Delete)
- ✅ NO swipe actions on "New recipes" system category
- ✅ Edit opens sheet with pre-filled name
- ✅ Edit validates duplicates, length, empty names
- ✅ Edit updates category and maintains sorting
- ✅ Delete shows confirmation alert with recipe count
- ✅ Delete reassigns recipes to "New recipes"
- ✅ Primary category reassignment automatic
- ✅ System category protection works

### Technical Requirements:
- ✅ No compilation errors
- ✅ No runtime crashes
- ✅ App stable in simulator
- ✅ Proper Theme.swift and Typography.swift usage
- ✅ Leverages existing CategoryManager validation methods
- ✅ Uses RecipeStorageManager.reassignRecipesFromDeletedCategory()
- ✅ Recipe.removeCategory() handles primary reassignment

### User Testing Results:
- ✅ **All swipe actions tested and working correctly**
- ✅ **Edit functionality validated with various scenarios**
- ✅ **Delete confirmation and recipe reassignment verified**
- ✅ **System category protection confirmed**
- ✅ **User confirmed: "Everything works as expected"**

### Implementation Notes:
- Followed iOS-standard swipe action patterns
- Reused existing validation and deletion logic from CategoryManager
- Maintained code simplicity by leveraging existing infrastructure
- EditCategorySheet follows exact NewCategorySheet pattern
- Delete flow properly cleans up recipes before removing category

**Final Result**: Phase 3 completed successfully with zero issues reported during user testing.

---

## Category Operations Summary

**Current Implementation (Phases 1-3 Complete)**:

1. **Category Operations**:
  - ✅ Create: NewCategorySheet with full validation (Phase 1-2)
  - ✅ Rename: EditCategorySheet with duplicate checking (Phase 3)
  - ✅ Delete: Confirmation alert with recipe reassignment (Phase 3)

2. **Delete Rules** (Implemented):
```swift
// RecipeStorageManager.reassignRecipesFromDeletedCategory()
storageManager.recipes.forEach { recipe in
    if recipe.hasCategory(fromCategoryId) {
        var updatedRecipe = recipe
        updatedRecipe.removeCategory(fromCategoryId)

        if updatedRecipe.categoryIds.isEmpty {
            updatedRecipe.addCategory(toCategoryId, asPrimary: true)
        }

        storageManager.updateRecipe(updatedRecipe)
    }
}
```

3. **Recipe Filtering** (Implemented):
```swift
func getRecipesForCategory(_ categoryId: UUID) -> [Recipe] {
    return recipes.filter { $0.hasCategory(categoryId) }
}
```

**Testing Results**:
- ✅ Category CRUD maintains single list
- ✅ Delete rules preserve data integrity
- ✅ Recipes appear in all assigned categories

---
## Phase 4: Search Integration in HomeView ✅ **COMPLETED & TESTED**

**Goal**: Add comprehensive search functionality to HomeView including category names from CategoryManager

**Status**: Fully implemented and tested successfully by user

### Implementation Details

**File Modified**: `/TastoryAI v.1/Views/HomeView.swift`

**Features Implemented**:
- Search bar with iOS-native `.searchable` modifier
- 250ms debounced search for optimal performance
- Case/diacritic-insensitive matching using `String.folding()`
- AND logic across search tokens (all terms must match)
- Category name resolution via CategoryManager.getCategory()
- Empty state for no search results

**Search Fields**:
1. Recipe title
2. Ingredients list
3. Steps/instructions
4. **Category names** (resolved from recipe.categoryIds)

**Code Added**:
```swift
// State variables
@StateObject private var categoryManager = CategoryManager.shared
@State private var searchText = ""
@State private var debouncedSearchText = ""

// Filtered recipes with comprehensive search
private var filteredRecipes: [Recipe] {
    guard !debouncedSearchText.isEmpty else {
        return storageManager.recipes
    }

    // Split search text into tokens and normalize
    let searchTokens = debouncedSearchText
        .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        .split(separator: " ")
        .map { String($0) }

    guard !searchTokens.isEmpty else {
        return storageManager.recipes
    }

    return storageManager.recipes.filter { recipe in
        // Get category names for this recipe
        let categoryNames = recipe.categoryIds.compactMap { categoryId in
            categoryManager.getCategory(withId: categoryId)?.name
        }.joined(separator: " ")

        // Combine all searchable fields
        let searchableContent = [
            recipe.title,
            recipe.ingredients.joined(separator: " "),
            recipe.steps.joined(separator: " "),
            categoryNames
        ]
        .joined(separator: " ")
        .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

        // AND logic: all tokens must match
        return searchTokens.allSatisfy { token in
            searchableContent.contains(token)
        }
    }
}

// Searchable modifier with debounce
.searchable(text: $searchText, prompt: "Search recipes, ingredients, or categories")
.onChange(of: searchText) { _, newValue in
    // Debounce search with 250ms delay
    Task {
        try? await Task.sleep(nanoseconds: 250_000_000)
        if searchText == newValue {
            debouncedSearchText = newValue
        }
    }
}
```

**Empty State Component**:
```swift
struct SearchEmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.secondaryText)

            VStack(spacing: Theme.Spacing.small) {
                Text("No results found")
                    .font(Typography.Title2.semibold)
                    .foregroundColor(Theme.Colors.text)

                Text("Try searching for different keywords")
                    .font(Typography.Body.regular)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Theme.Spacing.xLarge)
    }
}
```

**View Update**:
```swift
if storageManager.recipes.isEmpty {
    EmptyStateView()
} else if filteredRecipes.isEmpty && !debouncedSearchText.isEmpty {
    SearchEmptyStateView(searchText: debouncedSearchText)
} else {
    RecipeGridView(recipes: filteredRecipes)
}
```

### Testing Checklist ✅

**Basic Search**:
- ✅ Search bar appears in navigation bar
- ✅ Search by recipe title works
- ✅ Search by ingredients works
- ✅ Search by steps/instructions works

**Category Search (NEW)**:
- ✅ Search finds recipes by category names
- ✅ Works for primary categories
- ✅ Works for additional categories
- ✅ CategoryManager integration successful

**Advanced Features**:
- ✅ Multi-word search (AND logic) works correctly
- ✅ 250ms debounce implemented and working
- ✅ Case-insensitive matching (PASTA = pasta = Pasta)
- ✅ Diacritic-insensitive matching (café = cafe)
- ✅ All search tokens must match (AND logic)

**UI/UX**:
- ✅ Empty state shows for no results
- ✅ Search clears properly
- ✅ Performance is smooth with debounce
- ✅ iOS-native search behavior

### User Testing Results:
- ✅ **All search functionality tested and working correctly**
- ✅ **Category name search verified**
- ✅ **Multi-word search tested**
- ✅ **Debounce performance confirmed**
- ✅ **User confirmed: "Everything works as expected"**

### Implementation Notes:
- Used iOS-native `.searchable()` modifier for consistency
- CategoryManager integration for real-time category name resolution
- Debounced search prevents performance issues during typing
- `String.folding()` handles both case and diacritic insensitivity
- AND logic ensures all search terms must be present
- Search works across all recipe fields including resolved category names

**Final Result**: Phase 4 completed successfully with zero issues reported during user testing.

---

## Search Implementation Summary

**Current Implementation (Phases 1-4 Complete)**:

1. **Search Functionality**:
   - ✅ Search bar in HomeView with `.searchable` modifier
   - ✅ 250ms debounced search for performance
   - ✅ Case/diacritic-insensitive matching
   - ✅ AND logic across multiple search tokens
   - ✅ Category name resolution from CategoryManager

2. **Searchable Fields**:
```swift
// All fields combined for comprehensive search
let searchableContent = [
    recipe.title,                              // Recipe title
    recipe.ingredients.joined(separator: " "), // All ingredients
    recipe.steps.joined(separator: " "),       // All steps
    categoryNames                              // Resolved category names
].joined(separator: " ")
```

3. **Search Algorithm**:
```swift
// Normalize search text and split into tokens
let searchTokens = debouncedSearchText
    .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    .split(separator: " ")

// AND logic: all tokens must match somewhere in searchable content
return searchTokens.allSatisfy { token in
    searchableContent.contains(token)
}
```

**Testing Results**:
- ✅ Search finds recipes by title, ingredients, steps, and categories
- ✅ Multi-word search works with AND logic
- ✅ Performance optimized with 250ms debounce
- ✅ Works for both primary and additional categories

---
Phase 5: Bulk Selection

Goal: Bulk category operations using single list

Tasks:
1. Bulk Category Operations:
  - "Add Category": Shows picker with full list
  - "Remove Category": Shows only categories recipes have
  - "Set Primary": Changes primary (keeps in categoryIds)

Testing Checklist:
- Bulk operations maintain data consistency
- Category list properly filtered in pickers

---
Phase 6-7: Polish & Cleanup

(Unchanged from previous plan)

---
Key Architecture Principles:

1. Single Source of Truth: One category list in CategoryManager
2. Data Consistency: Primary category ALWAYS in categoryIds array
3. UI Clarity: Two inputs for better UX, same data source
4. Proper Filtering: Pickers filter to prevent duplicates
5. Recipe Appears Everywhere: Shows in ALL its categories

This approach ensures:
- Simple, maintainable code
- Consistent user experience
- No data duplication
- Clear primary/additional distinction
- Recipes properly appear in all assigned categories

Ready to implement Phase 2 with this architecture?