# Tastory AI - UX Design System

## Purpose

This document defines the complete UX design system for Tastory AI across the entire application and Share Extension. Use this as the source of truth for all UI updates.

**Usage:** When implementing, reference this document with: *"Based on instructions from newUX.md, update [component/screen]"*

---

## Design System

### Color Palette

Create/update `TastoryDesign.swift` with these colors:

| Token | Hex | UIColor/Color | Usage |
|-------|-----|---------------|-------|
| `primaryGreen` | `#1B6D3F` | Primary buttons, active states, accents, checkmarks |
| `lightGreenBg` | `#E8F5EF` | Success backgrounds, info boxes, icon containers |
| `background` | `#F5F5F5` | Main screen backgrounds |
| `cardBackground` | `#FFFFFF` | Cards, input fields, list items |
| `primaryText` | `#1A1A1A` | Headings, primary content |
| `secondaryText` | `#6B7280` | Descriptions, placeholders, captions |
| `tertiaryText` | `#9CA3AF` | Hints, disabled text |
| `border` | `#E5E7EB` | Card borders, dividers, input borders |
| `secondaryButtonBg` | `#E8E8E8` | Secondary/cancel buttons |
| `errorRed` | `#DC2626` | Error states, destructive actions |
| `warningOrange` | `#F59E0B` | Warning states |

### Typography

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `largeTitle` | 32pt | Bold (700) | 1.2 | Hero headings, onboarding |
| `title` | 22pt | Semibold (600) | 1.3 | Screen titles, section headers |
| `headline` | 17pt | Semibold (600) | 1.4 | Card titles, important labels |
| `body` | 16pt | Medium (500) | 1.5 | Body text, descriptions |
| `callout` | 14pt | Medium (500) | 1.4 | Secondary info, badges |
| `caption` | 12pt | Medium (500) | 1.3 | Timestamps, counts, hints |

### Spacing

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 4pt | Tight spacing, inline elements |
| `xs` | 8pt | Icon-text gaps, list item internal |
| `sm` | 12pt | Between list items, section padding |
| `md` | 16pt | Card padding, standard gaps |
| `lg` | 20pt | Section spacing |
| `xl` | 24pt | Major section breaks |
| `xxl` | 32pt | Screen edge padding on larger screens |

### Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `small` | 8pt | Small badges, tags |
| `medium` | 12pt | Input fields, small cards |
| `large` | 16pt | Cards, containers |
| `xLarge` | 24pt | Buttons, bottom sheets |
| `full` | 9999pt | Circular elements, pills |

### Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `none` | - | Flat elements |
| `small` | 0 1px 2px rgba(0,0,0,0.05) | Subtle elevation |
| `medium` | 0 2px 4px rgba(0,0,0,0.08) | Cards, floating elements |

### Header/Navigation Pattern

Main screens (HomeView, CategoriesView) use a **custom header approach** for consistent styling:

```swift
// Custom header structure
VStack(spacing: 0) {
    // Header
    HStack {
        Text("Screen Title")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(TastoryColors.primaryText)

        Spacer()

        // Action button with gray glass style
        Button("Action") { }
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(TastoryColors.primaryGreen)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)  // or .circle for icon buttons
            .tint(.gray)
    }
    .padding(.horizontal, TastorySpacing.md)
    .padding(.top, TastorySpacing.sm)
    .padding(.bottom, TastorySpacing.md)

    // Custom search bar (if needed)
    // Content
}
.navigationBarHidden(true)
```

**Key principles:**
- **Title**: 28pt bold, left-aligned
- **Action buttons**: Gray glass background (`.buttonStyle(.bordered)` + `.tint(.gray)`)
- **Button shapes**: `.capsule` for text, `.circle` for icons
- **Text color**: Green for action buttons
- **Sub-screens**: Keep navigation bar for back button, apply same button styling to toolbar items

---

## Reusable Components

### IMPORTANT: Code Reuse Principles

1. **Single Source of Truth**: Each component defined ONCE in a shared location
2. **SwiftUI Components**: Create in `TastoryAI v.1/Views/Components/` folder
3. **UIKit Components**: Create helper methods in Share Extension that mirror SwiftUI components
4. **Naming Convention**: `Tastory[ComponentName]` for new components

### Component Definitions

#### 1. TastoryButton

