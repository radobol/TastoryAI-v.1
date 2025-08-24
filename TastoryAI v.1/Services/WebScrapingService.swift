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
        
        do {
            // Fetch the HTML content
            let htmlContent = try await fetchHTML(from: url)
            
            // Use unified extraction approach for all websites
            return try extractUnifiedContent(from: htmlContent, url: url)
            
        } catch {
            throw WebScrapingError.contentExtractionFailed(error.localizedDescription)
        }
    }
    
    func extractImageURL(from urlString: String) async throws -> String? {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw WebScrapingError.invalidURL
        }
        
        do {
            // Fetch the HTML content
            let htmlContent = try await fetchHTML(from: url)
            
            // Try different methods to extract image URL
            if let imageURL = extractOGImage(from: htmlContent) ?? 
                              extractTwitterImage(from: htmlContent) ?? 
                              extractJSONLDImage(from: htmlContent) ?? 
                              extractFirstContentImage(from: htmlContent) {
                // Convert relative URLs to absolute
                return normalizeImageURL(imageURL, baseURL: url)
            }
            
            return nil
            
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
    
    // MARK: - Unified Content Extraction
    
    private func extractUnifiedContent(from html: String, url: URL) throws -> String {
        var content = "Web Content: \(url.absoluteString)\n\n"
        var hasStructuredData = false
        
        // 1. Try JSON-LD first (most reliable for structured data including recipes)
        if let jsonLD = extractRecipeJSONLD(from: html) {
            content += "Recipe Data (JSON-LD):\n\(jsonLD)\n\n"
            hasStructuredData = true
        } else if let jsonLD = extractJSONLD(from: html) {
            // 2. Try general JSON-LD for any structured data
            content += "Structured Data (JSON-LD):\n\(jsonLD)\n\n"
            hasStructuredData = true
        }
        
        // 3. Try microdata as fallback for recipes
        if let microdata = extractRecipeMicrodata(from: html) {
            content += "Recipe Data (Microdata):\n\(microdata)\n\n"
            hasStructuredData = true
        }
        
        // 4. Extract standard meta content
        if let title = extractTitle(from: html) {
            content += "Title: \(title)\n\n"
        }
        
        if let description = extractMetaContent(from: html, property: "description") {
            content += "Description: \(description)\n\n"
        }
        
        if let ogTitle = extractMetaContent(from: html, property: "og:title") {
            content += "OG Title: \(ogTitle)\n\n"
        }
        
        if let ogDescription = extractMetaContent(from: html, property: "og:description") {
            content += "OG Description: \(ogDescription)\n\n"
        }
        
        // 5. Try to extract social media script data
        if let scriptContent = extractInstagramScriptData(from: html) {
            content += "Instagram Data:\n\(scriptContent)\n\n"
        }
        
        if let scriptContent = extractTikTokScriptData(from: html) {
            content += "TikTok Data:\n\(scriptContent)\n\n"
        }
        
        // 6. Always include clean content, even if we have structured data
        // This ensures we don't miss any content not in structured data
        let cleanContent = cleanHTML(html)
        if !cleanContent.isEmpty {
            content += "Page Content:\n\(cleanContent)\n"
        }
        
        return content.isEmpty ? "No content extracted from web page" : content
    }
    
    // MARK: - HTML Parsing Utilities
    
    private func extractJSONLD(from html: String) -> String? {
        let pattern = #"<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>"#
        return extractWithRegex(from: html, pattern: pattern, groupIndex: 1)
    }
    
    private func extractRecipeJSONLD(from html: String) -> String? {
        // Extract all JSON-LD blocks
        let pattern = #"<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSRange(html.startIndex..., in: html)
            let matches = regex.matches(in: html, options: [], range: range)
            
            // Check each JSON-LD block for Recipe schema
            for match in matches {
                if match.numberOfRanges > 1 {
                    let matchRange = match.range(at: 1)
                    if let swiftRange = Range(matchRange, in: html) {
                        let jsonString = String(html[swiftRange])
                        // Check if this JSON-LD contains Recipe schema
                        // Look for @type containing Recipe or recipeInstructions/recipeIngredient properties
                        if jsonString.contains("\"@type\"") && 
                           (jsonString.contains("\"Recipe\"") || 
                            jsonString.contains("recipeIngredient") || 
                            jsonString.contains("recipeInstructions")) {
                            return jsonString
                        }
                    }
                }
            }
        } catch {
            // Regex compilation failed
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
        
        // Remove script and style tags, but preserve JSON-LD
        let removePatterns = [
            #"<script(?![^>]*type=["\']application/ld\+json["\'])[^>]*>.*?</script>"#,
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
    
    // MARK: - Image Extraction Methods
    
    private func extractOGImage(from html: String) -> String? {
        if let imageURL = extractMetaContent(from: html, property: "og:image") {
            // Skip data URLs and SVG images
            if !imageURL.hasPrefix("data:") && !imageURL.contains(".svg") {
                return imageURL
            }
        }
        return nil
    }
    
    private func extractTwitterImage(from html: String) -> String? {
        if let imageURL = extractMetaContent(from: html, property: "twitter:image") {
            // Skip data URLs and SVG images
            if !imageURL.hasPrefix("data:") && !imageURL.contains(".svg") {
                return imageURL
            }
        }
        return nil
    }
    
    private func extractJSONLDImage(from html: String) -> String? {
        // Extract all JSON-LD blocks
        let pattern = #"<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSRange(html.startIndex..., in: html)
            let matches = regex.matches(in: html, options: [], range: range)
            
            for match in matches {
                if match.numberOfRanges > 1 {
                    let matchRange = match.range(at: 1)
                    if let swiftRange = Range(matchRange, in: html) {
                        let jsonString = String(html[swiftRange])
                        
                        // Try to parse JSON and extract image
                        if let data = jsonString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            
                            // Look for image in different possible locations
                            if let image = json["image"] as? String {
                                // Skip data URLs and SVG images
                                if !image.hasPrefix("data:") && !image.contains(".svg") {
                                    return image
                                }
                            } else if let imageObj = json["image"] as? [String: Any],
                                      let url = imageObj["url"] as? String {
                                // Skip data URLs and SVG images
                                if !url.hasPrefix("data:") && !url.contains(".svg") {
                                    return url
                                }
                            } else if let imageArray = json["image"] as? [[String: Any]],
                                      let firstImage = imageArray.first,
                                      let url = firstImage["url"] as? String {
                                // Skip data URLs and SVG images
                                if !url.hasPrefix("data:") && !url.contains(".svg") {
                                    return url
                                }
                            } else if let graph = json["@graph"] as? [[String: Any]] {
                                // Check in @graph array for Recipe schema
                                for item in graph {
                                    if let type = item["@type"] as? String,
                                       type.contains("Recipe") {
                                        if let image = item["image"] as? String {
                                            // Skip data URLs and SVG images
                                            if !image.hasPrefix("data:") && !image.contains(".svg") {
                                                return image
                                            }
                                        } else if let imageObj = item["image"] as? [String: Any],
                                                  let url = imageObj["url"] as? String {
                                            // Skip data URLs and SVG images
                                            if !url.hasPrefix("data:") && !url.contains(".svg") {
                                                return url
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            // Regex compilation failed
        }
        
        return nil
    }
    
    private func extractFirstContentImage(from html: String) -> String? {
        // Look for img tags in content area (excluding headers, footers, ads)
        let patterns = [
            #"<img[^>]*src=["\']([^"\']+)["\'][^>]*>"#,
            #"<img[^>]*data-src=["\']([^"\']+)["\'][^>]*>"#,  // For lazy-loaded images
            #"<img[^>]*srcset=["\']([^"\']+)["\'][^>]*>"#     // For responsive images
        ]
        
        for pattern in patterns {
            if let imageURL = extractWithRegex(from: html, pattern: pattern, groupIndex: 1) {
                // Skip small images (likely icons or buttons), data URLs, and SVG images
                if !imageURL.contains("icon") && !imageURL.contains("logo") && !imageURL.contains("avatar") 
                   && !imageURL.hasPrefix("data:") && !imageURL.contains(".svg") {
                    // For srcset, extract the first URL
                    if pattern.contains("srcset") {
                        let urls = imageURL.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                        if let firstURL = urls.first?.split(separator: " ").first {
                            let url = String(firstURL)
                            // Skip data URLs and SVG images
                            if !url.hasPrefix("data:") && !url.contains(".svg") {
                                return url
                            }
                        }
                    } else {
                        return imageURL
                    }
                }
            }
        }
        
        return nil
    }
    
    private func normalizeImageURL(_ imageURL: String, baseURL: URL) -> String {
        let trimmedURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Already absolute URL
        if trimmedURL.hasPrefix("http://") || trimmedURL.hasPrefix("https://") {
            return trimmedURL
        }
        
        // Protocol-relative URL
        if trimmedURL.hasPrefix("//") {
            return "https:" + trimmedURL
        }
        
        // Relative URL starting with /
        if trimmedURL.hasPrefix("/") {
            guard let scheme = baseURL.scheme,
                  let host = baseURL.host else {
                return trimmedURL
            }
            return "\(scheme)://\(host)\(trimmedURL)"
        }
        
        // Relative URL without /
        guard let scheme = baseURL.scheme,
              let host = baseURL.host else {
            return trimmedURL
        }
        
        let path = baseURL.path
        let basePath = path.components(separatedBy: "/").dropLast().joined(separator: "/")
        
        if basePath.isEmpty {
            return "\(scheme)://\(host)/\(trimmedURL)"
        } else {
            return "\(scheme)://\(host)\(basePath)/\(trimmedURL)"
        }
    }
}

// MARK: - Supporting Types


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