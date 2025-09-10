# Category System - Technical Documentation & Implementation Plan

## Original Requirements (from CLAUDE.md)
Implement a category system for recipe organization with multi-category support, primary category designation, and a dedicated Categories tab for management.

---

## TODO List - Category System Implementation

### ✅ Completed Items:
- [x] Create Category model with id, name, slug, is_system fields
- [x] Update Recipe model with categoryIds array and primaryCategoryId
- [x] Seed "New recipes" as reserved system category (is_system=true, non-deletable)
- [x] Recipe create behavior: auto-assign "New recipes" as primary
- [x] Basic validation logic (1-32 chars, trimmed)
- [x] CategoryManager service for CRUD operations
- [x] Display category in recipe cards and detail views
- [x] Basic category picker in EditRecipeView (single selection only currently)

### ✅ Phase 1: Recipe Creation/Edit UI Enhancements (COMPLETED - 2025-09-10)
- [x] Add "+ New Category" option to category picker in:
  - [x] EditRecipeView.swift - Two-input system with Menu-based pickers
  - [x] RecipeEditingView.swift - Consistent Menu UI for both primary/secondary
  - [x] AddRecipeView.swift - Uses RecipeEditingView (already has category support)
  - [x] ~Share Extension - UIKit implementation with primary/secondary pickers~ (Reverted - see Phase 8)
- [x] Allow choosing from existing categories - Single shared category list
- [x] Support multiple categories per recipe - Primary + Additional categories
- [x] UI to designate/change primary category - Separate Primary/Secondary inputs
- [x] Validate new category names - Case/diacritic-insensitive with proper error messages