**File:** `Views/Components/TastoryButton.swift`

```swift
enum TastoryButtonStyle {
    case primary    // Green background, white text
    case secondary  // Gray background, dark text
    case text       // No background, green text
    case destructive // Red text
}

struct TastoryButton: View {
    let title: String
    let style: TastoryButtonStyle
    let icon: String?  // SF Symbol name
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
}
```

**Specs:**
- Height: 56pt (primary/secondary), 48pt (text)
- Corner radius: 24pt
- Font: 17pt semibold
- Full width by default
- Icon on left if provided (8pt gap)
- Loading: Show spinner, disable interaction
- Disabled: 50% opacity

#### 2. TastoryCard

**File:** `Views/Components/TastoryCard.swift`

```swift
struct TastoryCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    var showShadow: Bool = true
}
```

**Specs:**
- Background: white
- Corner radius: 16pt
- Padding: 16pt default
- Shadow: medium (when showShadow = true)
- No border by default

#### 3. TastoryListItem

**File:** `Views/Components/TastoryListItem.swift`

```swift
struct TastoryListItem: View {
    let title: String
    var subtitle: String?
    var leadingIcon: String?      // SF Symbol
    var leadingIconBgColor: Color? // Circle background
    var trailingText: String?
    var showChevron: Bool = true
    var action: (() -> Void)?
}
```

**Specs:**
- Height: 56-72pt (based on content)
- Background: white card
- Icon container: 40x40pt, 12pt radius, light background
- Title: 16pt medium, primary text
- Subtitle: 14pt medium, secondary text
- Trailing: secondary text or chevron
- Spacing: 12pt between elements

#### 4. TastorySectionHeader

**File:** `Views/Components/TastorySectionHeader.swift`

```swift
struct TastorySectionHeader: View {
    let title: String
    var count: Int?
    var action: (() -> Void)?
    var actionIcon: String?
}
```

**Specs:**
- Title: 17pt semibold, primary text
- Count: 14pt medium, secondary text, in parentheses
- Action button: right-aligned, green text/icon
- Bottom padding: 8pt

#### 5. TastoryTextField

**File:** `Views/Components/TastoryTextField.swift`

```swift
struct TastoryTextField: View {
    @Binding var text: String
    let placeholder: String
    var leadingIcon: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
}
```

**Specs:**
- Height: 48pt
- Background: #F3F4F6 (light gray)
- Corner radius: 12pt
- Padding: 16pt horizontal
- Icon: left-aligned, 16pt, secondary text color
- Placeholder: secondary text color
- Text: primary text color, 16pt medium

#### 6. TastoryEmptyState

**File:** `Views/Components/TastoryEmptyState.swift`

```swift
struct TastoryEmptyState: View {
    let icon: String           // SF Symbol
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?
}
```

**Specs:**
- Icon: 60pt, in light green circle (100x100pt)
- Title: 22pt semibold, primary text
- Message: 16pt medium, secondary text, centered
- Button: primary style if provided
- Vertical spacing: 16pt between elements

#### 7. TastoryLoadingView

**File:** `Views/Components/TastoryLoadingView.swift`

```swift
struct TastoryLoadingView: View {
    let title: String
    var message: String?
    var showProgress: Bool = false
    var progress: Double = 0
}
```

**Specs:**
- Centered on screen
- Icon: 100x100pt light green circle with pulsing animation
- Inner icon: 40pt SF Symbol in green
- Title: 22pt semibold
- Message: 16pt medium, secondary text
- Animated dots "..." appended to message
- Progress bar: 4pt height, green fill, if showProgress = true

#### 8. TastoryBadge

**File:** `Views/Components/TastoryBadge.swift`

```swift
struct TastoryBadge: View {
    let text: String
    var style: BadgeStyle = .default

    enum BadgeStyle {
        case `default`  // Light gray bg, dark text
        case primary    // Light green bg, green text
        case count      // Green bg, white text (for numbers)
    }
}
```

**Specs:**
- Padding: 4pt vertical, 8pt horizontal
- Corner radius: 8pt (or full for count)
- Font: 12pt medium

---

## Screen-by-Screen Updates

### 1. MainTabView

**File:** `Views/MainTabView.swift`

