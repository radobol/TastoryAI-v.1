Category System Implementation Plan (Final Revision)

---
Phase 2: Categories Tab Implementation (Replace Search Tab)

Goal: Replace Search tab with Categories tab showing unified category list (3 tabs total: Recipes, Categories, Profile)

Tasks:
1. Create CategoriesView.swift:
  Location: /TastoryAI v.1/Views/CategoriesView.swift
  Features:
  - Display all categories in a List
  - "New recipes" always appears first (pinned at top)
  - Other categories sorted alphabetically (case/diacritic-insensitive)
  - Show recipe count for each category
  - Navigation to filtered recipe view when category tapped
  - "+ New Category" button in navigation bar
  Structure:
    @StateObject private var categoryManager = CategoryManager.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @State private var showingNewCategorySheet = false

2. Update MainTabView.swift:
  - Replace SearchView() with CategoriesView()
  - Change tab label from "Search" to "Categories"
  - Change icon from "magnifyingglass" to "folder.fill" or "tag.fill"
  - Keep tag(1) for middle tab position
  - Remove SearchView struct (lines 37-49)

3. Create FilteredRecipesView.swift:
  Location: /TastoryAI v.1/Views/FilteredRecipesView.swift
  Features:
  - Display recipes filtered by selected category
  - Use same RecipeGridView component as HomeView
  - Show category name in navigation title
  - Handle recipes that belong to multiple categories

4. Update RecipeStorageManager:
  Add method: getRecipes(for categoryId: UUID) -> [Recipe]
  - Returns all recipes where categoryIds.contains(categoryId)
  - Ensures recipes appear in ALL categories they belong to

5. Implement Category Creation:
  - Use existing NewCategorySheet from CategorySheets.swift
  - Integrate with CategoryManager.createCategory()
  - Show validation errors for duplicates
  - Refresh category list after creation

UI/UX Details:
- Category List Row: Name (left), Recipe count badge (right), Chevron indicator
- "New recipes" with special styling or icon
- Empty states: "No categories yet" if only system category exists
- Navigation Flow: Categories tab → Category list → Tap category → Filtered recipes

Testing Checklist:
- Search tab replaced with Categories tab
- Categories tab shows folder/tag icon
- "New recipes" appears first in list
- Other categories sorted alphabetically
- Recipe counts are accurate
- Tapping category shows filtered recipes
- Recipes appear in multiple categories correctly
- "+ New Category" button works
- Category creation with validation
- Empty states display correctly

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