//
//  OpenAIService.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

struct OpenAIError: Codable {
    let error: OpenAIErrorDetail
}

struct OpenAIErrorDetail: Codable {
    let message: String
    let type: String
    let code: String?
}

@MainActor
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o"
    private let maxTokens = 2000
    private let temperature = 0.1
    
    // Rate limiting: 10 requests per minute per user
    private var requestQueue: [Date] = []
    private let maxRequestsPerMinute = 10
    private let rateLimitWindow: TimeInterval = 60 // 1 minute
    
    private init() {}
    
    // MARK: - API Key Management
    
    private var apiKey: String? {
        // Try to get from build configuration (xcconfig)
        if let configKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
           !configKey.isEmpty && configKey != "YOUR_API_KEY_HERE" {
            print("✅ OpenAI API Key loaded from configuration: \(String(configKey.prefix(10)))...")
            return configKey
        }
        
        print("❌ OpenAI API Key not found or invalid")
        return nil
    }
    
    private func validateAPIKey() throws {
        guard let _ = apiKey, !apiKey!.isEmpty else {
            throw OpenAIServiceError.missingAPIKey
        }
    }
    
    // MARK: - Rate Limiting
    
    private func checkRateLimit() throws {
        let now = Date()
        
        // Remove requests older than the rate limit window
        requestQueue = requestQueue.filter { request in
            now.timeIntervalSince(request) < rateLimitWindow
        }
        
        // Check if we're at the rate limit
        if requestQueue.count >= maxRequestsPerMinute {
            throw OpenAIServiceError.rateLimitExceeded
        }
        
        // Add current request to queue
        requestQueue.append(now)
    }
    
    // MARK: - API Communication
    
    func generateRecipeFromText(_ text: String) async throws -> String {
        try validateAPIKey()
        try checkRateLimit()
        
        let prompt = """
        Extract recipe information from the following text and return it in this exact JSON format:
        
        {
          "title": "Recipe Name",
          "ingredients": ["ingredient 1", "ingredient 2"],
          "steps": ["step 1", "step 2"],
          "tips": ["tip 1", "tip 2"],
          "category": "category name or null",
          "servings": 4
        }
        
        Rules:
        - Extract only actual recipe content, ignore ads or unrelated text
        - Ingredients MUST include quantities and units in standardized format
        - If there is no list of ingredients with their volumes, try to find mentions of these ingredients in the recipe description and extract the volumes from the description.
        - Use standard units: cups, tablespoons (tbsp), teaspoons (tsp), ounces (oz), pounds (lbs), grams (g)
        - Format ingredients as: "2 cups flour" NOT "flour (2 cups)" or "flour - 2 cups"
        - Use consistent quantity formats: "1/2 cup", "1.5 cups", "2 cups" (no ranges like "1-2 cups")
        - Steps should be clear and sequential, playful and with all information that will be needed for cooking.
        - Tips should be helpful cooking advice that's NOT actual steps - things like temperature notes, storage tips, ingredient substitutions, technique advice, or serving suggestions
        - Return only the JSON, no additional text
        - If no valid recipe is found, return: {"error": "No recipe found"}
        
        Text to process:
        \(text)
        """
        
        let messages = [
            OpenAIMessage(role: "system", content: "You are a helpful assistant that extracts recipe information from text and returns structured JSON data."),
            OpenAIMessage(role: "user", content: prompt)
        ]
        
        let request = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens
        )
        
        return try await performRequest(request)
    }
    
    func generateRecipeFromURL(_ url: String, content: String) async throws -> String {
        try validateAPIKey()
        try checkRateLimit()
        
        let prompt = """
        Extract recipe information from this web content and return it in this exact JSON format:
        
        {
          "title": "Recipe Name",
          "ingredients": ["ingredient 1", "ingredient 2"],
          "steps": ["step 1", "step 2"],
          "tips": ["tip 1", "tip 2"],
          "category": "category name or null",
          "servings": 4,
          "sourceURL": "\(url)"
        }
        
        Rules:
        - Look for structured data (JSON-LD, microdata) first
        - Ingredients MUST include quantities and units in standardized format
        - If there is no list of ingredients with their volumes, try to find mentions of these ingredients in the recipe description and extract the volumes from the description.
        - Use standard units: cups, tablespoons (tbsp), teaspoons (tsp), ounces (oz), pounds (lbs), grams (g)
        - Format ingredients as: "2 cups flour" NOT "flour (2 cups)" or "flour - 2 cups"
        - Use consistent quantity formats: "1/2 cup", "1.5 cups", "2 cups" (no ranges like "1-2 cups")
        - Steps should be clear and sequential, playful and with all information that will be needed for cooking.
        - Tips should be helpful cooking advice that's NOT actual steps - things like temperature notes, storage tips, ingredient substitutions, technique advice, or serving suggestions
        - Extract existing tips from the webpage
        - Always include the provided sourceURL in the response
        - Ignore ads, comments, and unrelated content
        - Return only the JSON, no additional text
        - If no valid recipe is found, return: {"error": "No recipe found"}
        
        Source URL: \(url)
        
        Web content:
        \(content)
        """
        
        let messages = [
            OpenAIMessage(role: "system", content: "You are a helpful assistant that extracts recipe information from web content and returns structured JSON data."),
            OpenAIMessage(role: "user", content: prompt)
        ]
        
        let request = OpenAIRequest(
            model: model,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens
        )
        
        return try await performRequest(request)
    }
    
    private func performRequest(_ request: OpenAIRequest) async throws -> String {
        print("🔄 Starting OpenAI API request...")
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid URL: \(baseURL)")
            throw OpenAIServiceError.invalidURL
        }
        
        guard let apiKey = apiKey else {
            print("❌ Missing API key")
            throw OpenAIServiceError.missingAPIKey
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let requestData = try JSONEncoder().encode(request)
            urlRequest.httpBody = requestData
            
            print("📤 Sending request to OpenAI with \(request.messages.count) messages")
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw OpenAIServiceError.invalidResponse
            }
            
            print("📥 Received response with status code: \(httpResponse.statusCode)")
            
            // Handle HTTP errors
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ API request successful")
                break
            case 401:
                print("❌ Unauthorized - check your API key")
                throw OpenAIServiceError.unauthorizedAPIKey
            case 429:
                print("❌ Rate limit exceeded")
                throw OpenAIServiceError.rateLimitExceeded
            case 500...599:
                print("❌ Server error: \(httpResponse.statusCode)")
                throw OpenAIServiceError.serverError
            default:
                print("❌ HTTP error: \(httpResponse.statusCode)")
                throw OpenAIServiceError.httpError(httpResponse.statusCode)
            }
            
            // Try to parse OpenAI response
            do {
                let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                
                guard let firstChoice = openAIResponse.choices.first else {
                    print("❌ No response content in API response")
                    throw OpenAIServiceError.noResponseContent
                }
                
                print("✅ Successfully extracted response: \(String(firstChoice.message.content.prefix(100)))...")
                return firstChoice.message.content
                
            } catch {
                // Try to parse error response
                if let errorResponse = try? JSONDecoder().decode(OpenAIError.self, from: data) {
                    print("❌ OpenAI API error: \(errorResponse.error.message)")
                    throw OpenAIServiceError.apiError(errorResponse.error.message)
                }
                
                // Log raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Failed to parse response: \(String(responseString.prefix(200)))...")
                }
                
                print("❌ Parse error: \(error.localizedDescription)")
                throw OpenAIServiceError.parseError(error)
            }
            
        } catch let error as OpenAIServiceError {
            throw error
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw OpenAIServiceError.networkError(error)
        }
    }
}

// MARK: - Error Types

enum OpenAIServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case noResponseContent
    case rateLimitExceeded
    case unauthorizedAPIKey
    case serverError
    case httpError(Int)
    case networkError(Error)
    case parseError(Error)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Please configure your API key."
        case .invalidURL:
            return "Invalid API URL."
        case .invalidResponse:
            return "Invalid response from OpenAI API."
        case .noResponseContent:
            return "No content in OpenAI response."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please wait a moment before trying again."
        case .unauthorizedAPIKey:
            return "Invalid API key. Please check your OpenAI API key."
        case .serverError:
            return "OpenAI server error. Please try again later."
        case .httpError(let code):
            return "HTTP error \(code). Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parseError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .apiError(let message):
            return "OpenAI API error: \(message)"
        }
    }
}