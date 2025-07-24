# Tastory AI - Initial Project Setup Plan

## Overview
This plan outlines the initial setup for Tastory AI, a native iOS cookbook app that captures recipes from any source and uses AI to extract clean ingredients and directions. The focus is on creating a minimal, clean foundation that we can build upon incrementally.

## Todo Items

### 1. Project Configuration
- [x] Rename Xcode project from "TastoryAI v.1" to "TastoryAI"
- [ ] Update bundle identifier to com.tastoryai.app
- [ ] Set minimum iOS deployment target to iOS 17.0
- [ ] Configure project for iPhone and iPad support
- [ ] Enable SwiftUI previews for all device sizes

### 2. Core Folder Structure
- [x] Create Groups folder structure in Xcode:
  - [x] `App` - App entry point and configuration
  - [x] `Views` - All SwiftUI views
  - [x] `Models` - Data models
  - [x] `ViewModels` - View models for MVVM
  - [x] `Services` - Business logic and API services
  - [x] `Utilities` - Helper functions and extensions
  - [x] `Resources` - Assets, colors, fonts

### 3. Design System Setup
- [x] Create `Theme.swift` with color definitions:
  - [x] Primary colors (neutral tones)
  - [x] Background colors
  - [x] Text colors with proper contrast
  - [x] Accent color for CTAs
- [x] Create `Typography.swift` with font styles:
  - [x] Title styles
  - [x] Body text styles
  - [x] Caption styles
- [x] Configure Assets.xcassets with color sets

### 4. App Entry Point
- [x] Update `TastoryAIApp.swift` with proper naming
- [x] Create `MainTabView.swift` with tab navigation:
  - [x] Home tab (Recipes grid)
  - [x] Search tab (placeholder)
  - [x] Profile tab (placeholder)
- [x] Add SF Symbol icons for tabs
- [x] Set up proper navigation structure

### 5. Recipe Model
- [x] Create `Recipe.swift` model with basic properties:
  - [x] id (UUID)
  - [x] title (String)
  - [x] ingredients ([String])
  - [x] steps ([String])
  - [x] imageURL (String?)
  - [x] category (String?)
  - [x] tags ([String])
  - [x] servings (Int)
  - [x] createdAt (Date)
- [x] Add Codable conformance for future API integration

### 6. Home Screen
- [x] Create `HomeView.swift` with:
  - [x] Navigation title "My Recipes"
  - [x] Empty state with friendly message
  - [x] Floating "+" button for adding recipes
- [x] Create `RecipeGridView.swift` for displaying recipes:
  - [x] 2-column grid on iPhone
  - [x] 3-4 column grid on iPad
  - [x] Recipe cards with image, title, and category
- [x] Add sample data for preview testing

### 7. Add Recipe Flow
- [x] Create `AddRecipeView.swift` as a sheet:
  - [x] Navigation bar with Cancel/Save buttons
  - [x] Input options placeholder (URL, Photo, Manual)
  - [x] Clean, minimal design
- [x] Wire up sheet presentation from Home view
- [x] Add basic dismiss functionality

### 8. Recipe Card Component
- [x] Create `RecipeCardView.swift`:
  - [x] Rounded corners with soft shadow
  - [x] Placeholder image area
  - [x] Recipe title
  - [x] Category chip
  - [x] Tap gesture for future navigation

### 9. App Icon & Launch Screen
- [x] Create placeholder app icon:
  - [ ] Simple cookbook or recipe-related design
  - [ ] Follow Apple's icon guidelines
- [ ] Configure launch screen:
  - [ ] App logo centered
  - [ ] Brand color background
  - [ ] Smooth transition to app

### 10. Project Cleanup
- [x] Remove default "Hello, world!" content
- [x] Update file headers with proper copyright
- [x] Organize files into correct group folders
- [ ] Test on iPhone and iPad simulators
- [ ] Ensure all SwiftUI previews work correctly

