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

### Ready for Next Steps
The foundation is now in place for:
- Supabase backend integration
- AI recipe extraction implementation
- Share Sheet extension
- Camera/photo library integration
- Search functionality
- Data persistence