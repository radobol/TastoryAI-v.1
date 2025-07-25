//
//  WebScrapingService.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation

@MainActor
class WebScrapingService: ObservableObject {
    static let shared = WebScrapingService()
    
    private let session: URLSession
    private let timeout: TimeInterval = 30.0
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        ]
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    func extractContent(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw WebScrapingError.invalidURL
        }
        
        // Check if it's a supported platform
        let platform = detectPlatform(from: url)
        
        do {
            // Fetch the HTML content
            let htmlContent = try await fetchHTML(from: url)
            
            // Extract content based on platform
            switch platform {
            case .instagram:
                return try extractInstagramContent(from: htmlContent, url: url)
            case .tiktok:
                return try extractTikTokContent(from: htmlContent, url: url)
            case .youtube:
                return try extractYouTubeContent(from: htmlContent, url: url)
            case .recipeWebsite:
                return try extractRecipeWebsiteContent(from: htmlContent, url: url)
            case .general:
                return try extractGeneralContent(from: htmlContent, url: url)
            }
            
        } catch {
            throw WebScrapingError.contentExtractionFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchHTML(from url: URL) async throws -> String {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WebScrapingError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw WebScrapingError.httpError(httpResponse.statusCode)
            }
            
            // Try to detect encoding from response headers
            let encoding = detectEncoding(from: httpResponse, data: data)
            
            guard let html = String(data: data, encoding: encoding) else {
                throw WebScrapingError.encodingError
            }
            
            return html
            
        } catch let error as WebScrapingError {
            throw error
        } catch {
            throw WebScrapingError.networkError(error.localizedDescription)
        }
    }
    
    private func detectPlatform(from url: URL) -> Platform {
        let host = url.host?.lowercased() ?? ""
        
        if host.contains("instagram.com") {
            return .instagram
        } else if host.contains("tiktok.com") {
            return .tiktok
        } else if host.contains("youtube.com") || host.contains("youtu.be") {
            return .youtube
        } else if isRecipeWebsite(host: host) {
            return .recipeWebsite
        } else {
            return .general
        }
    }
    
    private func isRecipeWebsite(host: String) -> Bool {
        let recipeHosts = [
            "allrecipes.com", "foodnetwork.com", "epicurious.com",
            "bonappetit.com", "seriouseats.com", "food.com",
            "delish.com", "tasty.co", "buzzfeed.com",
            "marthastewart.com", "cookinglight.com", "eatingwell.com"
        ]
        
        return recipeHosts.contains { host.contains($0) }
    }
    
    private func detectEncoding(from response: HTTPURLResponse, data: Data) -> String.Encoding {
        // Check Content-Type header
        if let contentType = response.value(forHTTPHeaderField: "Content-Type") {
            if contentType.lowercased().contains("charset=utf-8") {
                return .utf8
            }
        }
        
        // Try to detect from HTML meta tags
        if let htmlString = String(data: data.prefix(1024), encoding: .utf8) {
            if htmlString.lowercased().contains("charset=utf-8") {
                return .utf8
            }
        }
        
        return .utf8 // Default fallback
    }
    
    // MARK: - Platform-Specific Extraction
    
    private func extractInstagramContent(from html: String, url: URL) throws -> String {
        var content = "Instagram Post: \(url.absoluteString)\n\n"
        
        // Try to extract JSON-LD data first
        if let jsonLD = extractJSONLD(from: html) {
            content += "Structured Data:\n\(jsonLD)\n\n"
        }
        
        // Extract meta description (often contains post caption)
        if let description = extractMetaContent(from: html, property: "description") {
            content += "Description: \(description)\n\n"
        }
        
        // Extract Open Graph description
        if let ogDescription = extractMetaContent(from: html, property: "og:description") {
            content += "Caption: \(ogDescription)\n\n"
        }
        
        // Try to extract post text from script tags
        if let scriptContent = extractInstagramScriptData(from: html) {
            content += "Post Content:\n\(scriptContent)\n\n"
        }
        
        return content.isEmpty ? "No content extracted from Instagram post" : content
    }
    
    private func extractTikTokContent(from html: String, url: URL) throws -> String {
        var content = "TikTok Video: \(url.absoluteString)\n\n"
        
        // Extract meta description
        if let description = extractMetaContent(from: html, property: "description") {
            content += "Description: \(description)\n\n"
        }
        
        // Extract video title/caption
        if let title = extractMetaContent(from: html, property: "og:title") {
            content += "Title: \(title)\n\n"
        }
        
        // Try to extract from script tags
        if let scriptContent = extractTikTokScriptData(from: html) {
            content += "Video Content:\n\(scriptContent)\n\n"
        }
        
        return content.isEmpty ? "No content extracted from TikTok video" : content
    }
    
    private func extractYouTubeContent(from html: String, url: URL) throws -> String {
        var content = "YouTube Video: \(url.absoluteString)\n\n"
        
        // Extract video title
        if let title = extractMetaContent(from: html, property: "og:title") {
            content += "Title: \(title)\n\n"
        }
        
        // Extract video description
        if let description = extractMetaContent(from: html, property: "og:description") {
            content += "Description: \(description)\n\n"
        }
        
        return content.isEmpty ? "No content extracted from YouTube video" : content
    }
    
    private func extractRecipeWebsiteContent(from html: String, url: URL) throws -> String {
        var content = "Recipe Website: \(url.absoluteString)\n\n"
        
        // Try JSON-LD first (most reliable for recipes)
        if let jsonLD = extractRecipeJSONLD(from: html) {
            content += "Recipe Data (JSON-LD):\n\(jsonLD)\n\n"
            return content
        }
        
        // Try microdata
        if let microdata = extractRecipeMicrodata(from: html) {
            content += "Recipe Data (Microdata):\n\(microdata)\n\n"
            return content
        }
        
        // Fallback to general extraction
        return try extractGeneralContent(from: html, url: url)
    }
    
    private func extractGeneralContent(from html: String, url: URL) throws -> String {
        var content = "Web Page: \(url.absoluteString)\n\n"
        
        // Extract title
        if let title = extractTitle(from: html) {
            content += "Title: \(title)\n\n"
        }
        
        // Extract meta description
        if let description = extractMetaContent(from: html, property: "description") {
            content += "Description: \(description)\n\n"
        }
        
        // Extract main content (remove scripts, styles, nav, etc.)
        let cleanContent = cleanHTML(html)
        if !cleanContent.isEmpty {
            content += "Content:\n\(cleanContent)\n"
        }
        
        return content
    }
    
    // MARK: - HTML Parsing Utilities
    
    private func extractJSONLD(from html: String) -> String? {
        let pattern = #"<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>"#
        return extractWithRegex(from: html, pattern: pattern, groupIndex: 1)
    }
    
    private func extractRecipeJSONLD(from html: String) -> String? {
        guard let jsonLD = extractJSONLD(from: html) else { return nil }
        
        // Check if it contains recipe data
        if jsonLD.lowercased().contains("recipe") {
            return jsonLD
        }
        
        return nil
    }
    
    private func extractRecipeMicrodata(from html: String) -> String? {
        // Look for Recipe microdata
        let pattern = #"<[^>]*itemtype=["\']https?://schema\.org/Recipe["\'][^>]*>.*?</[^>]*>"#
        return extractWithRegex(from: html, pattern: pattern, groupIndex: 0)
    }
    
    private func extractMetaContent(from html: String, property: String) -> String? {
        let patterns = [
            #"<meta[^>]*name=["\']" + property + #"["\'][^>]*content=["\']([^"\']*)["\'][^>]*/?>"#,
            #"<meta[^>]*property=["\']" + property + #"["\'][^>]*content=["\']([^"\']*)["\'][^>]*/?>"#,
            #"<meta[^>]*content=["\']([^"\']*)["\'][^>]*name=["\']" + property + #"["\'][^>]*/?>"#,
            #"<meta[^>]*content=["\']([^"\']*)["\'][^>]*property=["\']" + property + #"["\'][^>]*/?>"#
        ]
        
        for pattern in patterns {
            if let result = extractWithRegex(from: html, pattern: pattern, groupIndex: 1) {
                return result.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return nil
    }
    
    private func extractTitle(from html: String) -> String? {
        let pattern = #"<title[^>]*>(.*?)</title>"#
        return extractWithRegex(from: html, pattern: pattern, groupIndex: 1)
    }
    
    private func extractInstagramScriptData(from html: String) -> String? {
        // Instagram often stores data in script tags with window._sharedData
        let pattern = #"window\._sharedData\s*=\s*({.*?});"#
        return extractWithRegex(from: html, pattern: pattern, groupIndex: 1)
    }
    
    private func extractTikTokScriptData(from html: String) -> String? {
        // TikTok stores data in script tags
        let pattern = #"window\.__INITIAL_STATE__\s*=\s*({.*?});"#
        return extractWithRegex(from: html, pattern: pattern, groupIndex: 1)
    }
    
    private func extractWithRegex(from text: String, pattern: String, groupIndex: Int) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSRange(text.startIndex..., in: text)
            
            if let match = regex.firstMatch(in: text, options: [], range: range) {
                if groupIndex < match.numberOfRanges {
                    let matchRange = match.range(at: groupIndex)
                    if let swiftRange = Range(matchRange, in: text) {
                        return String(text[swiftRange])
                    }
                }
            }
        } catch {
            // Regex compilation failed
        }
        
        return nil
    }
    
    private func cleanHTML(_ html: String) -> String {
        var cleaned = html
        
        // Remove script and style tags
        let removePatterns = [
            #"<script[^>]*>.*?</script>"#,
            #"<style[^>]*>.*?</style>"#,
            #"<nav[^>]*>.*?</nav>"#,
            #"<header[^>]*>.*?</header>"#,
            #"<footer[^>]*>.*?</footer>"#,
            #"<!--.*?-->"#
        ]
        
        for pattern in removePatterns {
            cleaned = cleaned.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        // Remove HTML tags but keep content
        cleaned = cleaned.replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )
        
        // Clean up whitespace
        cleaned = cleaned.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        
        // Decode HTML entities
        cleaned = decodeHTMLEntities(cleaned)
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func decodeHTMLEntities(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }
}

// MARK: - Supporting Types

extension WebScrapingService {
    enum Platform {
        case instagram
        case tiktok
        case youtube
        case recipeWebsite
        case general
    }
}

enum WebScrapingError: LocalizedError {
    case invalidURL
    case networkError(String)
    case invalidResponse
    case httpError(Int)
    case encodingError
    case contentExtractionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "HTTP error \(code)"
        case .encodingError:
            return "Failed to decode response content."
        case .contentExtractionFailed(let message):
            return "Content extraction failed: \(message)"
        }
    }
}