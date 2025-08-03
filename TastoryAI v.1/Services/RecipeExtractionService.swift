//
//  RecipeExtractionService.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation
import UIKit

struct ExtractedRecipeData {
    let title: String
    let ingredients: [String]
    let steps: [String]
    let category: String?
    let tags: [String]
    let servings: Int
}

@MainActor
class RecipeExtractionService: ObservableObject {
    static let shared = RecipeExtractionService()
    
    private let openAIService = OpenAIService.shared
    private let webScrapingService = WebScrapingService.shared
    private let storageManager = RecipeStorageManager.shared
    
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var processingStatus = ""
    
    private init() {}
    
    // MARK: - Main Processing Methods
    
    func processURL(_ urlString: String) async throws -> Recipe {
        isProcessing = true
        processingProgress = 0.1
        processingStatus = "Fetching web content..."
        
        defer {
            Task {
                isProcessing = false
                processingProgress = 0.0
                processingStatus = ""
            }
        }
        
        do {
            // Step 1: Scrape web content
            let webContent = try await webScrapingService.extractContent(from: urlString)
            processingProgress = 0.4
            processingStatus = "Processing content with AI..."
            
            // Step 2: Process with AI
            let aiResponse = try await openAIService.generateRecipeFromURL(urlString, content: webContent)
            processingProgress = 0.7
            processingStatus = "Parsing recipe data..."
            
            // Step 3: Parse and validate
            let extractedData = try parseAIResponse(aiResponse)
            processingProgress = 0.9
            processingStatus = "Creating recipe..."
            
            // Step 4: Create recipe
            let recipe = createRecipe(from: extractedData)
            processingProgress = 1.0
            processingStatus = "Complete!"
            
            return recipe
            
        } catch {
            processingStatus = "Error: \(error.localizedDescription)"
            throw error
        }
    }
    
    func processText(_ text: String) async throws -> Recipe {
        isProcessing = true
        processingProgress = 0.2
        processingStatus = "Processing text with AI..."
        
        defer {
            Task {
                isProcessing = false
                processingProgress = 0.0
                processingStatus = ""
            }
        }
        
        do {
            // Process with AI
            let aiResponse = try await openAIService.generateRecipeFromText(text)
            processingProgress = 0.6
            processingStatus = "Parsing recipe data..."
            
            // Parse and validate
            let extractedData = try parseAIResponse(aiResponse)
            processingProgress = 0.9
            processingStatus = "Creating recipe..."
            
            // Create recipe
            let recipe = createRecipe(from: extractedData)
            processingProgress = 1.0
            processingStatus = "Complete!"
            
            return recipe
            
        } catch {
            processingStatus = "Error: \(error.localizedDescription)"
            throw error
        }
    }
    
    func processImage(_ image: UIImage, withExtractedText text: String) async throws -> Recipe {
        isProcessing = true
        processingProgress = 0.2
        processingStatus = "Processing image content with AI..."
        
        defer {
            Task {
                isProcessing = false
                processingProgress = 0.0
                processingStatus = ""
            }
        }
        
        do {
            // For now, process the extracted OCR text
            // In future versions, we could send the image directly to GPT-4o Vision
            let enhancedPrompt = """
            This text was extracted from a recipe image using OCR. Some characters might be incorrect due to OCR errors.
            Please clean up any obvious OCR mistakes and extract the recipe information:
            
            \(text)
            """
            
            let aiResponse = try await openAIService.generateRecipeFromText(enhancedPrompt)
            processingProgress = 0.6
            processingStatus = "Parsing recipe data..."
            
            // Parse and validate
            let extractedData = try parseAIResponse(aiResponse)
            processingProgress = 0.9
            processingStatus = "Creating recipe..."
            
            // Create recipe
            let recipe = createRecipe(from: extractedData)
            processingProgress = 1.0
            processingStatus = "Complete!"
            
            return recipe
            
        } catch {
            processingStatus = "Error: \(error.localizedDescription)"
            throw error
        }
    }
    
