# Tastory AI - Development Roadmap

## 📊 Current State (For Future Sessions)

### ✅ COMPLETED: Foundation & Recipe Management System
- **Complete MVVM architecture** with local JSON storage via RecipeStorageManager
- **All input methods implemented**: Manual entry, URL input with validation, Photo/OCR with Vision framework, Share Extension for Instagram/TikTok
- **Advanced recipe features**: Serving size scaling with sophisticated IngredientParser, full CRUD operations, editing, sharing
- **Responsive UI**: iPhone/iPad layouts with Theme.swift and Typography.swift design system
- **Share Extension**: Configured to accept URLs, images, videos, text with programmatic UI

### 🔄 CURRENT STATUS: Ready for AI Processing Integration
All input mechanisms capture content successfully. Next phase focuses on AI-powered recipe extraction.

---

## 🎯 Phase 2: AI Integration & Advanced Features

### HIGH PRIORITY (Phase 2A - Next Sprint)

#### 1. AI Processing Pipeline
- [ ] Set up OpenAI GPT-4o API client service  
- [ ] Create structured prompts for recipe extraction from text/HTML/OCR content
- [ ] Implement multi-modal processing (text + images + audio)
- [ ] Add error handling for API failures and rate limits
- [ ] Process extracted content into Recipe model format

#### 2. Web Content Processing  
- [ ] Create web scraping service for common recipe websites
- [ ] Extract recipe data from various web formats (JSON-LD, Microdata, etc.)
- [ ] Connect existing URL input to AI processing pipeline
- [ ] Handle different website structures and formats

#### 3. Complete Share Extension Integration
- [ ] Test sharing from Instagram/TikTok/Safari thoroughly
- [ ] Implement data passing between Share Extension and main app
- [ ] Connect Share Extension content to AI processing

#### 4. Rate Limiting System
- [ ] Implement 10 requests/minute/user rate limiting
- [ ] Add queue system for processing requests  
- [ ] Create user feedback for rate limit status
- [ ] Handle rate limit exceeded gracefully

### MEDIUM PRIORITY (Phase 2B)

#### 5. AI-Powered Features
- [ ] Implement AI-powered category detection
- [ ] Generate relevant tags based on ingredients and cooking methods
- [ ] Create category suggestion system
- [ ] Add confidence scoring for AI-generated metadata

#### 6. Unit Conversion System
- [ ] Create unit conversion service for ingredients
- [ ] Add US/Metric toggle switch in RecipeDetailView  
- [ ] Extend IngredientParser to handle unit conversions
- [ ] Support common conversions (cups↔ml, oz↔g, fahrenheit↔celsius)
- [ ] Persist user's preferred unit system

#### 7. Search & Organization
- [ ] Create RecipeSearchManager with full-text search capabilities
- [ ] Add search bar to HomeView with real-time results
- [ ] Search through titles, ingredients, categories, tags, and steps
- [ ] Implement search result highlighting
- [ ] Add search history and suggestions

#### 8. Category/Tag Filtering System  
- [ ] Create filter UI in HomeView with category/tag chips
- [ ] Implement tap-to-filter functionality
- [ ] Add multi-filter support (AND/OR logic)
- [ ] Create filter state management
- [ ] Add "Clear all filters" functionality

### LOW PRIORITY (Phase 2C)

#### 9. Enhanced Recipe Management
- [ ] Create CategoryManager service for custom category CRUD
- [ ] Add category creation/editing UI
- [ ] Implement tag management system with autocomplete
- [ ] Create category and tag selection interfaces
- [ ] Add category/tag deletion with recipe reassignment

#### 10. Advanced Features
- [ ] Enhanced Grid View with interactive category chips
- [ ] Show active filters in grid view  
- [ ] Add filter summary display
- [ ] Smart Manual Entry with paste detection for recipe content
- [ ] Auto-format pasted recipe text into structured ingredients/steps

#### 11. Enhanced System Sharing
- [ ] Extend existing share functionality for Mail, SMS, WhatsApp, Messenger
- [ ] Add recipe formatting for different share targets
- [ ] Include recipe images in shared content
- [ ] Create share templates for different platforms

#### 12. Project Finalization
- [ ] Update bundle identifier to com.tastoryai.app
- [ ] Set minimum iOS deployment target to iOS 17.0
- [ ] Create final app icon following Apple guidelines
- [ ] Configure launch screen with app logo and brand colors
- [ ] Test on iPhone and iPad simulators thoroughly
- [ ] Ensure all SwiftUI previews work correctly

---

## 🎯 Success Criteria for Phase 2

### Phase 2A (AI Integration)
- Users can share content from any app and get structured recipes
- URL processing extracts clean recipe data from websites
- AI processing handles text, images, and mixed content reliably
- Rate limiting prevents API abuse while maintaining good UX

### Phase 2B (Enhanced Features)  
- Unit conversion works seamlessly with ingredient scaling
- Search finds recipes across all content (title, ingredients, steps, tags)
- Filtering by categories/tags provides quick recipe discovery

### Phase 2C (Polish & Advanced)
- Custom categories and tags system for personalization
- Professional sharing capabilities across platforms
- Complete recipe management ecosystem ready for production

---

## 📝 Technical Notes

### Current Architecture
- **Storage**: Local JSON via RecipeStorageManager (will migrate to Supabase later)
- **Parsing**: IngredientParser utility with unit recognition and quantity scaling
- **UI Framework**: SwiftUI with MVVM pattern, Theme-based design system
- **Input Processing**: Vision framework for OCR, Share Extension for external content
- **Permissions**: Camera/Photo library configured via Xcode project settings

### Key Design Decisions  
- Local-first approach for Phase 1 (offline functionality)
- Ingredient scaling with sophisticated parsing (handles fractions, ranges, units)
- Share Extension uses programmatic UI (no storyboard) for better control
- OpenAI GPT-4o chosen for multi-modal recipe extraction capabilities

### Development Principles (from CLAUDE.md)
- Keep UI clean and simple - single input, clear output
- Ensure mobile responsiveness for creators on-the-go  
- Prioritize simplicity in every code change and design decision
- Follow Apple UI best practices and iOS design guidelines