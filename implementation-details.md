# Implementation Details

This file contains technical implementation specifics for features in Tastory AI. For architecture overview and development status, see [CLAUDE.md](CLAUDE.md).

---

## Table of Contents

1. [Share Extension Processing Flow](#share-extension-processing-flow)
2. [Enhanced Recipe Scaling System](#enhanced-recipe-scaling-system)
3. [Photo Upload and Thumbnail Management](#photo-upload-and-thumbnail-management)
4. [Source URL and Tips Implementation](#source-url-and-tips-implementation)
5. [Share Extension Tips Integration](#share-extension-tips-integration)
6. [Category System Implementation](#category-system-implementation)
7. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)

---

## Share Extension Processing Flow

### Instagram/TikTok Posts

When users share from Instagram/TikTok, the Share Extension extracts:
- URLs (post links)
- Text (captions/descriptions)
- Images (post photos)
- Videos (for future audio extraction)

### Complete User Experience Flow

1. **Content Extraction** - ShareViewController extracts shared content (URLs, text, images)
2. **AI Processing** - "Importing..." progress screen while OpenAI processes content
3. **Recipe Editing UI** - Full editing interface appears with:
   - Recipe image placeholder (top left)
   - Editable recipe title field
   - Editable ingredients list with bullet points
   - Editable instructions with numbered steps
   - Save/Cancel buttons
4. **User Interaction** - User can modify AI-extracted content as needed
5. **Save to App Groups** - Recipe saved to shared container for main app access
6. **Success Feedback** - "Recipe Saved!" alert with completion

### Technical Implementation

```
ShareViewController → RecipeExtractionService.processSharedContent()
                  ↓
If URLs available → WebScrapingService.extractContent()
                  ↓
All content combined → OpenAIService.generateRecipeFromText()
                  ↓
Recipe editing UI → User edits → Save to App Groups → Success alert
```

### ReciMe-Style UI Features

- **Scrollable Content**: Full recipe editing in compact Share Extension format
- **Editable Fields**: All text fields and text views allow user modifications
- **Professional Design**: Clean layout with orange accent colors and proper spacing
- **Save/Cancel Flow**: Clear user actions with success feedback

---

## Enhanced Recipe Scaling System

### Current Implementation
- **Local Ingredient Database**: 100 common cooking ingredients with scaling properties and fuzzy matching (cooking_ingredients.json) (IngredientDatabase.swift)
- **Simplified IngredientParser**: Removed complex categorization, focus on quantity detection and database lookup (enhanced IngredientParser.swift)
- **Enhanced AI Prompts**: Standardized ingredient format requests ("2 cups flour" not "flour (2 cups)") (OpenAIService.swift)
- **Database-Driven Scaling**: Ingredient-specific scaling rules (salt/pepper marked as non-scalable)
- **Fuzzy Matching**: Handles ingredient name variations ("tomato" vs "tomatoes")

### Phase 2B: USDA API Integration (Future Enhancement)

#### USDA FoodData Central Integration Plan
- **API Endpoint**: https://api.nal.usda.gov/fdc/v1/
- **Rate Limits**: 1,000 requests/hour (generous compared to other APIs)
- **Authentication**: API key required (free registration)
- **Data Coverage**: 600,000+ food items, Foundation Foods for raw ingredients

#### Implementation Strategy
1. **Fallback Architecture**: Local database primary, API for missing ingredients
2. **Caching System**: Store API responses locally for 30 days
3. **Background Sync**: Update local database with frequently requested items
4. **Error Handling**: Graceful degradation when API unavailable
5. **User Experience**: Seamless integration with "Looking up ingredient..." feedback

#### Technical Components
- **USDAAPIService.swift**: API communication and response parsing
- **IngredientCache.swift**: Local storage for API responses
- **Enhanced IngredientDatabase**: Auto-expansion with API data
- **Background Tasks**: Periodic database updates and cleanup

#### Data Flow
```
User scales recipe → Check local database → If not found → Query USDA API
→ Cache response → Apply scaling → Display scaled ingredient
```

#### Rate Limiting Strategy
- **Batch Requests**: Group multiple ingredient lookups
- **Smart Caching**: Prioritize commonly used ingredients
- **User Feedback**: Progress indicators for API calls
- **Offline Mode**: Full functionality without internet

#### Security & Privacy
- **API Key Management**: Secure storage in Keychain
- **No User Data**: Only ingredient names sent to API
- **Local Processing**: All scaling calculations done locally

This approach ensures reliable offline scaling while providing comprehensive ingredient coverage through USDA's authoritative database.

---

## Photo Upload and Thumbnail Management

### Current Implementation (Completed)
- **Photo Upload Strategy**: User photos stored as data URLs in existing Recipe.imageURL field
- **Thumbnail Priority System**: (1) User uploaded photo, (2) AI-fetched thumbnail, (3) Placeholder
- **Editing Context Only**: Photo upload available in EditRecipeView and RecipeEditingView, not in detail view
- **Data URL Format**: Base64-encoded JPEG with 80% compression quality

### Technical Components

#### ImageDataURL Utility (ImageDataURL.swift)
```swift
struct ImageDataURL {
    static func create(from image: UIImage, compressionQuality: CGFloat = 0.8) -> String? {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }
}
```

#### PhotosPicker Integration Pattern
- Used in EditRecipeView.swift and RecipeEditingView.swift
- Single field approach: Recipe.imageURL handles both HTTP URLs and data URLs
- AsyncImage automatically handles both URL types without modification

### Key Design Decisions
1. **Single Field Architecture**: Avoid complexity of separate user/fetched image fields
2. **Data URL Storage**: Eliminates need for separate photo storage manager
3. **Context-Specific Upload**: Photos only uploadable during editing, not viewing
4. **Backward Compatibility**: Existing recipes with HTTP URLs continue working

---

## Source URL and Tips Implementation

### Current Implementation (Completed)
- **Source URL Storage**: Captured only during URL-based recipe extraction
- **Tips & Notes**: Generated by AI and editable in all contexts (manual, photo, URL, Share Extension)
- **Recipe Model Extension**: Added sourceURL and tips fields with backward compatibility

### Recipe Model Updates (Recipe.swift)
```swift
struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var ingredients: [String]
    var steps: [String]
    var imageURL: String?
    var category: String?
    var servings: Int
    var sourceURL: String?      // NEW: Only set during URL extraction
    var tips: [String]          // NEW: AI-generated cooking tips
    let createdAt: Date
    var updatedAt: Date
}
```

### AI Prompt Enhancements (OpenAIService.swift)
- **Tips Generation**: Enhanced prompts to generate 2-5 practical cooking tips
- **Source URL Handling**: Only captured when processing URLs, not manual/photo entries
- **JSON Response Format**: Updated to include tips array in all AI responses

### UI Implementation Patterns

#### Recipe Detail View (RecipeDetailView.swift)
```swift
private var tipsSection: some View {
    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
        if !viewModel.recipe.tips.isEmpty {
            Text("Tips & Notes")
                .font(Typography.Headline.regular)
                .foregroundColor(Theme.Colors.text)

            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                ForEach(viewModel.recipe.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: Theme.Spacing.small) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.top, 2)

                        Text(tip)
                            .font(Typography.Body.regular)
                            .foregroundColor(Theme.Colors.text)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }
}
```

#### Source URL Display Pattern
```swift
private var sourceURLSection: some View {
    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
        if let sourceURL = viewModel.recipe.sourceURL, !sourceURL.isEmpty {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "link")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.accent)

                if let url = URL(string: sourceURL) {
                    Link("Original recipe", destination: url)
                        .font(Typography.Body.semibold)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
        }
    }
}
```

---

## Share Extension Tips Integration

### Current Implementation (Completed)
- **Complete Tips UI**: Tips display, editing, and persistence in Share Extension
- **Emoji Icons**: 💡 lightbulb emoji for visual consistency across platforms
- **Editable Text Views**: Users can modify AI-generated tips before saving
- **App Groups Sync**: Tips properly synchronized between extension and main app

### Technical Implementation (ShareViewController.swift)

#### Tips UI Components
```swift
// Properties
private var tipsStackView: UIStackView!
private var tipsLabel: UILabel!

// Initialization in setupScrollView()
tipsLabel = UILabel()
tipsLabel.text = "Tips & Notes"
tipsLabel.font = UIFont.boldSystemFont(ofSize: 18)
tipsLabel.textColor = UIColor.label
tipsLabel.translatesAutoresizingMaskIntoConstraints = false

tipsStackView = UIStackView()
tipsStackView.axis = .vertical
tipsStackView.spacing = 12
tipsStackView.translatesAutoresizingMaskIntoConstraints = false
```

#### Tips Row Creation Pattern
```swift
private func addTipRow(text: String) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false

    let iconLabel = UILabel()
    iconLabel.text = "💡"
    iconLabel.font = UIFont.systemFont(ofSize: 18)
    iconLabel.textAlignment = .center
    iconLabel.translatesAutoresizingMaskIntoConstraints = false

    let textView = UITextView()
    textView.text = text
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.textColor = UIColor.label
    textView.backgroundColor = UIColor.clear
    textView.isScrollEnabled = false
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = UIEdgeInsets.zero
    textView.translatesAutoresizingMaskIntoConstraints = false

    // Add to container and stack view...
}
```

---

## Category System Implementation

### Data Models

#### Category Model (Category.swift)
**Location**: `/TastoryAI v.1/Models/Category.swift`

**Fields**:
- `id: UUID` - Unique identifier
- `name: String` - Display name (1-32 characters)
- `slug: String` - URL-safe identifier generated from name
- `isSystem: Bool` - True for "New recipes" system category
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last modification timestamp

**System Category**:
- Fixed UUID: `00000000-0000-0000-0000-000000000001`
- Name: "New recipes"
- Cannot be deleted or renamed
- Auto-assigned to new recipes

#### Recipe Model Extensions (Recipe.swift)
**New Fields**:
- `categoryIds: [UUID]` - All assigned categories
- `primaryCategoryId: UUID?` - Primary category (must be in categoryIds)
- `category: String?` - Legacy field (maintained for backward compatibility)

**Helper Methods**:
- `hasCategory(_ categoryId: UUID) -> Bool`
- `addCategory(_ categoryId: UUID, asPrimary: Bool = false)`
- `removeCategory(_ categoryId: UUID)`
- `setPrimaryCategory(_ categoryId: UUID)`
- `getAdditionalCategoryIds() -> [UUID]`

### Services

#### CategoryManager (CategoryManager.swift)
**Pattern**: Singleton with `CategoryManager.shared`

**Storage**: JSON file in App Groups for Share Extension sync

**CRUD Operations**:
- `addCategory(_ name: String) throws -> Category`
- `updateCategory(_ category: Category) throws`
- `deleteCategory(_ id: UUID) throws`

**Query Methods**:
- `getCategory(withId: UUID) -> Category?`
- `getCategoryByName(_ name: String) -> Category?`
- `getNewRecipesCategory() -> Category`

**Validation**:
- Name length: 1-32 characters
- Case/diacritic-insensitive uniqueness
- System category protection

**Sorting**:
- "New recipes" always first
- Other categories alphabetically (locale-aware)

#### RecipeStorageManager Enhancements
**Category Filtering**:
```swift
func getRecipesForCategory(_ categoryId: UUID) -> [Recipe] {
    return recipes.filter { $0.hasCategory(categoryId) }
}
```

**Recipe Reassignment**:
- When category deleted, reassign recipes to "New recipes"
- Primary category auto-reassignment
- Maintain data integrity

### UI Components

#### CategoriesView.swift
**Features**:
- Category list with recipe counts
- "New recipes" displayed first
- "+ New Category" button
- Navigation to FilteredRecipesView

#### FilteredRecipesView.swift
**Features**:
- Shows recipes for specific category
- Reuses RecipeGridView component
- Empty state for categories with 0 recipes
- Multi-category support (same recipe appears in all assigned categories)

#### CategorySheets.swift
**Components**:
1. **NewCategorySheet**: Create new category with validation
2. **AddCategorySheet**: Add category to recipe from list
3. **EditCategorySheet**: Rename existing category
4. **BulkCategorySheets**: Bulk operations (AddCategoryToBulkSheet, SetPrimaryCategorySheet, RemoveFromCategorySheet, MoveToCategorySheet)

#### Recipe Editing Integration
**Files**:
- EditRecipeView.swift (main app)
- RecipeEditingView.swift (Share Extension)

**Features**:
- Primary category dropdown (Menu-based)
- Additional categories section with remove buttons
- Prevents duplicate assignments
- Category creation overlay

### Search Integration

**Implementation** (HomeView.swift):
- 250ms debounced search
- Searches: title, ingredients, steps, **category names**
- Case/diacritic-insensitive matching
- AND logic across search tokens

**Code Pattern**:
```swift
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
].joined(separator: " ")
```

### Bulk Operations

**HomeView Bulk Actions**:
- Delete selected recipes
- Add category to selected recipes
- Set primary category for selected recipes

**FilteredRecipesView Bulk Actions**:
- Remove from current category
- Add category to selected recipes
- Move to different category

**Implementation Pattern**:
- Apple Photos-style multi-select mode
- Checkmark overlay on recipe cards
- Set<UUID> for selected recipe tracking
- Confirmation alerts for destructive operations

### Delete Rules

When category deleted:
```swift
for recipe in affectedRecipes {
    if recipe.primaryCategoryId == deletingCategoryId {
        recipe.primaryCategoryId = Category.newRecipesCategoryId
        recipe.categoryIds = [Category.newRecipesCategoryId] +
                            recipe.categoryIds.filter { $0 != deletingCategoryId }
    } else {
        recipe.categoryIds.removeAll { $0 == deletingCategoryId }
    }
}
```

### Architecture Principles

1. **Single Source of Truth**: One category list in CategoryManager
2. **Data Consistency**: Primary category ALWAYS in categoryIds array
3. **Multi-Category Support**: Recipes appear in ALL assigned categories
4. **System Category Protection**: "New recipes" cannot be deleted
5. **Validation**: Case/diacritic-insensitive uniqueness checks

---

## Common Pitfalls and Solutions

### Share Extension Compatibility Issues
**Problem**: Recipe model changes break Share Extension compilation

**Solution**: Always update ExtractedRecipeData and all Recipe initialization calls when adding new fields

**Pattern**: Use default values for new fields to maintain backward compatibility

### Photo Storage Over-engineering
**Problem**: Creating separate photo storage managers increases complexity

**Solution**: Use data URLs in existing imageURL field - AsyncImage handles both HTTP URLs and data URLs seamlessly

**Key Insight**: Single field architecture is simpler and more maintainable

### Tips UI Consistency
**Problem**: Different tip display patterns between main app and Share Extension

**Solution**: Use consistent emoji icons (💡) and text styling across all contexts

**Pattern**: Shared visual language improves user experience

### Build Error Prevention
**Critical**: When adding new Recipe fields, always check and update:
1. Recipe initializers throughout codebase
2. ExtractedRecipeData struct in RecipeExtractionService
3. All Recipe creation calls in Share Extension
4. JSON parsing logic for backward compatibility

### Data Flow Architecture
**Key Pattern**:
- Source URLs only captured during URL-based extraction (not manual/photo)
- Tips generated and editable in all contexts (manual, photo, URL, Share Extension)
- Photo uploads only available in editing contexts (not detail view)
- Maintain single source of truth for recipe data

---

## References

This file is referenced by:
- [CLAUDE.md](CLAUDE.md) - Main development guide
- Development plans and todo files
- Feature implementation documentation

For architecture overview and development workflow, see [CLAUDE.md](CLAUDE.md).
