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
- **Ingredient Database**: USDA FoodData Central API integration for missing ingredients 


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

2. **AI Processing** ✅ **COMPLETED**
   - ✅ Structured recipe extraction (title, ingredients, steps, tips) - OpenAI GPT-4o integration with secure xcconfig API key management
   - ✅ Multi-modal processing pipeline - Text, URL, OCR, and Share Extension content processing
   - ✅ Rate limiting (10 req/min/user) - Implemented with queue system and user feedback
   - ✅ Web scraping service - Platform-specific extraction for Instagram, TikTok, recipe sites
   - ✅ Share Extension recipe editing - Full UI with editable fields matching ReciMe design
   

3. **Recipe Management** ✅ **COMPLETED**
   - ✅ CRUD operations with editable fields - Full RecipeStorageManager with JSON persistence
   - [ ] US/Metric unit toggle - Planned for Phase 2B with IngredientParser extension
   - ✅ Dynamic serving size scaling - Enhanced IngredientParser with local ingredient database and fuzzy matching
   - ✅ Local ingredient database - 100 common cooking ingredients with scaling properties
   - ✅ Share recipe via system sheet - Built-in iOS share integration

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

6. **iCloud Sync System** **PLANNED**
   
   ### Overview
   Implement JSON + iCloud Documents sync for seamless multi-device recipe synchronization while maintaining full offline support and protecting existing user data.
   
   ### Architecture Decision
   - **Storage**: JSON files in iCloud Documents container (not CloudKit)
   - **Sync**: Automatic via iOS iCloud Documents
   - **Fallback**: Local storage when iCloud unavailable
   - **Migration**: Safe, non-destructive upgrade for existing users
   
   ### Implementation Requirements
   
   #### Phase 1: Core iCloud Setup
   - [ ] Enable iCloud capability in Xcode project
         - Add iCloud Documents container
         - Configure entitlements: com.apple.developer.icloud-container-identifiers
         - Update Info.plist with NSUbiquitousContainers configuration
   
   - [ ] Implement iCloud availability detection
         ```swift
         // Check if iCloud is available and user is signed in
         if FileManager.default.ubiquityIdentityToken != nil {
             // iCloud available
         } else {
             // Fallback to local storage
         }
         ```
   
   #### Phase 2: Migration Strategy (CRITICAL - Zero Data Loss)
   - [ ] Implement safe migration for existing users
         ```swift
         class RecipeStorageManager {
             func migrateToiCloudIfNeeded() {
                 // 1. Check if local recipes.json exists
                 // 2. Check if iCloud is available
                 // 3. Check if iCloud recipes.json already exists
                 // 4. If local exists but iCloud doesn't: copy to iCloud
                 // 5. If both exist: merge (prefer newer based on timestamps)
                 // 6. Keep local backup until migration confirmed
                 // 7. Never delete local data without user confirmation
             }
         }
         ```
   
   - [ ] Migration flow for existing users:
         1. App update detects existing local recipes.json
         2. Prompt user: "Enable iCloud sync to access recipes on all devices?"
         3. If Yes: Copy local → iCloud, verify, then use iCloud
         4. If No: Continue with local storage
         5. Option to enable later in Settings
   
   #### Phase 3: Storage Manager Updates
   - [ ] Update RecipeStorageManager for dual-mode operation
         ```swift
         private var storageMode: StorageMode = .local
         enum StorageMode {
             case local
             case iCloud
         }
         
         private var recipesFileURL: URL {
             switch storageMode {
             case .local:
                 return localRecipesURL
             case .iCloud:
                 return iCloudRecipesURL
             }
         }
         ```
   
   - [ ] Implement iCloud change monitoring
         - NSMetadataQuery for file updates
         - Conflict resolution (last-write-wins or merge)
         - Update UI when sync occurs
   
   #### Phase 4: Share Extension Compatibility
   - [ ] Update Share Extension for iCloud support
         - Check iCloud availability in extension
         - Write to same iCloud container
         - Fallback to App Groups if iCloud unavailable
   
   #### Phase 5: UI/UX Updates
   - [ ] Add sync status indicator in HomeView
         - Cloud icon with status (synced/syncing/offline)
         - Last sync timestamp
   
   - [ ] Add iCloud toggle in Settings
         - Enable/disable iCloud sync
         - Migration status for existing users
         - Manual sync button
   
   - [ ] Error handling UI
         - "No iCloud account" message
         - "Storage full" warning
         - "Sync conflict" resolution
   
   ### Technical Implementation Details
   
   #### iCloud Document Storage Path
   ```swift
   // Get iCloud container
   if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
       let documentsURL = iCloudURL.appendingPathComponent("Documents")
       let recipesURL = documentsURL.appendingPathComponent("recipes.json")
   }
   ```
   
   #### Monitoring iCloud Changes
   ```swift
   private func startMonitoringiCloud() {
       metadataQuery = NSMetadataQuery()
       metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
       metadataQuery?.predicate = NSPredicate(format: "%K LIKE 'recipes.json'", 
                                             NSMetadataItemFSNameKey)
       
       NotificationCenter.default.addObserver(
           self,
           selector: #selector(queryDidUpdate),
           name: .NSMetadataQueryDidUpdate,
           object: metadataQuery
       )
       
       metadataQuery?.start()
   }
   ```
   
   ### Testing Guidelines
   
   1. **Migration Testing**
      - Install current version with local recipes
      - Update to iCloud version
      - Verify all recipes preserved
      - Test both "Yes" and "No" to sync prompt
   
   2. **Sync Testing**
      - Add recipe on iPhone → verify appears on iPad
      - Edit recipe on iPad → verify updates on iPhone
      - Delete recipe → verify removal syncs
   
   3. **Edge Cases**
      - No iCloud account
      - iCloud storage full
      - Airplane mode / offline
      - Sign out of iCloud
      - Conflicts from simultaneous edits
   
   4. **Share Extension Testing**
      - Share recipe with iCloud enabled
      - Share recipe with iCloud disabled
      - Share recipe while offline
   
   ### Important Considerations
   
   - **Privacy**: Recipes remain in user's personal iCloud, not our servers
   - **Cost**: Free for users and developers (uses user's iCloud storage)
   - **Performance**: Local cache ensures instant access even while syncing
   - **Backwards Compatibility**: Users can disable iCloud and use local storage
   - **Data Integrity**: Always maintain local backup during migration
   
   ### Success Metrics
   - Zero data loss during migration
   - Sync completes within 5 seconds on WiFi
   - Seamless experience for non-iCloud users
   - Share Extension continues working reliably


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

## Enhanced Recipe Scaling System (Phase 2A Complete)

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

## Photo Upload and Thumbnail Management Implementation

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

This implementation prioritizes simplicity while providing comprehensive functionality across all recipe creation and editing contexts.