## Success Criteria
- Clean, organized project structure following MVVM
- Minimal but functional UI with proper navigation
- Responsive layout for iPhone and iPad
- Consistent design system in place
- All components use SwiftUI best practices
- Project builds without warnings
- Smooth navigation and interactions

## Next Steps (Future)
- Supabase integration
- AI recipe extraction service
- Share Sheet extension
- Search functionality
- User authentication
- Data persistence

## Notes
- Keep everything minimal - we'll add complexity incrementally
- Focus on clean code and proper architecture from the start
- Ensure every component is reusable and testable
- Follow Apple's Human Interface Guidelines throughout

## Implementation Review

### Completed Tasks
1. **Project Structure**: Created a clean MVVM folder structure with separate directories for App, Views, Models, ViewModels, Services, Utilities, and Resources
2. **Design System**: Implemented comprehensive Theme.swift and Typography.swift files with:
   - Neutral color palette with proper contrast
   - Complete typography scale following iOS standards
   - Spacing, corner radius, and shadow definitions
3. **Navigation**: Set up MainTabView with three tabs (Recipes, Search, Profile) using SF Symbols
4. **Recipe Model**: Created a robust Recipe model with all required properties and Codable conformance
5. **Home Screen**: Built HomeView with:
   - Empty state for new users
   - Floating add button with proper styling
   - RecipeGridView that adapts between iPhone (2 columns) and iPad (4 columns)
6. **Add Recipe Flow**: Created AddRecipeView with three input options (URL, Photo, Manual) in a clean sheet presentation
7. **Recipe Cards**: Designed RecipeCardView with placeholder images, category chips, and serving/ingredient counts

### Key Decisions Made
- Used SwiftUI's built-in navigation and state management
- Implemented a clean, minimal design with soft shadows and rounded corners
- Added sample recipe data for testing
- Made the grid layout responsive using horizontalSizeClass
- Used system colors and fonts for consistency with iOS

## Recipe Details & Local Storage Implementation - COMPLETED ✅

### Additional Features Implemented
8. **Local Storage Manager**: Created `RecipeStorageManager.swift` with JSON-based persistence
   - CRUD operations (Create, Read, Update, Delete)
   - Automatic sample data migration on first launch
   - Error handling and data validation

9. **Recipe Detail View**: Built comprehensive `RecipeDetailView.swift` with:
   - Hero image placeholder
   - Title and category display
   - Interactive serving size adjustment with live scaling
   - Checkable ingredients list with quantity scaling
   - Step-by-step instructions with numbered circles
   - Edit, share, duplicate, and delete actions

10. **Edit Recipe Functionality**: Created `EditRecipeView.swift` with:
    - Inline editing of all recipe fields
    - Dynamic ingredient and step management
    - Tag editor with add/remove functionality
    - Form validation and save functionality

11. **Manual Recipe Entry**: Extended `AddRecipeView.swift` with:
    - Full manual entry form (`ManualRecipeEntryView`)
    - Dynamic ingredient and step addition
    - Real-time form validation
    - Integration with storage manager

12. **Navigation Integration**: Updated navigation flow:
    - Recipe cards now link to detail views
    - Home view uses storage manager
    - Proper SwiftUI navigation structure

### Key Technical Achievements
- **Offline-first design**: All data stored locally in JSON format
- **Real-time quantity scaling**: Ingredients automatically adjust based on serving size
- **Comprehensive CRUD operations**: Full create, read, update, delete functionality
- **Share functionality**: Built-in iOS share sheet integration
- **Data persistence**: Automatic saving and loading of recipes
- **Form validation**: Proper input validation and error handling

## Phase 2: Core CLAUDE.md Features Implementation

### 1. Recipe Capture System (High Priority)
Currently the "From URL" and "From Photo" buttons in AddRecipeView are placeholder buttons with empty actions.

