# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Development Guide for Tastory AI

## Core Principles
- **Keep the UI clean and simple** - single input, clear output
- **Ensure mobile responsiveness** for creators on-the-go
- **Prioritize simplicity** in every code change and design decision
- **Follow Apple UI best practices** and iOS design guidelines
- **Use modern SwiftUI** patterns and components

## Standard Development Workflow


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

## Technical Guidelines

### Architecture
- **Platform**: Native SwiftUI for iOS/iPadOS
- **Backend**: Supabase (Postgres, Auth, Storage, Edge Functions)
- **AI Service**: OpenAI GPT-4o 
- **Auth**: Sign in with Apple or Google (optional) sign-in 


### UI/UX Requirements
- Modern digital cookbook aesthetic with notes-like feel
- Clean, minimal, and functional design
- Prioritize clarity, whitespace, and typography
- Visual hierarchy: ingredients and steps over metadata
- ShadCN-style components: neutral tones, soft shadows, rounded corners
- Fully responsive between iPhone and iPad (portrait/landscape)

### Features to Implement
1. **Recipe Capture**
   - Share Sheet integration (Instagram, TikTok, URLs)
   - Photo/Camera import with OCR
   - Manual entry with smart paste detection

2. **AI Processing**
   - Structured recipe extraction (title, ingredients, steps, tips)
   - Auto-categorization and tagging
   - Rate limiting (10 req/min/user)

3. **Recipe Management**
   - CRUD operations with editable fields
   - US/Metric unit toggle
   - Dynamic serving size scaling
   - Custom categories and tags
   - Share recipe via system sheet (Mail, SMS, WhatsApp, Messenger, etc.).

4. **Search & Organization**
   - Full-text search
   - Filter by category/tag
   - Grid view with category chips


### Performance Requirements
- Cold start ≤ 2 seconds
- Recipe capture ≤ 5 seconds on 4G
- 60 fps scrolling
- 99.9% API uptime

### Security & Privacy
- TLS encryption in transit
- AES-256 encryption at rest
- Row-level security in Supabase
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
