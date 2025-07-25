//
//  ShareViewController.swift
//  TastoryShare
//
//  Created by Denis Radabolski on 7/24/25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

// Import Recipe model and services from main app target
// Note: These would need to be shared between targets in the Xcode project
struct Recipe: Identifiable, Codable {
    let id: UUID
    var title: String
    var ingredients: [String]
    var steps: [String]
    var imageURL: String?
    var category: String?
    var tags: [String]
    var servings: Int
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        ingredients: [String] = [],
        steps: [String] = [],
        imageURL: String? = nil,
        category: String? = nil,
        tags: [String] = [],
        servings: Int = 4,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.steps = steps
        self.imageURL = imageURL
        self.category = category
        self.tags = tags
        self.servings = servings
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// Shared storage manager for the extension (using same App Groups file system as main app)
class RecipeStorageManager {
    static let shared = RecipeStorageManager()
    
    private let documentsDirectory: URL
    private let recipesFileURL: URL
    
    private init() {
        // Use App Group container if available, fallback to documents directory
        if let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.tastoryai.app") {
            documentsDirectory = groupContainer
            print("✅ Share Extension using App Groups container: \(groupContainer.path)")
        } else {
            documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            print("⚠️ Share Extension falling back to documents directory")
        }
        
        recipesFileURL = documentsDirectory.appendingPathComponent("recipes.json")
        print("📁 Share Extension recipes file: \(recipesFileURL.path)")
    }
    
    func addRecipe(_ recipe: Recipe) {
        var recipes = loadRecipes()
        recipes.append(recipe)
        saveRecipes(recipes)
        print("💾 Saved recipe to App Groups: \(recipe.title)")
    }
    
    private func loadRecipes() -> [Recipe] {
        do {
            let data = try Data(contentsOf: recipesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let recipes = try decoder.decode([Recipe].self, from: data)
            print("📖 Loaded \(recipes.count) existing recipes from App Groups")
            return recipes
        } catch {
            print("📖 No existing recipes found (this is normal for first run): \(error)")
            return []
        }
    }
    
    private func saveRecipes(_ recipes: [Recipe]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(recipes)
            try data.write(to: recipesFileURL)
            print("💾 Successfully saved \(recipes.count) recipes to App Groups")
        } catch {
            print("❌ Failed to save recipes: \(error.localizedDescription)")
        }
    }
}

// Note: Complex AI processing removed from Share Extension to prevent crashes
// Share Extension now creates placeholder recipes that get processed in the main app

class ShareViewController: UIViewController {
    
    // Processing UI
    private var titleLabel: UILabel!
    private var statusLabel: UILabel!
    private var progressView: UIProgressView!
    private var cancelButton: UIButton!
    private var openAppButton: UIButton!
    
    // Recipe editing UI
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var recipeImageView: UIImageView!
    private var recipeTitleField: UITextField!
    private var ingredientsStackView: UIStackView!
    private var stepsStackView: UIStackView!
    private var saveButton: UIButton!
    
    private var extractedContent: ExtractedContent?
    private var processedRecipe: Recipe?
    
    struct ExtractedContent {
        var urls: [URL] = []
        var images: [UIImage] = []
        var text: String = ""
        var videos: [URL] = []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        setupUI()
        extractSharedContent()
    }
    
    private func createUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Create Title Label
        titleLabel = UILabel()
        titleLabel.text = "Adding Recipe to Tastory AI"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Status Label
        statusLabel = UILabel()
        statusLabel.text = "Processing shared content..."
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        statusLabel.textColor = UIColor.secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Progress View
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Cancel Button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.systemRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Open App Button
        openAppButton = UIButton(type: .system)
        openAppButton.setTitle("Open Tastory AI", for: .normal)
        openAppButton.setTitleColor(UIColor.systemBlue, for: .normal)
        openAppButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        openAppButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all views to the main view
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(progressView)
        view.addSubview(cancelButton)
        view.addSubview(openAppButton)
        
