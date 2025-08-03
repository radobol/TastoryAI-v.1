//
//  IngredientParser.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation

struct IngredientParser {
    
    private static let database = IngredientDatabaseManager.shared
    
    // MARK: - Non-scalable Patterns
    
    private static let nonScalablePatterns: [String] = [
        "to taste",
        "as needed",
        "for seasoning",
        "pinch",
        "dash",
        "splash"
    ]
    
    // MARK: - Parsing Logic
    
    static func scaleIngredient(_ ingredient: String, by multiplier: Double) -> String {
        guard multiplier != 1.0 else { return ingredient }
        
        let lowercased = ingredient.lowercased()
        
        // Check for non-scalable patterns first (these override database settings)
        for pattern in nonScalablePatterns {
            if lowercased.contains(pattern) {
                return ingredient // Don't scale "salt to taste", "as needed", etc.
            }
        }
        
        return parseAndScale(ingredient, multiplier: multiplier)
    }
    
    private static func parseAndScale(_ ingredient: String, multiplier: Double) -> String {
        let components = ingredient.components(separatedBy: " ")
        var result = components
        
        // First, check for mixed numbers like "1 1/2" (higher priority)
        for (index, component) in components.prefix(3).enumerated() {
            if index < components.count - 1 {
                if let wholeNumber = Double(component),
                   wholeNumber.truncatingRemainder(dividingBy: 1) == 0, // Ensure it's a whole number
                   let fraction = extractFraction(from: components[index + 1]) {
                    let totalQuantity = wholeNumber + fraction
                    let scaledQuantity = totalQuantity * multiplier
                    let formattedQuantity = formatQuantity(scaledQuantity)
                    
                    // Replace both the whole number and fraction with scaled result
                    result[index] = formattedQuantity
                    result.remove(at: index + 1)
                    return result.joined(separator: " ")
                }
            }
        }
        
        // Then look for single quantities (including fractions and units like "400g")
        for (index, component) in components.prefix(4).enumerated() {
            if let quantity = extractQuantity(from: component) {
                let scaledQuantity = quantity * multiplier
                
                // Handle different types of quantities
                if component.contains("/") {
                    // It's a fraction, just replace with scaled result
                    result[index] = formatQuantity(scaledQuantity)
                } else if component.contains("-") {
                    // It's a range, replace entire component with scaled average
                    result[index] = formatQuantity(scaledQuantity)
                } else {
                    // Check for attached units like "400g"
                    // Extract the number part from the original component to find units
                    let numberPattern = "^([0-9]*\\.?[0-9]+)"
                    if let regex = try? NSRegularExpression(pattern: numberPattern),
                       let match = regex.firstMatch(in: component, range: NSRange(component.startIndex..., in: component)) {
                        let numberRange = Range(match.range(at: 1), in: component)!
                        let numberPart = String(component[numberRange])
                        let unit = String(component.dropFirst(numberPart.count))
                        if !unit.isEmpty {
                            result[index] = formatQuantity(scaledQuantity) + unit
                        } else {
                            result[index] = formatQuantity(scaledQuantity)
                        }
                    } else {
                        result[index] = formatQuantity(scaledQuantity)
                    }
                }
                return result.joined(separator: " ")
            }
        }
        
        return ingredient // Return unchanged if no quantity found
    }
    
    private static func extractQuantity(from text: String) -> Double? {
        // Handle fractions like "1/2", "3/4"
        if text.contains("/") {
            return extractFraction(from: text)
        }
        
        // Handle decimals and whole numbers
        if let number = Double(text) {
            return number
        }
        
        // Handle ranges like "2-3" (take the average)
        if text.contains("-") {
            let parts = text.components(separatedBy: "-")
            if parts.count == 2,
               let min = Double(parts[0]),
               let max = Double(parts[1]) {
                return (min + max) / 2.0
            }
        }
        
        // Handle quantities with units attached like "400g", "2lbs", "500ml"
        let numberPattern = "^([0-9]*\\.?[0-9]+)"
        if let regex = try? NSRegularExpression(pattern: numberPattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let numberRange = Range(match.range(at: 1), in: text)!
            let numberString = String(text[numberRange])
            return Double(numberString)
        }
        
        return nil
    }
    
    private static func extractFraction(from text: String) -> Double? {
        guard text.contains("/") else { return nil }
        
        let parts = text.components(separatedBy: "/")
        if parts.count == 2,
           let numerator = Double(parts[0]),
           let denominator = Double(parts[1]),
           denominator != 0 {
            return numerator / denominator
        }
        
        return nil
    }
    
    private static func formatQuantity(_ quantity: Double) -> String {
        // Handle very small quantities
        if quantity < 0.01 {
            return "pinch of"
        }
        
        // Check if it's effectively a whole number
        if abs(quantity - quantity.rounded()) < 0.01 {
            return String(Int(quantity.rounded()))
        }
        
        // Check for mixed numbers first (quantities > 1)
        if quantity > 1 {
            let whole = Int(quantity)
            let fractional = quantity - Double(whole)
            
            // Common fractions for fractional parts
            let fractions: [(Double, String)] = [
                (0.125, "1/8"), (0.25, "1/4"), (0.333, "1/3"), (0.375, "3/8"),
                (0.5, "1/2"), (0.625, "5/8"), (0.667, "2/3"), (0.75, "3/4"), (0.875, "7/8")
            ]
            
            for (value, fraction) in fractions {
                if abs(fractional - value) < 0.05 {
                    return "\(whole) \(fraction)"
                }
            }
            
            // If no common fraction matches, use decimal for fractional part
            if fractional > 0.01 {
                return String(format: "%.1f", quantity)
            } else {
                return String(whole)
            }
        }
        
        // Check if it's close to a common fraction (for quantities < 1)
        let commonFractions: [(Double, String)] = [
            (0.125, "1/8"), (0.25, "1/4"), (0.333, "1/3"), (0.375, "3/8"),
            (0.5, "1/2"), (0.625, "5/8"), (0.667, "2/3"), (0.75, "3/4"), (0.875, "7/8")
        ]
        
        for (value, fraction) in commonFractions {
            if abs(quantity - value) < 0.05 {
                return fraction
            }
        }
        
        // Default to decimal with appropriate precision
        if quantity < 10 {
            return String(format: "%.1f", quantity)
        } else {
            return String(format: "%.0f", quantity)
        }
    }
}

// MARK: - Extensions for Testing

extension IngredientParser {
    static func isIngredientScalable(_ ingredient: String) -> Bool {
        let lowercased = ingredient.lowercased()
        
        // Check for non-scalable patterns
        for pattern in nonScalablePatterns {
            if lowercased.contains(pattern) {
                return false
            }
        }
        
        // Check database
        return database.isIngredientScalable(ingredient)
    }
    
    static func findIngredientInDatabase(_ ingredient: String) -> (name: String, category: String, scalable: Bool)? {
        return database.getIngredientInfo(ingredient)
    }
}