    func processSharedContent(urls: [URL], images: [UIImage], text: String, videos: [URL]) async throws -> Recipe {
        isProcessing = true
        processingProgress = 0.1
        processingStatus = "Processing shared content..."
        
        defer {
            Task {
                isProcessing = false
                processingProgress = 0.0
                processingStatus = ""
            }
        }
        
        do {
            var combinedContent = ""
            
            // Process URLs first (highest priority)
            if !urls.isEmpty {
                processingStatus = "Processing shared URLs..."
                for url in urls {
                    do {
                        let webContent = try await webScrapingService.extractContent(from: url.absoluteString)
                        combinedContent += "URL Content from \(url.absoluteString):\n\(webContent)\n\n"
                    } catch {
                        // Continue with other content if URL fails
                        continue
                    }
                }
                processingProgress = 0.4
            }
            
            // Add text content
            if !text.isEmpty {
                combinedContent += "Text Content:\n\(text)\n\n"
            }
            
            // For images, we would need OCR processing here
            // For now, skip images in shared content (handled separately in photo flow)
            
            if combinedContent.isEmpty {
                throw RecipeExtractionError.noContentFound
            }
            
            processingStatus = "Processing content with AI..."
            processingProgress = 0.6
            
            // Process with AI - use URL-specific method if URLs are present
            let aiResponse: String
            if !urls.isEmpty, let firstURL = urls.first {
                // Use URL-specific processing for better structured data extraction
                aiResponse = try await openAIService.generateRecipeFromURL(firstURL.absoluteString, content: combinedContent)
            } else {
                // Use general text processing for non-URL content
                aiResponse = try await openAIService.generateRecipeFromText(combinedContent)
            }
            processingProgress = 0.8
            processingStatus = "Parsing recipe data..."
            
            // Parse and validate
            let extractedData = try parseAIResponse(aiResponse)
            processingProgress = 0.9
            processingStatus = "Creating recipe..."
            
            // Create recipe
            let recipe = createRecipe(from: extractedData)
            processingProgress = 1.0
            processingStatus = "Complete!"
            
            return recipe
            
        } catch {
            processingStatus = "Error: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseAIResponse(_ response: String) throws -> ExtractedRecipeData {
        // Clean response - remove any markdown formatting or extra text
        let cleanedResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw RecipeExtractionError.invalidResponse
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let json = json else {
                throw RecipeExtractionError.invalidJSON
            }
            
            // Check for error response
            if let errorMessage = json["error"] as? String {
                throw RecipeExtractionError.noRecipeFound(errorMessage)
            }
            
            // Parse recipe data
            guard let title = json["title"] as? String, !title.isEmpty else {
                throw RecipeExtractionError.missingTitle
            }
            
            guard let ingredients = json["ingredients"] as? [String], !ingredients.isEmpty else {
                throw RecipeExtractionError.missingIngredients
            }
            
            guard let steps = json["steps"] as? [String], !steps.isEmpty else {
                throw RecipeExtractionError.missingSteps
            }
            
            let category = json["category"] as? String
            let tags = (json["tags"] as? [String]) ?? []
            let servings = (json["servings"] as? Int) ?? 4
            
            return ExtractedRecipeData(
                title: title,
                ingredients: ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                steps: steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                category: category?.isEmpty == true ? nil : category,
                tags: tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                servings: max(1, min(20, servings)) // Clamp servings between 1-20
            )
            
        } catch let error as RecipeExtractionError {
            throw error
        } catch {
            throw RecipeExtractionError.parseError(error.localizedDescription)
        }
    }
    
    private func createRecipe(from data: ExtractedRecipeData) -> Recipe {
        return Recipe(
            title: data.title,
            ingredients: data.ingredients,
            steps: data.steps,
            category: data.category,
            tags: data.tags,
            servings: data.servings
        )
    }
    
    // MARK: - Convenience Methods
    
    func extractAndSaveRecipe(from urlString: String) async throws -> Recipe {
        let recipe = try await processURL(urlString)
        await MainActor.run {
            storageManager.addRecipe(recipe)
        }
        return recipe
    }
    
    func extractAndSaveRecipe(fromText text: String) async throws -> Recipe {
        let recipe = try await processText(text)
        await MainActor.run {
            storageManager.addRecipe(recipe)
        }
        return recipe
    }
    
    func extractAndSaveRecipe(fromImage image: UIImage, withText text: String) async throws -> Recipe {
        let recipe = try await processImage(image, withExtractedText: text)
        await MainActor.run {
            storageManager.addRecipe(recipe)
        }
        return recipe
    }
}

// MARK: - Error Types

enum RecipeExtractionError: LocalizedError {
    case noContentFound
    case invalidResponse
    case invalidJSON
    case noRecipeFound(String)
    case missingTitle
    case missingIngredients
    case missingSteps
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .noContentFound:
            return "No content found to process."
        case .invalidResponse:
            return "Invalid response from AI service."
        case .invalidJSON:
            return "Could not parse AI response as JSON."
        case .noRecipeFound(let message):
            return "No recipe found: \(message)"
        case .missingTitle:
            return "Recipe title is missing or empty."
        case .missingIngredients:
            return "Recipe ingredients are missing or empty."
        case .missingSteps:
            return "Recipe steps are missing or empty."
        case .parseError(let message):
            return "Failed to parse recipe data: \(message)"
        }
    }
}