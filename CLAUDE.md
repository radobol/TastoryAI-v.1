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
### 1. Problem Analysis & Planning
- First, thoroughly read and understand the problem
- Review the existing codebase for relevant files
- Create a detailed plan in `todo.md` with specific, actionable items
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
- Add a review section to `todo.md` after completing tasks
- Summarize all changes made
- Include any relevant information for future development
- Note any potential improvements or considerations



#### Current Implementation (Phase 2A Complete)
- **Platform**: Native SwiftUI for iOS/iPadOS
- **Storage**: Local JSON via RecipeStorageManager with App Groups for Share Extension sync
- **AI Processing**: OpenAI GPT-4o with secure xcconfig API key management and rate limiting
- **Input Processing**: Vision framework for OCR, Share Extension with full recipe editing UI
- **Recipe Processing**: IngredientParser utility with sophisticated scaling and unit recognition
- **UI Framework**: MVVM pattern with Theme.swift and Typography.swift design system
- **Web Scraping**: Platform-specific content extraction for Instagram, TikTok, recipe websites

#### Planned Architecture (Phase 2+)
- **Backend**: Supabase (Postgres, Auth, Storage, Edge Functions)
- **AI Service**: OpenAI GPT-4o for multi-modal recipe extraction
- **Auth**: Sign in with Apple or Google (optional) sign-in 


### UI/UX Requirements
- Modern digital cookbook aesthetic with notes-like feel
- Clean, minimal, and functional design
- Prioritize clarity, whitespace, and typography
- Visual hierarchy: ingredients and steps over metadata
- ShadCN-style components: neutral tones, soft shadows, rounded corners
- Fully responsive between iPhone and iPad (portrait/landscape)

### Features Implementation Status

1. **Recipe Capture** ✅ **COMPLETED**
   - ✅ Share Sheet integration (Instagram, TikTok, URLs) - Full extension with content extraction and recipe editing UI
   - ✅ Photo/Camera import with OCR - Vision framework with error handling
   - ✅ Manual entry with validation - Complete form with dynamic ingredients/steps
   - ✅ URL input handling - Complete AI processing pipeline integrated

2. **AI Processing** ✅ **COMPLETED - Phase 2A**
   - ✅ Structured recipe extraction (title, ingredients, steps, tips) - OpenAI GPT-4o integration with secure xcconfig API key management
   - ✅ Multi-modal processing pipeline - Text, URL, OCR, and Share Extension content processing
   - ✅ Rate limiting (10 req/min/user) - Implemented with queue system and user feedback
   - ✅ Web scraping service - Platform-specific extraction for Instagram, TikTok, recipe sites
   - ✅ Share Extension recipe editing - Full UI with editable fields matching ReciMe design
   - [ ] Auto-categorization and tagging - Planned for Phase 2B

3. **Recipe Management** ✅ **COMPLETED**
   - ✅ CRUD operations with editable fields - Full RecipeStorageManager with JSON persistence
   - [ ] US/Metric unit toggle - Planned for Phase 2B with IngredientParser extension
   - ✅ Dynamic serving size scaling - Advanced IngredientParser with unit recognition
   - [ ] Custom categories and tags - Planned for Phase 2C
   - ✅ Share recipe via system sheet - Built-in iOS share integration

4. **Search & Organization** 📋 **PLANNED - Phase 2B**
   - [ ] Full-text search - RecipeSearchManager design ready
   - [ ] Filter by category/tag - Interactive chips system planned
   - [ ] Grid view with category chips - Extension of existing RecipeGridView


### Performance Requirements
- Cold start ≤ 2 seconds
- Recipe capture ≤ 5 seconds on 4G
- 60 fps scrolling
- 99.9% API uptime

### Security & Privacy
- **API Key Security**: OpenAI API key stored in secure xcconfig file (excluded from git)
- **Build-time Injection**: API keys injected at build time via $(OPENAI_API_KEY) variable reference
- **Git Security**: .gitignore configured to prevent sensitive data commits
- TLS encryption in transit
- AES-256 encryption at rest
- Row-level security in Supabase (planned)
- GDPR compliance
- App Store privacy requirements

## Development Best Practices

### Code Organization
- Use modular SwiftPM packages
- Maintain 80% unit test coverage
- Implement snapshot UI tests
- Follow MVVM architecture pattern

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

## Remember
- Every change should make the app simpler, not more complex
- When in doubt, choose the solution with less code
- Always consider the mobile cooking experience
- Test your changes in real cooking scenarios
- Keep the interface clean and focused on the recipe content

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

ShareViewController → RecipeExtractionService.processSharedContent()
                  ↓
If URLs available → WebScrapingService.extractContent()
                  ↓
All content combined → OpenAIService.generateRecipeFromText()
                  ↓
Recipe editing UI → User edits → Save to App Groups → Success alert

### ReciMe-Style UI Features

- **Scrollable Content**: Full recipe editing in compact Share Extension format
- **Editable Fields**: All text fields and text views allow user modifications
- **Professional Design**: Clean layout with orange accent colors and proper spacing
- **Save/Cancel Flow**: Clear user actions with success feedback