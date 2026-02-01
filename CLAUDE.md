# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Development Guide for Tastory AI

## Core Principles
- **Keep the UI clean and simple** - single input, clear output
- **Ensure mobile responsiveness** for creators on-the-go
- **Prioritize simplicity** in every code change and design decision
- **Follow Apple UI best practices** and iOS design guidelines
- **Use modern SwiftUI** patterns and components

## Project Overview
Tastory AI is a native iOS cookbook app that captures recipes from any source (TikTok, Instagram, photos, web links) and uses AI to extract clean ingredients and step-by-step directions. The app focuses on simplicity, mobile responsiveness, and a clean UI design.

## Development Workflow

### 1. Problem Analysis & Planning
- First, thoroughly read and understand the problem
- Review the existing codebase for relevant files
- Create a detailed plan with specific, actionable items
- Each todo item should be small and focused on a single change

### 2. Plan Verification
- Present the plan for review before starting implementation
- Wait for confirmation that the approach is correct
- Make any necessary adjustments based on feedback

### 3. Implementation Process
- Work through todo items one at a time
- Mark items as complete as you finish them
- Keep changes minimal and focused - impact as little code as possible
- Every change should maintain or improve simplicity

### 4. Communication Guidelines
- Provide high-level explanations for each change made
- Avoid technical jargon when explaining modifications
- Focus on the "what" and "why" rather than implementation details

### 5. Review & Documentation
- Summarize all changes made
- Include any relevant information for future development
- Note any potential improvements or considerations

---

## Current Architecture

### Platform & Storage
- **Platform**: Native SwiftUI for iOS/iPadOS
- **Storage**: Local JSON via RecipeStorageManager with App Groups for Share Extension sync
- **UI Framework**: MVVM pattern with Theme.swift and Typography.swift design system

### AI & Processing
- **AI Processing**: OpenAI GPT-4o with secure xcconfig API key management and rate limiting
- **Input Processing**: Vision framework for OCR, Share Extension with full recipe editing UI
- **Recipe Processing**: IngredientParser utility with sophisticated scaling and unit recognition
- **Web Scraping**: Platform-specific content extraction for Instagram, TikTok, recipe websites

### Future Architecture (Planned)
- **Backend**: Supabase (Postgres, Auth, Storage, Edge Functions)
- **Auth**: Sign in with Apple or Google (optional) sign-in
- **Ingredient Database**: USDA FoodData Central API integration for missing ingredients

---

## UI/UX Requirements & Design System

> **IMPORTANT**: All new UI elements, screens, and components MUST follow the Tastory design system defined in [newUX.md](newUX.md). This includes colors, typography, spacing, and reusable components.
>
> **Status**: ✅ UX Redesign COMPLETED (All 7 phases)