        // Setup Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Title Label - top and center
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Status Label - below title with spacing
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Progress View - below status with spacing
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Open App Button - below progress with spacing
            openAppButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 40),
            openAppButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openAppButton.heightAnchor.constraint(equalToConstant: 44),
            openAppButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            // Cancel Button - at bottom
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    private func setupUI() {
        progressView.isHidden = false
        openAppButton.isHidden = true
        
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        openAppButton.addTarget(self, action: #selector(openMainApp), for: .touchUpInside)
    }
    
    private func extractSharedContent() {
        guard let extensionContext = extensionContext else {
            showError("Unable to access shared content")
            return
        }
        
        print("🔍 Starting Share Extension content extraction...")
        
        var content = ExtractedContent()
        let group = DispatchGroup()
        
        for item in extensionContext.inputItems {
            guard let inputItem = item as? NSExtensionItem else { 
                print("❌ Failed to cast input item")
                continue 
            }
            
            print("📝 Processing input item: \(inputItem)")
            
            guard let attachments = inputItem.attachments else { 
                print("❌ No attachments found")
                continue 
            }
            
            print("📎 Found \(attachments.count) attachments")
            
            for (index, attachment) in attachments.enumerated() {
                print("📎 Processing attachment \(index + 1): \(attachment)")
                
                // Handle URLs with better error handling
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    print("🔗 Found URL attachment")
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (data, error) in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("❌ URL extraction error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let url = data as? URL {
                            print("✅ Extracted URL: \(url.absoluteString)")
                            content.urls.append(url)
                        } else {
                            print("❌ URL data is not URL type: \(String(describing: data))")
                        }
                    }
                }
                
                // Handle plain text with better debugging
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    print("📝 Found text attachment")
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (data, error) in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("❌ Text extraction error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let text = data as? String {
                            print("✅ Extracted text: \(String(text.prefix(100)))...")
                            content.text += text + "\n"
                        } else {
                            print("❌ Text data is not String type: \(String(describing: data))")
                        }
                    }
                }
                
                // Handle Images with better error handling
                if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    print("🖼️ Found image attachment")
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (data, error) in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("❌ Image extraction error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let imageData = data as? Data, let image = UIImage(data: imageData) {
                            print("✅ Extracted image from Data")
                            content.images.append(image)
                        } else if let image = data as? UIImage {
                            print("✅ Extracted UIImage directly")
                            content.images.append(image)
                        } else {
                            print("❌ Image data is not valid: \(String(describing: data))")
                        }
                    }
                }
                
                // Try to handle web pages and HTML content
                if attachment.hasItemConformingToTypeIdentifier("public.html") {
                    print("🌐 Found HTML content")
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: "public.html", options: nil) { (data, error) in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("❌ HTML extraction error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let text = data as? String {
                            print("✅ Extracted HTML: \(String(text.prefix(100)))...")
                            content.text += text + "\n"
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            print("🎯 Content extraction complete:")
            print("   URLs: \(content.urls.count)")
            print("   Images: \(content.images.count)")
            print("   Text length: \(content.text.count)")
            print("   Videos: \(content.videos.count)")
            
            self.extractedContent = content
            self.processExtractedContent()
        }
    }
    
    private func processExtractedContent() {
        guard let content = extractedContent else {
            showError("No content found to process")
            return
        }
        
        // Update UI to show what we found
        var statusText = "Found: "
        if !content.urls.isEmpty {
            statusText += "\(content.urls.count) URL(s) "
        }
        if !content.images.isEmpty {
            statusText += "\(content.images.count) image(s) "
        }
        if !content.videos.isEmpty {
            statusText += "\(content.videos.count) video(s) "
        }
        if !content.text.isEmpty {
            statusText += "text content "
        }
        
        statusLabel?.text = statusText
        
        // Process content with AI
        processWithRecipeExtraction(content: content)
    }
    
    private func processWithRecipeExtraction(content: ExtractedContent) {
        statusLabel?.text = "Importing..."
        progressView?.progress = 0.1
        
        print("🔄 Starting AI processing...")
        
        Task {
            do {
                await MainActor.run {
                    self.progressView?.progress = 0.3
                    self.statusLabel?.text = "Fetching content..."
                }
                
                var combinedContent = ""
                
                // If we have URLs, try to scrape content
                if !content.urls.isEmpty {
                    print("🌐 Processing URLs...")
                    for url in content.urls {
                        print("🔗 Processing URL: \(url.absoluteString)")
                        combinedContent += "URL: \(url.absoluteString)\n"
                        
                        // Simple URL content extraction (avoid complex web scraping in extension)
                        if let htmlContent = try? await fetchBasicContent(from: url) {
                            combinedContent += htmlContent + "\n"
                        }
                    }
                }
                
                // Add any extracted text
                if !content.text.isEmpty {
                    combinedContent += "Text Content:\n\(content.text)\n"
                }
                
                await MainActor.run {
                    self.progressView?.progress = 0.6
                    self.statusLabel?.text = "Processing with AI..."
                }
                
                // Process with OpenAI (simplified for extension)
                let recipe = try await processWithSimpleAI(content: combinedContent)
                
                await MainActor.run {
                    self.progressView?.progress = 0.9
                    self.statusLabel?.text = "Saving recipe..."
                }
                
                // Save the recipe
                RecipeStorageManager.shared.addRecipe(recipe)
                print("✅ Recipe saved: \(recipe.title)")
                
                await MainActor.run {
                    self.showSuccess(with: recipe)
                }
                
            } catch {
                print("❌ AI processing failed: \(error.localizedDescription)")
                
                await MainActor.run {
                    self.showError("Failed to process recipe: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchBasicContent(from url: URL) async throws -> String {
        print("📥 Fetching content from: \(url.absoluteString)")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        
        // Extract basic text content (remove HTML tags)
        let cleanedText = html.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return String(cleanedText.prefix(2000)) // Limit to prevent huge content
    }
    
    private func processWithSimpleAI(content: String) async throws -> Recipe {
        print("🤖 Processing with OpenAI...")
        
        let prompt = """
        Extract recipe information from this content and return ONLY a JSON object in this exact format:
        
        {
          "title": "Recipe Name",
          "ingredients": ["ingredient 1", "ingredient 2"],
          "steps": ["step 1", "step 2"],
          "category": "category name or null",
          "tags": ["tag1", "tag2"],
          "servings": 4
        }
        
        Content to process:
        \(content)
        """
        
        // Use a simplified OpenAI request for the extension
        guard let apiKey = getAPIKey() else {
            throw NSError(domain: "OpenAI", code: 1, userInfo: [NSLocalizedDescriptionKey: "API key not found"])
        }
        
        let request = createOpenAIRequest(prompt: prompt, apiKey: apiKey)
        let response = try await performSimpleOpenAIRequest(request)
        
        return try parseRecipeResponse(response)
    }
    
    private func getAPIKey() -> String? {
        // Try to get API key from main app bundle (shared xcconfig)
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            print("✅ Found API key in Share Extension: \(String(key.prefix(10)))...")
            return key
        }
        
        print("❌ No API key found in Share Extension bundle")
        return nil
    }
    
    private func createOpenAIRequest(prompt: String, apiKey: String) -> URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody = [
            "model": "gpt-4o",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.1,
            "max_tokens": 1500
        ] as [String: Any]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        return request
    }
    
    private func performSimpleOpenAIRequest(_ request: URLRequest) async throws -> String {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NSError(domain: "OpenAI", code: 2, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String
        
        return content ?? ""
    }
    
    private func parseRecipeResponse(_ response: String) throws -> Recipe {
        let cleanedResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedResponse.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "Parse", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
        }
        
        let title = json["title"] as? String ?? "Shared Recipe"
        let ingredients = json["ingredients"] as? [String] ?? ["Ingredients will be processed"]
        let steps = json["steps"] as? [String] ?? ["Steps will be processed"]
        let category = json["category"] as? String
        let tags = json["tags"] as? [String] ?? ["shared"]
        let servings = json["servings"] as? Int ?? 4
        
        return Recipe(
            title: title,
            ingredients: ingredients.filter { !$0.isEmpty },
            steps: steps.filter { !$0.isEmpty },
            category: category?.isEmpty == true ? nil : category,
            tags: tags,
            servings: servings
        )
    }
    
    private func createPlaceholderRecipe(from content: ExtractedContent) -> Recipe {
        var title = "Shared Recipe"
        var ingredients: [String] = []
        var steps: [String] = []
        
        // Extract title from text content
        if !content.text.isEmpty {
            let lines = content.text.components(separatedBy: .newlines)
            if let firstLine = lines.first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                let trimmed = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count < 100 {
                    title = trimmed
                }
            }
        }
        
        // Add content info
        if !content.urls.isEmpty {
            steps.append("Original source: \(content.urls.first?.absoluteString ?? "")")
        }
        
        if !content.text.isEmpty {
            steps.append("Shared content: \(content.text)")
        }
        
        if content.images.count > 0 {
            steps.append("Contains \(content.images.count) image(s)")
        }
        
        // Add processing note
        ingredients.append("⚠️ This recipe needs processing")
        ingredients.append("Open the main app to extract ingredients with AI")
        
        steps.append("⚠️ Recipe steps will be extracted when you open the main app")
        
        return Recipe(
            title: title,
            ingredients: ingredients,
            steps: steps,
            category: "Shared Content",
            tags: ["shared", "needs-processing"],
            servings: 1
        )
    }
    
    private func showSuccess() {
        statusLabel?.text = "Content ready for processing!"
        progressView?.isHidden = true
        openAppButton?.isHidden = false
    }
    
    private func showSuccess(with recipe: Recipe) {
        self.processedRecipe = recipe
        showRecipeEditingUI()
    }
    
    private func showError(_ message: String) {
        statusLabel?.text = "Error: \(message)"
        progressView?.isHidden = true
        openAppButton?.isHidden = false
        openAppButton?.setTitle("Try Again in Main App", for: .normal)
    }
    
    @objc private func cancelAction() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @objc private func openMainApp() {
        // TODO: Pass extracted content to main app
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        
        // For now, just complete the extension - opening URL from extension is complex
        // In Phase 2, we'll implement proper data passing to the main app
    }
    
    // MARK: - Recipe Editing UI
    
    private func showRecipeEditingUI() {
        guard let recipe = processedRecipe else { return }
        
        // Hide processing UI
        titleLabel?.isHidden = true
        statusLabel?.isHidden = true
        progressView?.isHidden = true
        openAppButton?.isHidden = true
        
        createRecipeEditingUI()
        populateRecipeData(recipe)
        
        // Update cancel button to show "Cancel" and save button to show "Save"
        cancelButton?.setTitle("Cancel", for: .normal)
    }
    
    private func createRecipeEditingUI() {
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Recipe image
        recipeImageView = UIImageView()
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.backgroundColor = UIColor.systemGray6
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title field
        recipeTitleField = UITextField()
        recipeTitleField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        recipeTitleField.textColor = UIColor.label
        recipeTitleField.placeholder = "Recipe Title"
        recipeTitleField.borderStyle = .none
        recipeTitleField.translatesAutoresizingMaskIntoConstraints = false
        
        // Ingredients section
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "INGREDIENTS"
        ingredientsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        ingredientsLabel.textColor = UIColor.secondaryLabel
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ingredientsStackView = UIStackView()
        ingredientsStackView.axis = .vertical
        ingredientsStackView.spacing = 8
        ingredientsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Steps section
        let stepsLabel = UILabel()
        stepsLabel.text = "INSTRUCTIONS"
        stepsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        stepsLabel.textColor = UIColor.secondaryLabel
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stepsStackView = UIStackView()
        stepsStackView.axis = .vertical
        stepsStackView.spacing = 12
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor.systemOrange
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveRecipe), for: .touchUpInside)
        
        // Add all views
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(recipeImageView)
        contentView.addSubview(recipeTitleField)
        contentView.addSubview(ingredientsLabel)
        contentView.addSubview(ingredientsStackView)
        contentView.addSubview(stepsLabel)
        contentView.addSubview(stepsStackView)
        
        // Add save button to main view (fixed position)
        view.addSubview(saveButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Recipe image
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recipeImageView.widthAnchor.constraint(equalToConstant: 100),
            recipeImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Title field
            recipeTitleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            recipeTitleField.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 16),
            recipeTitleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Ingredients section
            ingredientsLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 30),
            ingredientsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ingredientsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ingredientsStackView.topAnchor.constraint(equalTo: ingredientsLabel.bottomAnchor, constant: 12),
            ingredientsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ingredientsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Steps section
            stepsLabel.topAnchor.constraint(equalTo: ingredientsStackView.bottomAnchor, constant: 30),
            stepsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stepsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stepsStackView.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 12),
            stepsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stepsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stepsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Save button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func populateRecipeData(_ recipe: Recipe) {
        recipeTitleField.text = recipe.title
        
        // Add ingredients
        for ingredient in recipe.ingredients {
            addIngredientRow(text: ingredient)
        }
        
        // Add steps
        for (index, step) in recipe.steps.enumerated() {
            addStepRow(number: index + 1, text: step)
        }
        
        // Set a placeholder image (in a real app, you might extract from the shared content)
        recipeImageView.image = UIImage(systemName: "photo")
        recipeImageView.tintColor = UIColor.systemGray3
    }
    
    private func addIngredientRow(text: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: "circle"))
        iconView.tintColor = UIColor.systemGray3
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.text = text
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = UIColor.label
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconView)
        containerView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        ingredientsStackView.addArrangedSubview(containerView)
    }
    
    private func addStepRow(number: Int, text: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        numberLabel.textColor = UIColor.white
        numberLabel.backgroundColor = UIColor.systemOrange
        numberLabel.textAlignment = .center
        numberLabel.layer.cornerRadius = 15
        numberLabel.clipsToBounds = true
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.label
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(numberLabel)
        containerView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            numberLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 30),
            numberLabel.heightAnchor.constraint(equalToConstant: 30),
            
            textView.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        stepsStackView.addArrangedSubview(containerView)
    }
    
    @objc private func saveRecipe() {
        guard let originalRecipe = processedRecipe else { return }
        
        // Collect updated data
        let updatedTitle = recipeTitleField.text ?? originalRecipe.title
        var updatedIngredients: [String] = []
        var updatedSteps: [String] = []
        
        // Collect ingredients from text fields
        for case let containerView as UIView in ingredientsStackView.arrangedSubviews {
            for subview in containerView.subviews {
                if let textField = subview as? UITextField, let text = textField.text, !text.isEmpty {
                    updatedIngredients.append(text)
                }
            }
        }
        
        // Collect steps from text views
        for case let containerView as UIView in stepsStackView.arrangedSubviews {
            for subview in containerView.subviews {
                if let textView = subview as? UITextView, !textView.text.isEmpty {
                    updatedSteps.append(textView.text)
                }
            }
        }
        
        // Create updated recipe
        let updatedRecipe = Recipe(
            id: originalRecipe.id,
            title: updatedTitle,
            ingredients: updatedIngredients.isEmpty ? originalRecipe.ingredients : updatedIngredients,
            steps: updatedSteps.isEmpty ? originalRecipe.steps : updatedSteps,
            imageURL: originalRecipe.imageURL,
            category: originalRecipe.category,
            tags: originalRecipe.tags,
            servings: originalRecipe.servings,
            createdAt: originalRecipe.createdAt,
            updatedAt: Date()
        )
        
        // Save the updated recipe
        RecipeStorageManager.shared.addRecipe(updatedRecipe)
        print("✅ Updated recipe saved: \(updatedRecipe.title)")
        
        // Show success and close extension
        showFinalSuccess(with: updatedRecipe)
    }
    
    private func showFinalSuccess(with recipe: Recipe) {
        let alert = UIAlertController(
            title: "Recipe Saved!",
            message: "'\(recipe.title)' has been added to your cookbook",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        })
        
        present(alert, animated: true)
    }
}
