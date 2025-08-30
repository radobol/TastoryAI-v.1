### MEDIUM PRIORITY (Phase 2B)

4. Category System  **PLANNED**
   - [ ] Adjust Recipes creation and edit UI to choose from existing, create a new category. By default, all new recipes have "New recipes" category
         Update schema
         categories(id, name, slug, is_system)
         recipe_categories(recipe_id, category_id, is_primary)
         Constraints: unique (recipe_id, category_id); exactly one is_primary=true per recipe_id
   - [ ] Seed reserved category New recipes (is_system=true, non‑deletable)
   - [ ] Recipe create behavior: auto‑assign New recipes as primary; editor allows adding more categories and changing the primary
   - [ ] Create a new "Categories" section, a new tab + icon (instead of the current "Search") in the app and add an icon to the main menu
   - [ ] Create "Categories" section UI with 
         - filtering by category
         - recipes grouped by category, each recipe appears in all categories that set up
         - “New recipes” first; others sorted A→Z (locale + case/diacritic‑insensitive)
         - “+ New category” button opens overlay (create with validation)
         - “Edit” opens rename / delete 

   - [ ]  Category delete rules: reassign affected primaries to New recipes (or next remaining); block delete if is_system=true
   - [ ] Validation: name required, 1–32 chars, trimmed; case‑insensitive uniqueness (no duplicates after trimming/diacritics)   

5. Search & Organization  **PLANNED**
   - [ ] Search bar in HomeView with 250 ms debounce; search title, ingredients, categories, steps; case/diacritic‑insensitive; AND across tokens; highlight matches; works with active category filter
   - [ ] Add option to select recipies(simmilar as Apple photo app have) and with follow functionality(long‑press or “Select”):
         - delete selected recipes
         - change existed or add new category; Add, Remove, Set primary (single)
   - [ ] Add option to share each recipe directly from thumbnail card of recipe in home screen
   - [ ] Rename items to ingredients on recipe cards


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
- **Storage**: Local JSON via RecipeStorageManager with App Groups for Share Extension sync
- **AI Processing**: OpenAI GPT-4o with secure xcconfig API key management and rate limiting
- **Web Scraping**: Platform-specific content extraction for Instagram, TikTok, recipe websites
- **Parsing**: IngredientParser utility with unit recognition and quantity scaling
- **UI Framework**: SwiftUI with MVVM pattern, Theme-based design system
- **Input Processing**: Vision framework for OCR, Share Extension for external content
- **Security**: API keys excluded from git with build-time injection via xcconfig
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








 Here is Claude's plan:                                                                                                                                                                                                         │
│ ╭────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Category System Implementation Plan                                                                                                                                                                                        │ │
│ │                                                                                                                                                                                                                            │ │
│ │ Phase 1: Data Models & Storage (Backend Foundation)                                                                                                                                                                        │ │
│ │                                                                                                                                                                                                                            │ │
│ │ 1. Create Category Model - New Category.swift with id, name, slug, isSystem fields                                                                                                                                         │ │
│ │ 2. Update Recipe Model - Replace single category field with categoryIds array and primaryCategoryId                                                                                                                        │ │
│ │ 3. Create CategoryManager - New service to handle category CRUD operations with JSON persistence                                                                                                                           │ │
│ │ 4. Migration Logic - Convert existing recipes' string categories to new category system                                                                                                                                    │ │
│ │ 5. Seed System Category - Initialize "New recipes" as default system category                                                                                                                                              │ │
│ │                                                                                                                                                                                                                            │ │
│ │ Phase 2: Recipe Creation/Edit UI Updates                                                                                                                                                                                   │ │
│ │                                                                                                                                                                                                                            │ │
│ │ 6. Update AddRecipeView - Add category picker with multi-select and primary designation                                                                                                                                    │ │
│ │ 7. Update EditRecipeView - Add category management UI with existing/new category options                                                                                                                                   │ │
│ │ 8. Update RecipeEditingView - Ensure manual recipe creation assigns "New recipes" by default                                                                                                                               │ │
│ │ 9. Create CategoryPicker Component - Reusable category selection UI with create new option                                                                                                                                 │ │
│ │ 10. Update Share Extension - Ensure imported recipes get "New recipes" category                                                                                                                                            │ │
│ │                                                                                                                                                                                                                            │ │
│ │ Phase 3: Categories Tab & Navigation                                                                                                                                                                                       │ │
│ │                                                                                                                                                                                                                            │ │
│ │ 11. Replace Search Tab with Categories - Update MainTabView with new categories icon/tab                                                                                                                                   │ │
│ │ 12. Create CategoriesView - Main categories screen with grouped recipe display                                                                                                                                             │ │
│ │ 13. Implement Category Filtering - Show recipes by selected category                                                                                                                                                       │ │
│ │ 14. Add Category Management UI - Create/rename/delete categories with validation                                                                                                                                           │ │
│ │ 15. Sort & Display Logic - "New recipes" first, then A-Z sorting                                                                                                                                                           │ │
│ │                                                                                                                                                                                                                            │ │
│ │ Phase 4: Category Management Features                                                                                                                                                                                      │ │
│ │                                                                                                                                                                                                                            │ │
│ │ 16. Category Delete Logic - Reassign orphaned recipes to "New recipes"                                                                                                                                                     │ │
│ │ 17. Validation Rules - 1-32 chars, trimmed, case-insensitive uniqueness                                                                                                                                                    │ │
│ │ 18. Bulk Recipe Actions - Select multiple recipes to change categories                                                                                                                                                     │ │
│ │ 19. Share Extension Updates - Ensure proper category assignment for shared recipes                                                                                                                                         │ │
│ │ 20. Testing & Polish - Ensure smooth UX across all category operations                                                                                                                                                     │ │
│ │                                                                                                                                                                                                                            │ │
│ │ Implementation Approach:                                                                                                                                                                                                   │ │
│ │                                                                                                                                                                                                                            │ │
│ │ - Minimal disruption - Backward compatible with existing recipes                                                                                                                                                           │ │
│ │ - Simple architecture - Leverage existing JSON storage pattern                                                                                                                                                             │ │
│ │ - Clean UI - Follow Apple HIG and existing app design patterns                                                                                                                                                             │ │
│ │ - Incremental rollout - Each phase is functional independently                                                                                                                                                             │ │
│ │                                                                                                                                                                                                                            │ │
│ │ This plan maintains simplicity while adding powerful organization features.    