**Changes:**
- [ ] Tab bar: Keep default iOS style but use `primaryGreen` for active state
- [ ] Tab icons: book.fill, folder.fill, person.fill (unchanged)

---

### 2. HomeView (Recipes Tab)

**File:** `Views/HomeView.swift`

**Changes:**
- [ ] Background: `background` (#F5F5F5)
- [ ] Search bar: Use `TastoryTextField` with magnifyingglass icon
- [ ] Recipe grid: 12pt gap between cards
- [ ] Empty state: Use `TastoryEmptyState` component
- [ ] FAB (Add Recipe): Green circle, white plus icon, medium shadow
- [ ] Bulk action toolbar: White card at bottom, 3 `TastoryButton` (text style)

**Bulk Action Buttons:**
- Delete: `TastoryButton(style: .destructive, icon: "trash")`
- Add Category: `TastoryButton(style: .text, icon: "folder.badge.plus")`
- Set Primary: `TastoryButton(style: .text, icon: "star")`

---

### 3. RecipeCardView

**File:** `Views/RecipeCardView.swift`

**Changes:**
- [ ] Container: `TastoryCard` with shadow
- [ ] Image: 12pt top corner radius only
- [ ] Title: 16pt semibold, primary text, max 2 lines
- [ ] Category tag: `TastoryBadge(style: .default)` with tag.fill icon
- [ ] Servings: caption style, secondary text
- [ ] Selection checkmark: Green circle with white checkmark

---

### 4. RecipeDetailView

**File:** `Views/RecipeDetailView.swift`

**Changes:**
- [ ] Background: `background`
- [ ] Hero image: Full width, 250pt, no corner radius at top
- [ ] Title section: Inside `TastoryCard`
  - Title: 22pt semibold
  - Category: `TastoryBadge(style: .primary)`
- [ ] Servings control: Inside `TastoryCard`
  - Minus/Plus buttons: 40x40pt, light gray bg, 12pt radius
  - Count: 20pt semibold, centered
- [ ] Ingredients section: Inside `TastoryCard`
  - Header: `TastorySectionHeader` with count
  - Each ingredient: Green bullet (8pt circle) + 16pt text
  - Checkbox: Green when checked, gray border when unchecked
  - Strikethrough: secondary text color when checked
- [ ] Instructions section: Inside `TastoryCard`
  - Header: `TastorySectionHeader`
  - Step number: Green badge (28x28pt), white text, 8pt radius
  - Step text: 16pt medium
- [ ] Tips section: `TastoryCard` with `lightGreenBg` background
  - Lightbulb icon in green
  - Tips text: 16pt medium
- [ ] Source URL: `TastoryListItem` style with link icon

---

### 5. AddRecipeView

**File:** `Views/AddRecipeView.swift`

**Changes:**
- [ ] Background: `background`
- [ ] Title: 22pt semibold, "Add a Recipe"
- [ ] Subtitle: 16pt medium, secondary text
- [ ] Option cards: Use `TastoryListItem` for each option
  - From URL: link icon in light green circle
  - From Photo: camera icon in light green circle
  - Manual: square.and.pencil icon in light green circle
- [ ] Each option shows chevron on right

---

### 6. URLRecipeEntryView (inside AddRecipeView)

**File:** `Views/AddRecipeView.swift`

**Changes:**
- [ ] URL input: `TastoryTextField` with link icon
- [ ] Paste button: `TastoryButton(style: .text)` if clipboard has URL
- [ ] Import button: `TastoryButton(style: .primary)` - "Import Recipe"
- [ ] Loading state: `TastoryLoadingView` with "Analyzing URL..."
- [ ] Error: Red text below input field

---

### 7. PhotoRecipeEntryView (inside AddRecipeView)

**File:** `Views/AddRecipeView.swift`

**Changes:**
- [ ] Photo preview: `TastoryCard` containing image (200pt max height)
- [ ] Select/Change Photo: `TastoryButton(style: .secondary)`
- [ ] Extract button: `TastoryButton(style: .primary)` - "Extract Recipe"
- [ ] Processing: `TastoryLoadingView` with "Extracting text..."
- [ ] Extracted text: `TastoryCard` with scrollable text

---

### 8. RecipeEditingView

**File:** `Views/RecipeEditingView.swift`

**Changes:**
- [ ] Background: `background`
- [ ] Photo section: `TastoryCard`
  - Image: 100x100pt, 12pt radius
  - Photo picker overlay on tap
- [ ] Title: Large `TastoryTextField` (24pt font override)
- [ ] Categories section: `TastoryCard`
  - Primary: Dropdown menu styled as `TastoryListItem`
  - Additional: List of `TastoryBadge` with X remove button
  - Add button: `TastoryButton(style: .text)` - "+ Add Category"
- [ ] Ingredients section: `TastoryCard`
  - Header: `TastorySectionHeader` with "+ Add" action
  - Each: `TastoryTextField` with green bullet prefix
  - Delete: Swipe or X button
- [ ] Instructions section: `TastoryCard`
  - Header: `TastorySectionHeader` with "+ Add" action
  - Each: Green number badge + `TastoryTextField`
- [ ] Tips section: `TastoryCard` with `lightGreenBg`
  - Header with "+ Add" action
  - Each: Lightbulb emoji + `TastoryTextField`
- [ ] Save button: `TastoryButton(style: .primary)` - "Save Recipe"
- [ ] Cancel: `TastoryButton(style: .text)` in nav bar

---

### 9. EditRecipeView

**File:** `Views/EditRecipeView.swift`

**Changes:**
- [ ] Apply same patterns as RecipeEditingView
- [ ] Consider consolidating with RecipeEditingView to reduce duplication

---

### 10. CategoriesView

**File:** `Views/CategoriesView.swift`

**Changes:**
- [ ] Background: `background`
- [ ] Title: "Categories" (standard nav title)
- [ ] Add button: Green plus icon in nav bar
- [ ] Category list: Each row is `TastoryListItem`
  - Icon: folder.fill in light green circle
  - Title: Category name
  - Trailing: Recipe count in secondary text
  - Chevron: Show navigation indicator
- [ ] "New recipes" row: Same style, no swipe actions
- [ ] Swipe actions:
  - Edit: Blue background, pencil icon
  - Delete: Red background, trash icon
- [ ] Empty state: `TastoryEmptyState` with folder icon

---

### 11. FilteredRecipesView

**File:** `Views/FilteredRecipesView.swift`

**Changes:**
- [ ] Background: `background`
- [ ] Title: Category name (nav title)
- [ ] Recipe grid: Same as HomeView
- [ ] Empty state: `TastoryEmptyState` - "No recipes in this category"
- [ ] Bulk actions: Same as HomeView but with category-specific actions:
  - Remove from Category: red folder.badge.minus
  - Add to Category: blue folder.badge.plus
  - Move to Category: blue folder.fill.badge.gearshape

---

### 12. CategorySheets

**File:** `Views/CategorySheets.swift`

**NewCategorySheet Changes:**
- [ ] Background: white
- [ ] Title: 22pt semibold - "New Category"
- [ ] Input: `TastoryTextField` with auto-focus
- [ ] Error: Red text, 14pt, below input
- [ ] Hint: Caption style, secondary text
- [ ] Cancel: `TastoryButton(style: .text)` in nav bar
- [ ] Save: `TastoryButton(style: .primary)` - "Create"

**EditCategorySheet Changes:**
- [ ] Same structure as NewCategorySheet
- [ ] Title: "Edit Category"
- [ ] Save button: "Save"

**AddCategorySheet Changes:**
- [ ] Background: `background`
- [ ] Title: "Add to Category"
- [ ] List: `TastoryListItem` for each category
  - Icon: folder.fill in light green circle
  - Trailing: plus.circle in green
- [ ] Create new: `TastoryButton(style: .text)` at bottom - "+ Create New Category"

---

### 13. BulkCategorySheets

**File:** `Views/BulkCategorySheets.swift`

**Apply to all sheets:**
- [ ] Background: white or `background`
- [ ] Headers: 22pt semibold
- [ ] Category lists: `TastoryListItem` style
- [ ] Action buttons: `TastoryButton` appropriate style
- [ ] Confirmation alerts: System style (unchanged)

---

### 14. ProfileView

**File:** `Views/MainTabView.swift` (ProfileView is embedded)

**Changes:**
- [ ] Background: `background`
- [ ] App header: `TastoryCard`
  - App icon: 60x60pt, 12pt radius
  - App name: 20pt semibold
  - Recipe count: 14pt medium, secondary text
- [ ] Settings sections: Group of `TastoryListItem`
  - Preferences header: `TastorySectionHeader`
  - Unit System: `TastoryListItem` with dropdown trailing
  - Default Servings: `TastoryListItem` with stepper trailing
- [ ] Development section: Same pattern
- [ ] Support section: Same pattern

---

### 15. DebugMenuView

**File:** `Views/DebugMenuView.swift`

**Changes:**
- [ ] Background: `background`
- [ ] Section headers: `TastorySectionHeader`
- [ ] Menu items: `TastoryListItem` for each option
- [ ] System info: Caption style at bottom

---

## Share Extension

### 16. ShareViewController

**File:** `TastoryShare/ShareViewController.swift`

**CRITICAL:** This is UIKit, not SwiftUI. Create UIKit equivalents of components.

#### UIKit Helper Methods

Add to ShareViewController:

```swift
// MARK: - Tastory Design Constants
private enum TastoryColors {
    static let primaryGreen = UIColor(red: 27/255, green: 109/255, blue: 63/255, alpha: 1)
    static let lightGreenBg = UIColor(red: 232/255, green: 245/255, blue: 239/255, alpha: 1)
    static let background = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    static let cardBackground = UIColor.white
    static let primaryText = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
    static let secondaryText = UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1)
    static let border = UIColor(red: 229/255, green: 231/255, blue: 235/255, alpha: 1)
    static let secondaryButtonBg = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
}

private func createCard() -> UIView { ... }
private func createPrimaryButton(title: String) -> UIButton { ... }
private func createSecondaryButton(title: String) -> UIButton { ... }
private func createSectionHeader(title: String, count: Int?) -> UIView { ... }
```

#### Loading Screen Redesign

**Current:** Title + status + progress bar

**New Design:**
- [ ] Background: `background` (#F5F5F5)
- [ ] Centered container:
  - Icon circle: 100x100pt, `lightGreenBg`, centered
  - Icon: fork.knife or doc.text.magnifyingglass, 40pt, `primaryGreen`
  - Pulse animation on circle (scale 1.0 → 1.05, 1s, repeat)
  - Title: "Importing Recipe" - 22pt semibold
  - Status: "Analyzing content..." - 16pt medium, secondary text
  - Animated dots: cycle "", ".", "..", "..." every 500ms
- [ ] Cancel button at bottom: secondary style, full width

#### Recipe Editing Screen Redesign

- [ ] Background: `background`
- [ ] ScrollView with content cards

**Header Card:**
- [ ] White card, 16pt padding
- [ ] Image: 100x100pt, 12pt radius, left-aligned
- [ ] Title field: 22pt semibold, right of image
- [ ] Light shadow

**Ingredients Card:**
- [ ] White card
- [ ] Section header: "Ingredients" + count
- [ ] Each ingredient:
  - Green bullet (8pt filled circle)
  - UITextField, 16pt
  - 12pt vertical spacing
- [ ] Add button at bottom: "+ Add Ingredient"

**Instructions Card:**
- [ ] White card
- [ ] Section header: "Instructions"
- [ ] Each step:
  - Green number badge (28x28pt, 8pt radius)
  - UITextView, 16pt
  - 16pt vertical spacing
- [ ] Add button at bottom: "+ Add Step"

**Tips Card:**
- [ ] `lightGreenBg` background card
- [ ] Section header: "Tips & Notes"
- [ ] Each tip:
  - Lightbulb emoji or icon
  - UITextView, 16pt
- [ ] Add button: "+ Add Tip"

**Action Buttons:**
- [ ] Save: Primary button, "Save Recipe", 56pt height
- [ ] Cancel: Secondary button, "Cancel", 48pt height
- [ ] 12pt gap between buttons
- [ ] 20pt bottom padding

#### Transition Animation

```swift
private func transitionToRecipeView() {
    UIView.animate(withDuration: 0.3, animations: {
        self.loadingContainer.alpha = 0
        self.loadingContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }) { _ in
        self.loadingContainer.isHidden = true
        self.recipeScrollView.alpha = 0
        self.recipeScrollView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.recipeScrollView.alpha = 1
        }
    }
}
```

---

## Implementation Checklist

### Phase 1: Design System Foundation
- [ ] Create `TastoryDesign.swift` with colors, spacing, radius, shadows
- [ ] Create `Views/Components/` folder
- [ ] Implement `TastoryButton.swift`
- [ ] Implement `TastoryCard.swift`
- [ ] Implement `TastoryListItem.swift`
- [ ] Implement `TastorySectionHeader.swift`
- [ ] Implement `TastoryTextField.swift`
- [ ] Implement `TastoryEmptyState.swift`
- [ ] Implement `TastoryLoadingView.swift`
- [ ] Implement `TastoryBadge.swift`

### Phase 2: Core Views
- [ ] Update HomeView
- [ ] Update RecipeCardView
- [ ] Update RecipeDetailView
- [ ] Update CategoriesView

### Phase 3: Recipe Creation/Editing
- [ ] Update AddRecipeView
- [ ] Update RecipeEditingView
- [ ] Update EditRecipeView (or consolidate)

### Phase 4: Category Management
- [ ] Update FilteredRecipesView
- [ ] Update CategorySheets
- [ ] Update BulkCategorySheets

### Phase 5: Settings & Profile
- [ ] Update ProfileView
- [ ] Update DebugMenuView

### Phase 6: Share Extension
- [ ] Add UIKit design constants
- [ ] Create UIKit helper methods
- [ ] Redesign loading screen with animation
- [ ] Redesign recipe editing screen
- [ ] Add transition animations
- [ ] Test full flow

### Phase 7: Polish & Testing
- [ ] Test all screens on iPhone 16
- [ ] Verify consistent styling
- [ ] Check dark mode compatibility (if supported)
- [ ] Verify accessibility
- [ ] Final visual review

---

## Files to Modify

### New Files to Create
1. `TastoryAI v.1/Resources/TastoryDesign.swift`
2. `TastoryAI v.1/Views/Components/TastoryButton.swift`
3. `TastoryAI v.1/Views/Components/TastoryCard.swift`
4. `TastoryAI v.1/Views/Components/TastoryListItem.swift`
5. `TastoryAI v.1/Views/Components/TastorySectionHeader.swift`
6. `TastoryAI v.1/Views/Components/TastoryTextField.swift`
7. `TastoryAI v.1/Views/Components/TastoryEmptyState.swift`
8. `TastoryAI v.1/Views/Components/TastoryLoadingView.swift`
9. `TastoryAI v.1/Views/Components/TastoryBadge.swift`

### Files to Modify
1. `TastoryAI v.1/Views/MainTabView.swift` (ProfileView)
2. `TastoryAI v.1/Views/HomeView.swift`
3. `TastoryAI v.1/Views/RecipeCardView.swift`
4. `TastoryAI v.1/Views/RecipeDetailView.swift`
5. `TastoryAI v.1/Views/AddRecipeView.swift`
6. `TastoryAI v.1/Views/RecipeEditingView.swift`
7. `TastoryAI v.1/Views/EditRecipeView.swift`
8. `TastoryAI v.1/Views/CategoriesView.swift`
9. `TastoryAI v.1/Views/FilteredRecipesView.swift`
10. `TastoryAI v.1/Views/CategorySheets.swift`
11. `TastoryAI v.1/Views/BulkCategorySheets.swift`
12. `TastoryAI v.1/Views/RecipeGridView.swift`
13. `TastoryAI v.1/Views/DebugMenuView.swift`
14. `TastoryShare/ShareViewController.swift`

---

## Key Principles

1. **Consistency**: Same component = same code = same appearance everywhere
2. **Reusability**: Create once, use many times
3. **No Duplication**: If it exists, reuse it; don't recreate
4. **Clear Hierarchy**: Design tokens → Components → Screens
5. **UIKit Parity**: Share Extension mirrors SwiftUI components in UIKit

---

## Success Criteria

- [ ] All screens use `background` (#F5F5F5) as base color
- [ ] All cards use white background with medium shadow
- [ ] All primary actions use green (#1B6D3F) buttons
- [ ] All secondary actions use gray (#E8E8E8) buttons
- [ ] Typography is consistent across all screens
- [ ] Spacing follows the defined system
- [ ] Components are reused, not duplicated
- [ ] Share Extension matches main app aesthetic
- [ ] Loading states have animations
- [ ] Transitions are smooth