### Design Principles
- Modern, clean aesthetic inspired by Tastory Suite
- Consistent use of reusable components (TastoryButton, TastoryCard, TastoryListItem, etc.)
- Primary accent color: Green (#1B6D3F)
- Background: Off-white (#F5F5F5)
- Cards: White with subtle shadows
- Fully responsive between iPhone and iPad (portrait/landscape)

### Component Library
Use the following reusable components defined in `Views/Components/`:
- `TastoryButton` - Primary, secondary, text, destructive button styles
- `TastoryCard` - White card container with shadow
- `TastoryListItem` - Standardized list row with icon, title, subtitle
- `TastorySectionHeader` - Section headers with optional count and action
- `TastoryTextField` - Styled input fields
- `TastoryEmptyState` - Empty state displays
- `TastoryLoadingView` - Loading indicators with animation
- `TastoryBadge` - Tags and badges

### Header/Navigation Pattern
All main screens use a consistent custom header approach:
- **Custom Header**: VStack with HStack containing title (28pt bold) and action button
- **Action Buttons**: Use `.buttonStyle(.bordered)` with `.tint(.gray)` for gray glass effect
- **Button Shapes**: `.buttonBorderShape(.capsule)` for text buttons, `.buttonBorderShape(.circle)` for icon buttons
- **Navigation Bar Hidden**: Main tabs use `.navigationBarHidden(true)` for full control
- **Sub-screens**: Keep navigation bar for back button, apply glass button style to toolbar items

### Visual Hierarchy
- Ingredients and steps prioritized over metadata
- Clarity, whitespace, and typography emphasized

---

## Features Implementation Status

### 1. Recipe Capture ✅ **COMPLETED**
- ✅ Share Sheet integration (Instagram, TikTok, URLs) - Full extension with content extraction and recipe editing UI
- ✅ Photo/Camera import with OCR - Vision framework with error handling
- ✅ Manual entry with validation - Complete form with dynamic ingredients/steps
- ✅ URL input handling - Complete AI processing pipeline integrated

### 2. AI Processing ✅ **COMPLETED**
- ✅ Structured recipe extraction (title, ingredients, steps, tips) - OpenAI GPT-4o integration
- ✅ Multi-modal processing pipeline - Text, URL, OCR, and Share Extension content processing
- ✅ Rate limiting (10 req/min/user) - Implemented with queue system and user feedback
- ✅ Web scraping service - Platform-specific extraction for Instagram, TikTok, recipe sites
- ✅ Share Extension recipe editing - Full UI with editable fields

### 3. Recipe Management ✅ **COMPLETED**
- ✅ CRUD operations with editable fields - Full RecipeStorageManager with JSON persistence
- ✅ Dynamic serving size scaling - Enhanced IngredientParser with local ingredient database and fuzzy matching
- ✅ Local ingredient database - 100 common cooking ingredients with scaling properties
- ✅ Share recipe via system sheet - Built-in iOS share integration
- ✅ Photo upload - Data URL storage in Recipe.imageURL field
- ✅ Source URL tracking - Captured during URL-based recipe extraction
- ✅ Tips & Notes - AI-generated cooking tips editable in all contexts

### 4. Category System ✅ **COMPLETED & TESTED** (Phases 1-5)

**Phase 1 - Data Models & Recipe Editing** ✅
- Category model with validation (Category.swift)
- Recipe model extended with categoryIds and primaryCategoryId
- CategoryManager singleton with CRUD operations
- "New recipes" system category with auto-assignment
- Recipe editing UI with primary and additional category pickers
- Share Extension integration

**Phase 2 - Categories Tab UI** ✅
- Replaced Search tab with Categories tab (3 tabs: Recipes, Categories, Profile)
- CategoriesView.swift - category list with recipe counts
- FilteredRecipesView.swift - category-based recipe filtering
- Multi-category support - recipes appear in all assigned categories

**Phase 3 - Category Management** ✅
- Category edit/rename functionality
- Category deletion with automatic recipe reassignment to "New recipes"
- iOS-standard swipe actions (Edit/Delete)
- System category protection

**Phase 4 - Search Integration** ✅
- Search bar in HomeView with 250ms debounced search
- Comprehensive search across title, ingredients, steps, and category names
- Case/diacritic-insensitive matching
- AND logic across search tokens

**Phase 5 - Bulk Operations** ✅
- Apple Photos-style multi-select mode
- Bulk actions: Delete, Add Category, Set Primary, Remove from Category, Move to Category
- Confirmation alerts for destructive operations
- RecipeGridView modified to support both selection and navigation modes

> **Implementation Details**: For technical implementation patterns, code examples, and specific component details, see [implementation-details.md](implementation-details.md)

### 5. Search & Organization ✅ **COMPLETED**
- ✅ Search bar in HomeView - search title, ingredients, categories, steps
- ✅ Multi-select recipes with bulk operations
- ✅ Category browsing and filtering

### 6. UX Redesign ✅ **COMPLETED** (All 7 Phases)
- ✅ **Phase 1**: Design System Foundation - TastoryDesign.swift with colors, spacing, radius, shadows; reusable components in Views/Components/
- ✅ **Phase 2**: Core Views - HomeView, RecipeCardView, RecipeDetailView, CategoriesView updated
- ✅ **Phase 3**: Recipe Creation/Editing - AddRecipeView, URLRecipeEntryView, PhotoRecipeEntryView, RecipeEditingView, EditRecipeView
- ✅ **Phase 4**: Category Management - FilteredRecipesView, CategorySheets, BulkCategorySheets
- ✅ **Phase 5**: Settings & Profile - ProfileView, DebugMenuView
- ✅ **Phase 6**: Share Extension - ShareViewController UIKit styling with Tastory design constants
- ✅ **Phase 7**: Polish & Testing - All screens tested, consistent styling verified, custom header pattern implemented

---

## Performance Requirements
- Cold start ≤ 2 seconds
- Recipe capture ≤ 5 seconds on 4G
- 60 fps scrolling
- 99.9% API uptime

---

## Security & Privacy
- **API Key Security**: OpenAI API key stored in secure xcconfig file (excluded from git)
- **Build-time Injection**: API keys injected at build time via $(OPENAI_API_KEY) variable reference
- **Git Security**: .gitignore configured to prevent sensitive data commits
- TLS encryption in transit
- AES-256 encryption at rest
- Row-level security in Supabase (planned)
- GDPR compliance
- App Store privacy requirements

---

## Development Best Practices

### Code Organization
- Use modular SwiftPM packages
- Maintain 80% unit test coverage
- Implement snapshot UI tests
- Follow MVVM architecture pattern

### Debug & Testing Guidelines
- **All future test features and debug tools should be added to the DebugMenuView** - accessed via Profile → Debug & Testing
- Test buttons and debug functionality must never appear on the main screens
- Keep debug tools organized in dedicated development sections

### Testing & Build Process
When implementing changes, follow this testing workflow:
1. `xcodebuild clean` - Clear old build data
2. `xcodebuild build` - Compile the updated app
3. Install the updated app in the simulator using `xcrun simctl install`
4. Launch the app with `xcrun simctl launch`
5. Wait for user confirmation that everything works as expected
6. Only after user confirmation, update status documentation

### State Management
- Use SwiftUI's built-in state management
- Implement proper data flow between views
- Cache appropriately for offline functionality

### Error Handling
- Graceful degradation for network issues
- Queue and retry failed operations
- Clear user feedback for errors

### Accessibility
- VoiceOver labels on all interactive elements
- Dynamic Type support
- WCAG AA color contrast compliance
- Readable fonts for cooking scenarios

---

## Common Tasks

### Adding a New Feature
1. Review the feature requirements
2. Check impact on existing code
3. Create minimal implementation plan
4. Test thoroughly on both iPhone and iPad
5. Ensure offline functionality where applicable

### Fixing Bugs
1. Reproduce the issue consistently
2. Identify root cause with minimal code inspection
3. Implement simplest possible fix
4. Test fix doesn't break other features
5. Document the fix in commit message

### UI Updates
1. Follow Apple HIG guidelines
2. Maintain consistency with existing design
3. Test on multiple device sizes
4. Ensure accessibility compliance
5. Keep animations smooth and purposeful

---

## Important Implementation Notes

### Recipe Model Changes
**Critical**: When adding new Recipe fields, always check and update:
1. Recipe initializers throughout codebase
2. ExtractedRecipeData struct in RecipeExtractionService
3. All Recipe creation calls in Share Extension
4. JSON parsing logic for backward compatibility

### Storage Architecture
- **Single Source of Truth**: RecipeStorageManager for recipes, CategoryManager for categories
- **App Groups**: Shared container for Share Extension sync
- **JSON Persistence**: Simple, reliable local storage

### Category System Architecture
- **Single Category List**: CategoryManager maintains one unified category list
- **System Category**: "New recipes" (UUID: 00000000-0000-0000-0000-000000000001) cannot be deleted
- **Multi-Category Support**: Recipes can belong to multiple categories
- **Primary Category**: Always included in categoryIds array
- **Data Consistency**: Delete operations maintain referential integrity

> **Technical Details**: For specific code patterns, UI components, and implementation examples, see [implementation-details.md](implementation-details.md)

---

## Remember
- Every change should make the app simpler, not more complex
- When in doubt, choose the solution with less code
- Always consider the mobile cooking experience
- Test your changes in real cooking scenarios
- Keep the interface clean and focused on the recipe content
- Refer to [implementation-details.md](implementation-details.md) for technical implementation patterns
- **Use reusable components from `Views/Components/`** - avoid duplicating UI code
- **Follow the design system in [newUX.md](newUX.md)** for all UI work
