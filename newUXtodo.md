# Tastory AI - UX Redesign Todo

**Reference Document:** [newUX.md](newUX.md)

---

## Phase 1: Design System Foundation ✅ COMPLETED

### Design Tokens
- [x] Create `TastoryAI v.1/Resources/TastoryDesign.swift` with colors, spacing, radius, shadows

### Reusable Components
- [x] Create `Views/Components/` folder
- [x] Create `TastoryButton.swift` - Primary, secondary, text, destructive styles
- [x] Create `TastoryCard.swift` - White card with shadow
- [x] Create `TastoryListItem.swift` - List row with icon, title, subtitle, chevron
- [x] Create `TastorySectionHeader.swift` - Section title with optional count and action
- [x] Create `TastoryTextField.swift` - Styled input field
- [x] Create `TastoryEmptyState.swift` - Empty state with icon, title, message
- [x] Create `TastoryLoadingView.swift` - Loading indicator with animation
- [x] Create `TastoryBadge.swift` - Tag/badge component

---

## Phase 2: Core Views

### HomeView
- [ ] Update background to `background` (#F5F5F5)
- [ ] Replace search bar with `TastoryTextField`
- [ ] Update empty state with `TastoryEmptyState`
- [ ] Style FAB (Add Recipe) with green circle
- [ ] Update bulk action toolbar with `TastoryButton` components

### RecipeCardView
- [ ] Wrap in `TastoryCard`
- [ ] Update image corner radius (top only)
- [ ] Style title with 16pt semibold
- [ ] Replace category tag with `TastoryBadge`
- [ ] Update selection checkmark (green circle, white check)

### RecipeDetailView
- [ ] Update background
- [ ] Wrap title section in `TastoryCard`
- [ ] Wrap servings control in `TastoryCard`
- [ ] Update ingredients section with `TastoryCard` and green bullets
- [ ] Update instructions section with `TastoryCard` and green number badges
- [ ] Style tips section with light green background card
- [ ] Update source URL with `TastoryListItem` style

### CategoriesView
- [ ] Update background
- [ ] Replace category rows with `TastoryListItem`
- [ ] Update empty state with `TastoryEmptyState`
- [ ] Style add button (green plus icon)

---

## Phase 3: Recipe Creation/Editing

### AddRecipeView
- [ ] Update background
- [ ] Style title and subtitle
- [ ] Replace option cards with `TastoryListItem` components
- [ ] Add icons in light green circles

### URLRecipeEntryView
- [ ] Replace URL input with `TastoryTextField`
- [ ] Style paste button with `TastoryButton(style: .text)`
- [ ] Style import button with `TastoryButton(style: .primary)`
- [ ] Add `TastoryLoadingView` for processing state

### PhotoRecipeEntryView
- [ ] Wrap photo preview in `TastoryCard`
- [ ] Style buttons with `TastoryButton`
- [ ] Add `TastoryLoadingView` for processing state

### RecipeEditingView
- [ ] Update background
- [ ] Wrap sections in `TastoryCard` components
- [ ] Style photo picker section
- [ ] Update title field styling
- [ ] Style category dropdowns and badges
- [ ] Update ingredients with green bullets
- [ ] Update instructions with green number badges
- [ ] Style tips section with light green background
- [ ] Replace save/cancel with `TastoryButton`

### EditRecipeView
- [ ] Apply same patterns as RecipeEditingView
- [ ] Consider consolidating duplicate code

---

## Phase 4: Category Management

### FilteredRecipesView
- [ ] Update background
- [ ] Update empty state with `TastoryEmptyState`
- [ ] Style bulk action toolbar

### CategorySheets
- [ ] Update NewCategorySheet
  - [ ] Style title (22pt semibold)
  - [ ] Replace input with `TastoryTextField`
  - [ ] Style error messages
  - [ ] Style buttons with `TastoryButton`
- [ ] Update EditCategorySheet (same as above)
- [ ] Update AddCategorySheet
  - [ ] Replace list items with `TastoryListItem`
  - [ ] Style "Create New" button

### BulkCategorySheets
- [ ] Update AddCategoryToBulkSheet with `TastoryListItem`
- [ ] Update RemoveFromCategorySheet
- [ ] Update SetPrimaryCategorySheet
- [ ] Update MoveToCategorySheet

---

## Phase 5: Settings & Profile

### ProfileView (in MainTabView)
- [ ] Update background
- [ ] Wrap app header in `TastoryCard`
- [ ] Replace settings rows with `TastoryListItem`
- [ ] Add `TastorySectionHeader` for sections

### DebugMenuView
- [ ] Update background
- [ ] Replace menu items with `TastoryListItem`
- [ ] Add `TastorySectionHeader` for sections

---

## Phase 6: Share Extension

### ShareViewController (UIKit)
- [ ] Add TastoryColors constants
- [ ] Add TastorySpacing constants
- [ ] Add TastoryRadius constants
- [ ] Create helper methods:
  - [ ] `createCard() -> UIView`
  - [ ] `createPrimaryButton(title:) -> UIButton`
  - [ ] `createSecondaryButton(title:) -> UIButton`
  - [ ] `createSectionHeader(title:count:) -> UIView`

### Loading Screen
- [ ] Update background to #F5F5F5
- [ ] Create centered icon container (100x100, light green)
- [ ] Add icon (fork.knife, 40pt, green)
- [ ] Add pulse animation
- [ ] Style title (22pt semibold)
- [ ] Style status label (16pt, secondary text)
- [ ] Add animated dots ("...")
- [ ] Style cancel button (secondary style)

### Recipe Editing Screen
- [ ] Update background
- [ ] Create header card (image + title)
- [ ] Create ingredients card with green bullets
- [ ] Create instructions card with green number badges
- [ ] Create tips card with light green background
- [ ] Style save button (primary, 56pt height)
- [ ] Style cancel button (secondary, 48pt height)

### Transitions
- [ ] Add fade/scale transition from loading to recipe view

---

## Phase 7: Polish & Testing

- [ ] Test all screens on iPhone 16 simulator
- [ ] Verify consistent styling across all views
- [ ] Check component reuse (no duplicated styles)
- [ ] Verify animations work smoothly
- [ ] Test Share Extension full flow
- [ ] Final visual review against Tastory screenshots

---

## Completion Summary

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Design System | ✅ Completed | All components created and build verified |
| Phase 2: Core Views | Not Started | |
| Phase 3: Recipe Creation | Not Started | |
| Phase 4: Category Management | Not Started | |
| Phase 5: Settings & Profile | Not Started | |
| Phase 6: Share Extension | Not Started | |
| Phase 7: Polish & Testing | Not Started | |

---

## Quick Reference

**Primary Green:** #1B6D3F
**Light Green Bg:** #E8F5EF
**Background:** #F5F5F5
**Card Background:** #FFFFFF
**Primary Text:** #1A1A1A
**Secondary Text:** #6B7280

**Button Heights:** 56pt (primary), 48pt (secondary)
**Card Radius:** 16pt
**Button Radius:** 24pt
