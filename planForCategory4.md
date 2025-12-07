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
Phase 3: Category Management & Filtering

Goal: CRUD operations maintaining single category list

Tasks:
1. Category Operations:
  - Create: Adds to single CategoryManager list
  - Rename: Updates in CategoryManager
  - Delete: Removes from CategoryManager + recipe cleanup
2. Delete Rules:
// For each recipe with this category:
if recipe.primaryCategoryId == deletingCategoryId {
    recipe.primaryCategoryId = Category.newRecipesCategoryId
    recipe.categoryIds = [Category.newRecipesCategoryId] +
                        recipe.categoryIds.filter { $0 != deletingCategoryId }
} else {
    recipe.categoryIds.removeAll { $0 == deletingCategoryId }
}
3. Recipe Filtering:
  - Single method: getRecipes(for categoryId: UUID)
  - Returns all where recipe.categoryIds.contains(categoryId)

Testing Checklist:
- Category CRUD maintains single list
- Delete rules preserve data integrity
- Recipes appear in all assigned categories

---
Phase 4: Search in HomeView

Goal: Search includes category names from single list

Tasks:
1. Search Implementation:
  - Search recipe fields + category names
  - Resolve categoryIds to names via CategoryManager
  - Match on any category the recipe belongs to

Testing Checklist:
- Search finds recipes by category names
- Works for both primary and additional categories

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