### 📋 Phase 2: Categories Tab Implementation
- [ ] Create new "Categories" tab (keep Search tab - don't replace)
- [ ] Add to MainTabView with folder.fill or tag.fill icon
- [ ] Create CategoriesView.swift as main categories screen

### 📋 Phase 3: Categories Section UI
- [ ] Categories list display:
  - [ ] "New recipes" always first (pinned)
  - [ ] Other categories sorted A→Z (locale + case/diacritic-insensitive)
  - [ ] Show recipe count for each category
- [ ] Filtering by category:
  - [ ] Tap category to see filtered recipes
  - [ ] Recipes appear in ALL categories they're assigned to
  - [ ] Each recipe shows in every category it belongs to
- [ ] "+ New category" button in navigation bar
- [ ] Edit mode:
  - [ ] Swipe or edit button for rename/delete
  - [ ] Rename with validation
  - [ ] Delete with confirmation

### 📋 Phase 4: Category Delete Rules
- [ ] Implement delete with reassignment logic:
  - [ ] If deleting primary category → reassign to "New recipes" 
  - [ ] If deleting non-primary → just remove from recipe
  - [ ] Block deletion if is_system=true
- [ ] Show warning about affected recipes before delete
- [ ] Ensure no recipe is left without at least one category

### 📋 Phase 5: Search Implementation (Separate Feature)
- [ ] Add search bar to HomeView (not Categories)
- [ ] 250ms debounce for performance
- [ ] Search across: title, ingredients, categories, steps
- [ ] Case/diacritic-insensitive matching
- [ ] AND logic across search tokens
- [ ] Highlight matching terms
- [ ] Search works with active category filter

### 📋 Phase 6: Bulk Selection (Apple Photos Style)
- [ ] Selection mode:
  - [ ] Long-press recipe card to enter
  - [ ] OR "Select" button in navigation
- [ ] Select multiple recipes:
  - [ ] Checkbox overlay on cards
  - [ ] Select all/none options
- [ ] Bulk actions:
  - [ ] Delete selected recipes
  - [ ] Add category to selected
  - [ ] Remove category from selected
  - [ ] Change primary category (single recipe only)
- [ ] Share multiple recipes

### 📋 Phase 7: UI Polish
- [ ] Add share button directly on recipe card thumbnails
- [ ] Rename "items" to "ingredients" on recipe cards
- [ ] Empty states for categories with no recipes
- [ ] Smooth animations for filtering and transitions

### 📋 Phase 8: Share Extension Deep Linking
- [ ] Add "Edit Recipe" button to Share Extension
  - [ ] Shows after recipe is saved successfully
  - [ ] Opens main app directly to EditRecipeView for that recipe
- [ ] Implement URL scheme for the main app (e.g., `tastoryai://edit-recipe/{recipe-id}`)
- [ ] Handle deep link in TastoryAI_v_1App.swift
- [ ] Navigate to EditRecipeView with the specified recipe
- [ ] This avoids duplicating complex category UI in Share Extension
- [ ] Users can still quickly save recipes, then edit categories in the main app

---

## Current Technical Implementation (Updated 2025-09-10)

### Overview
The category system foundation has been implemented with core functionality working. Phase 1 is now complete with a two-input category system (Primary/Secondary) that maintains a single shared category list throughout the app.

### Phase 1 Implementation Details (Completed 2025-09-10)

#### Two-Input Category System
- **Primary Category**: Required, single selection from all available categories
- **Secondary Categories**: Optional, multiple selections (excluding primary)
- **Consistent UI**: Both use Menu-based pickers (no overlays/sheets for selection)
- **Single Category List**: All pickers draw from the same CategoryManager.categories

#### Key Improvements Made
1. **Fixed category filtering** - Secondary picker shows all categories except primary and already selected
2. **Consistent Menu UI** - Replaced AddCategorySheet overlay with Menu-based approach
3. **Proper validation** - Case/diacritic-insensitive duplicate checking with error messages
4. **Data consistency** - Primary category always included in categoryIds array
5. **Helper methods** - Added getAdditionalCategoryIds() to Recipe model

### Important Design Decisions

#### Schema Approach
**Original Plan**: Separate `recipe_categories` junction table  
**Current Implementation**: Arrays in Recipe model (`categoryIds`, `primaryCategoryId`)  
**Rationale**: Simpler for local JSON storage, achieves same functionality

#### Fixed UUID Strategy
**Decision**: "New recipes" uses hardcoded UUID `00000000-0000-0000-0000-000000000001`  
**Rationale**: Ensures consistency between main app and Share Extension without CategoryManager access

### Technical Architecture

#### 1. Data Models

**Category Model** (`/TastoryAI v.1/Models/Category.swift`)
```swift
struct Category: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var slug: String
    var isSystem: Bool
    let createdAt: Date
    var updatedAt: Date
    
    // Fixed UUID for "New recipes" system category
    static let newRecipesCategoryId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let newRecipesCategory = Category(
        id: newRecipesCategoryId,
        name: "New recipes",
        isSystem: true
    )
}
```

**Recipe Model Updates** (`/TastoryAI v.1/Models/Recipe.swift`)
```swift
struct Recipe {
    // New category fields
    var categoryIds: [UUID]        // All categories this recipe belongs to
    var primaryCategoryId: UUID?   // Primary category for display
    var category: String?          // Legacy field (kept for migration, always nil now)
    
    // Helper methods
    func hasCategory(_ categoryId: UUID) -> Bool
    mutating func addCategory(_ categoryId: UUID, asPrimary: Bool = false)
    mutating func removeCategory(_ categoryId: UUID)
    mutating func setPrimaryCategory(_ categoryId: UUID)
}
```

#### 2. Services

**CategoryManager** (`/TastoryAI v.1/Services/CategoryManager.swift`)
- Singleton service managing all category operations
- Stores categories in JSON file in documents directory
- Key methods:
  - `getNewRecipesCategory()` - Returns the system "New recipes" category
  - `getCategoryName(for id: UUID)` - Resolves category UUID to name
  - `createCategory(name: String)` - Creates new user category
  - `deleteCategory(_ category: Category)` - Deletes category and reassigns recipes
  - `initializeSystemCategories()` - Ensures "New recipes" exists on startup

**RecipeStorageManager Updates** (`/TastoryAI v.1/Services/RecipeStorageManager.swift`)
- Modified to handle category assignments
- `assignNewRecipesCategoryToRecipesWithoutCategories()` - Migration helper
- Auto-assigns "New recipes" to any recipe without categories
- Uses hardcoded UUID to avoid Share Extension compatibility issues

#### 3. UI Implementation

**Category Display**
- `RecipeCardView.swift` - Shows primary category with tag icon
- `RecipeDetailView.swift` - Displays primary category in detail view
- Both use helper method `getCategoryDisplayName(for recipe: Recipe)`

**Category Editing**
- `EditRecipeView.swift` - Has category picker (currently single selection)
- Uses `@StateObject private var categoryManager = CategoryManager.shared`
- Picker shows all available categories from CategoryManager

### Key Technical Decisions

#### 1. Fixed UUID for System Category
- "New recipes" uses hardcoded UUID: `00000000-0000-0000-0000-000000000001`
- Ensures consistency between main app and Share Extension
- Avoids issues with CategoryManager not being available in extensions

#### 2. Share Extension Compatibility
- Share Extension cannot access CategoryManager (different target)
- Uses hardcoded UUID directly when assigning categories
- Categories saved to shared App Group container for sync

#### 3. Migration Strategy
- No migration needed during development phase
- Sample recipes updated to remove legacy category field
- All recipes auto-assigned to "New recipes" if no category exists

### Files Modified/Created

#### Created Files:
- `/TastoryAI v.1/Models/Category.swift` - Category data model
- `/TastoryAI v.1/Services/CategoryManager.swift` - Category management service

#### Modified Files:
- `/TastoryAI v.1/Models/Recipe.swift` - Added category fields and helper methods (setPrimaryCategory, getAdditionalCategoryIds)
- `/TastoryAI v.1/Services/RecipeStorageManager.swift` - Category assignment logic
- `/TastoryAI v.1/Services/RecipeExtractionService.swift` - Auto-assign "New recipes"
- `/TastoryAI v.1/Services/CategoryManager.swift` - Enhanced validation (createCategory, validateCategoryName)
- `/TastoryAI v.1/Views/RecipeCardView.swift` - Display category
- `/TastoryAI v.1/Views/RecipeDetailView.swift` - Display category
- `/TastoryAI v.1/Views/EditRecipeView.swift` - Two-input category system with Menu pickers
- `/TastoryAI v.1/Views/RecipeEditingView.swift` - Consistent Menu-based category selection
- `/TastoryAI v.1/Views/CategorySheets.swift` - NEW: Modal for creating new categories
- `/TastoryAI v.1/Views/AddRecipeView.swift` - Auto-assign categories (needs category selection UI)
- `/TastoryShare/ShareViewController.swift` - Use hardcoded category UUID (needs category picker)

### Known Issues (Fixed)

#### 1. Picker Validation Error
**Issue**: "Picker: the selection '00000000-0000-0000-0000-000000000001' is invalid"
**Cause**: CategoryManager.getNewRecipesCategory() called during init before categories loaded
**Fix**: Use `Category.newRecipesCategoryId` directly instead of CategoryManager lookup

#### 2. Share Extension Build Errors
**Issue**: CategoryManager not available in Share Extension target
**Fix**: Use hardcoded UUID directly in Share Extension code

---

## Implementation Guide - Quick Reference

### Phase 1: Adding "+ New Category" to Pickers
**Pattern**: Add a button/row at bottom of picker that shows sheet for new category creation
**Validation**: 1-32 chars, trimmed, case-insensitive uniqueness
**Files**: EditRecipeView, RecipeEditingView, AddRecipeView, ShareViewController

### Phase 2: Categories Tab
**Create**: CategoriesView.swift, CategoryRowView.swift
**Update**: MainTabView to add Categories tab (keep Search tab)
**Icon**: folder.fill or tag.fill

### Phase 3: Category Filtering
**Add**: `getRecipes(for categoryId:)` to RecipeStorageManager
**Display**: Filtered RecipeGridView when category tapped
**Important**: Recipes appear in ALL categories they belong to

### Phase 4: Delete Rules
**Primary deleted**: Reassign to "New recipes"
**Non-primary deleted**: Just remove from recipe
**System category**: Block deletion

### Phase 5: Search (HomeView)
**Location**: HomeView, not Categories tab
**Debounce**: 250ms
**Search**: title, ingredients, steps, categories
**Logic**: AND across tokens

### Phase 6: Bulk Selection
**Trigger**: Long-press or Select button
**Style**: Like Apple Photos app
**Actions**: Delete, add/remove categories, share

---

## Testing Strategy

### After Each Phase:
1. **Clean Build**: `xcodebuild clean`
2. **Build**: `xcodebuild build -scheme "TastoryAI v.1"`
3. **Install**: Fresh install on simulator (delete old app first)
4. **Test Checklist**: Complete phase-specific tests
5. **User Testing**: Real-world usage test
6. **Document Issues**: Note any bugs or UX problems

### Critical Test Scenarios:
- Recipe with no categories → Should get "New recipes"
- Delete last category from recipe → Should get "New recipes"
- Create duplicate category name → Should show error
- Delete category with recipes → Recipes reassigned to "New recipes"
- Share Extension category sync → New categories appear in main app

---

## Success Metrics
- ✅ No data loss during any operation
- ✅ All recipes always have at least one category
- ✅ Categories sync properly between app and extension
- ✅ Search returns results in <100ms
- ✅ UI remains responsive during all operations
- ✅ No crashes or data corruption

## Testing Strategy for Each Phase

### Phase-by-Phase Testing
After completing each phase:
1. Clean build: `xcodebuild clean`
2. Build: `xcodebuild build -scheme "TastoryAI v.1"`
3. Fresh install on simulator (delete old app first)
4. Complete phase-specific test checklist
5. User acceptance testing
6. Document any issues found

### Critical Test Scenarios
- Recipe with no categories → Must get "New recipes"
- Delete last category from recipe → Must reassign to "New recipes"
- Create duplicate category name → Must show validation error
- Delete category with recipes → Recipes must be reassigned properly
- Multi-category recipe → Must appear in all assigned categories
- Share Extension category sync → New categories must appear in main app

## Remaining Work

### Phase 1 COMPLETED ✅ (with modification)
All recipe creation/import methods in the main app support the two-input category system:
- Main app editing (EditRecipeView, RecipeEditingView)
- Manual entry (via RecipeEditingView)

**Note**: Share Extension category UI was reverted in favor of a simpler approach with deep linking (see Phase 8)

### Next Priority - Phase 2: Categories Tab
**Goal**: Create dedicated Categories tab for browsing and managing categories
- Replace Search tab with Categories tab
- Display all categories with recipe counts
- Navigation to filtered recipe views

## Next Steps
**Continue with Phase 2**: Create CategoriesView.swift and integrate into MainTabView, replacing the placeholder Search tab.