#### Share Sheet Integration
- [ ] Implement Share Sheet extension for receiving content from Instagram/TikTok/other apps
- [x] Add URL input handling and validation
- [ ] Create web scraping service for common recipe websites
- [ ] Extract recipe data from various web formats (JSON-LD, Microdata, etc.)
- [x] Connect "From URL" button to actual URL processing functionality

#### Photo/Camera Import with OCR
- [x] Add camera and photo library access permissions
- [x] Implement OCR using Vision framework for text extraction from images
- [ ] Create PhotoRecipeParser for converting OCR text to recipe format
- [ ] Add image preprocessing for better OCR accuracy
- [x] Connect "From Photo" button to camera/photo library selection
- [x] Handle OCR parsing errors gracefully

#### Smart Manual Entry Enhancement
- [ ] Add smart paste detection to identify recipe content in clipboard
- [ ] Auto-format pasted recipe text into structured ingredients/steps
- [ ] Enhance existing ManualRecipeEntryView with paste intelligence

### 2. AI Processing System (High Priority)
Transform captured content (URLs, photos, manual) into clean recipe data.

#### OpenAI GPT-4o Integration
- [ ] Set up OpenAI API client service
- [ ] Create structured prompts for recipe extraction
- [ ] Implement recipe parsing from unstructured text/web content
- [ ] Add error handling for API failures and rate limits
- [ ] Process extracted content into Recipe model format

#### Auto-categorization and Tagging
- [ ] Implement AI-powered category detection
- [ ] Generate relevant tags based on ingredients and cooking methods
- [ ] Create category suggestion system
- [ ] Add confidence scoring for AI-generated metadata

#### Rate Limiting System
- [ ] Implement 10 requests/minute/user rate limiting
- [ ] Add queue system for processing requests
- [ ] Create user feedback for rate limit status
- [ ] Handle rate limit exceeded gracefully

### 3. Enhanced Recipe Management (Medium Priority)
Extend existing recipe functionality with CLAUDE.md requirements.

#### US/Metric Unit Toggle System
- [ ] Create unit conversion service for ingredients
- [ ] Add toggle switch in RecipeDetailView for unit switching
- [ ] Extend IngredientParser to handle unit conversions
- [ ] Support common conversions (cups↔ml, oz↔g, fahrenheit↔celsius)
- [ ] Persist user's preferred unit system

#### Custom Categories and Tags Management
- [ ] Create CategoryManager service for custom category CRUD
- [ ] Add category creation/editing UI
- [ ] Implement tag management system with autocomplete
- [ ] Create category and tag selection interfaces
- [ ] Add category/tag deletion with recipe reassignment

#### Enhanced System Sharing
- [ ] Extend existing share functionality for Mail, SMS, WhatsApp, Messenger
- [ ] Add recipe formatting for different share targets
- [ ] Include recipe images in shared content
- [ ] Create share templates for different platforms

### 4. Search & Organization (Medium Priority)
Add comprehensive search and filtering capabilities.

#### Full-text Search Implementation
- [ ] Create RecipeSearchManager with full-text search capabilities
- [ ] Add search bar to HomeView with real-time results
- [ ] Search through titles, ingredients, categories, tags, and steps
- [ ] Implement search result highlighting
- [ ] Add search history and suggestions

#### Category/Tag Filtering System
- [ ] Create filter UI in HomeView with category/tag chips
- [ ] Implement tap-to-filter functionality
- [ ] Add multi-filter support (AND/OR logic)
- [ ] Create filter state management
- [ ] Add "Clear all filters" functionality

#### Enhanced Grid View with Category Chips
- [ ] Add category chips display to existing RecipeGridView
- [ ] Make category chips interactive (tap to filter)
- [ ] Show active filters in grid view
- [ ] Add filter summary display

### Ready for Next Steps
After Phase 2 completion, the app will have:
- Complete recipe capture from any source (URLs, photos, manual)
- AI-powered recipe extraction and categorization  
- Advanced search and filtering capabilities
- Professional unit conversion system
- Enhanced sharing across all major platforms