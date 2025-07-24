//
//  IngredientParser.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/24/25.
//

import Foundation

struct IngredientParser {
    
    // MARK: - Scalable Units
    
    private static let scalableUnits: Set<String> = [
        // Volume - Metric
        "ml", "milliliter", "milliliters", "millilitre", "millilitres",
        "l", "liter", "liters", "litre", "litres",
        "cl", "centiliter", "centiliters", "centilitre", "centilitres",
        
        // Volume - Imperial
        "cup", "cups", "c",
        "tablespoon", "tablespoons", "tbsp", "tbs", "tb",
        "teaspoon", "teaspoons", "tsp", "ts",
        "fluid ounce", "fluid ounces", "fl oz", "floz",
        "pint", "pints", "pt", "pts",
        "quart", "quarts", "qt", "qts",
        "gallon", "gallons", "gal", "gals",
        
        // Weight - Metric
        "g", "gram", "grams", "gramme", "grammes",
        "kg", "kilogram", "kilograms", "kilogramme", "kilogrammes",
        "mg", "milligram", "milligrams", "milligramme", "milligrammes",
        
        // Weight - Imperial
        "oz", "ounce", "ounces",
        "lb", "lbs", "pound", "pounds",
        
        // Generic measurements that are usually scalable
        "serving", "servings",
        "portion", "portions",
        "piece", "pieces", "pc", "pcs", // sometimes scalable
        "slice", "slices",
        "sheet", "sheets",
        "can", "cans",
        "jar", "jars",
        "bottle", "bottles",
        "pack", "packs", "package", "packages"
    ]
    
    private static let nonScalableUnits: Set<String> = [
        // Individual items that shouldn't scale
        "clove", "cloves",
        "head", "heads",
        "bulb", "bulbs",
        "bunch", "bunches",
        "sprig", "sprigs",
        "stalk", "stalks",
        "leaf", "leaves",
        "bay leaf", "bay leaves",
        "egg", "eggs", // debatable, but usually counted
        "onion", "onions",
        "carrot", "carrots",
        "potato", "potatoes",
        
        // Taste-based additions
        "to taste",
        "as needed",
        "for seasoning",
        "pinch", "pinches",
        "dash", "dashes",
        "splash", "splashes"
    ]
    
    // MARK: - Parsing Logic
    
    static func scaleIngredient(_ ingredient: String, by multiplier: Double) -> String {
        guard multiplier != 1.0 else { return ingredient }
        
        let lowercased = ingredient.lowercased()
        
        // Check if ingredient contains non-scalable indicators
        for nonScalableUnit in nonScalableUnits {
            if lowercased.contains(nonScalableUnit) {
                return ingredient // Don't scale "salt to taste", "1 clove garlic"
            }
        }
        
        return parseAndScale(ingredient, multiplier: multiplier)
    }
    
    private static func parseAndScale(_ ingredient: String, multiplier: Double) -> String {
        let components = ingredient.components(separatedBy: " ")
        var result = components
        
        // Look for quantity patterns in the first few words
        for (index, component) in components.prefix(4).enumerated() {
            if let quantity = extractQuantity(from: component) {
                let scaledQuantity = quantity * multiplier
                result[index] = formatQuantity(scaledQuantity)
                return result.joined(separator: " ")
            }
            
            // Check for mixed numbers like "1 1/2"
            if index < components.count - 1 {
                if let wholeNumber = Double(component),
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
        
        // Check if it's close to a common fraction
        let commonFractions: [(Double, String)] = [
            (0.125, "1/8"), (0.25, "1/4"), (0.333, "1/3"), (0.5, "1/2"),
            (0.667, "2/3"), (0.75, "3/4"), (1.5, "1 1/2"), (2.5, "2 1/2")
        ]
        
        for (value, fraction) in commonFractions {
            if abs(quantity - value) < 0.05 {
                return fraction
            }
        }
        
        // Check for mixed numbers
        if quantity > 1 {
            let whole = Int(quantity)
            let fractional = quantity - Double(whole)
            
            for (value, fraction) in commonFractions {
                if abs(fractional - value) < 0.05 && value < 1 {
                    return "\(whole) \(fraction)"
                }
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
    static func isScalableUnit(_ unit: String) -> Bool {
        return scalableUnits.contains(unit.lowercased())
    }
    
    static func isNonScalableUnit(_ unit: String) -> Bool {
        return nonScalableUnits.contains(unit.lowercased())
    }
}