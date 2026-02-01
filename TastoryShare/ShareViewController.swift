//
//  ShareViewController.swift
//  TastoryShare
//
//  Created by Denis Radabolski on 7/24/25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation

// Note: These files must be added to the TastoryShare target in Xcode:
// - Recipe.swift
// - RecipeStorageManager.swift
// - WebScrapingService.swift
// - OpenAIService.swift
// - RecipeExtractionService.swift

// MARK: - Tastory UIKit Design System

struct TastoryUIColors {
    static let primaryGreen = UIColor(red: 27/255, green: 109/255, blue: 63/255, alpha: 1) // #1B6D3F
    static let lightGreenBg = UIColor(red: 232/255, green: 245/255, blue: 239/255, alpha: 1) // #E8F5EF
    static let background = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1) // #F5F5F5
    static let cardBackground = UIColor.white
    static let primaryText = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1) // #1A1A1A
    static let secondaryText = UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1) // #6B7280
    static let errorRed = UIColor(red: 220/255, green: 38/255, blue: 38/255, alpha: 1) // #DC2626
}

struct TastoryUISpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct TastoryUIRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let button: CGFloat = 24
}

struct TastoryUIButtonHeight {
    static let primary: CGFloat = 56
    static let secondary: CGFloat = 48
}

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
    private var tipsStackView: UIStackView!
    private var tipsLabel: UILabel!
    private var saveButton: UIButton!
    
    private var extractedURLs: [URL] = []
    private var extractedImages: [UIImage] = []
    private var extractedText: String = ""
    private var processedRecipe: Recipe?
    
    // Services
    private let recipeExtractionService = RecipeExtractionService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        setupUI()
        extractSharedContent()
    }
    
    private func createUI() {
        view.backgroundColor = TastoryUIColors.background

        // Create centered icon container
        let iconContainer = UIView()
        iconContainer.backgroundColor = TastoryUIColors.lightGreenBg
        iconContainer.layer.cornerRadius = 50
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(image: UIImage(systemName: "fork.knife"))
        iconImageView.tintColor = TastoryUIColors.primaryGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        // Create Title Label
        titleLabel = UILabel()
        titleLabel.text = "Adding Recipe"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = TastoryUIColors.primaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create Status Label
        statusLabel = UILabel()
        statusLabel.text = "Processing shared content..."
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        statusLabel.textColor = TastoryUIColors.secondaryText
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create Progress View
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.5
        progressView.tintColor = TastoryUIColors.primaryGreen
        progressView.translatesAutoresizingMaskIntoConstraints = false

        // Create Cancel Button (secondary style)
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(TastoryUIColors.primaryGreen, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1.5
        cancelButton.layer.borderColor = TastoryUIColors.primaryGreen.cgColor
        cancelButton.layer.cornerRadius = TastoryUIRadius.button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        // Create Open App Button (primary style)
        openAppButton = UIButton(type: .system)
        openAppButton.setTitle("Open Tastory AI", for: .normal)
        openAppButton.setTitleColor(.white, for: .normal)
        openAppButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        openAppButton.backgroundColor = TastoryUIColors.primaryGreen
        openAppButton.layer.cornerRadius = TastoryUIRadius.button
        openAppButton.translatesAutoresizingMaskIntoConstraints = false

        // Add all views to the main view
        view.addSubview(iconContainer)
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(progressView)
        view.addSubview(cancelButton)
        view.addSubview(openAppButton)

        // Setup Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Icon container - centered
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: TastoryUISpacing.xl),
            iconContainer.widthAnchor.constraint(equalToConstant: 100),
            iconContainer.heightAnchor.constraint(equalToConstant: 100),

            // Icon inside container
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            // Title Label - below icon
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: TastoryUISpacing.lg),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TastoryUISpacing.md),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TastoryUISpacing.md),

            // Status Label - below title with spacing
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: TastoryUISpacing.sm),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TastoryUISpacing.md),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TastoryUISpacing.md),

            // Progress View - below status with spacing
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: TastoryUISpacing.lg),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TastoryUISpacing.xl),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TastoryUISpacing.xl),

            // Open App Button - below progress with spacing
            openAppButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: TastoryUISpacing.xl),
            openAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TastoryUISpacing.md),
            openAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TastoryUISpacing.md),
            openAppButton.heightAnchor.constraint(equalToConstant: TastoryUIButtonHeight.primary),

            // Cancel Button - at bottom
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -TastoryUISpacing.md),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TastoryUISpacing.md),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TastoryUISpacing.md),
            cancelButton.heightAnchor.constraint(equalToConstant: TastoryUIButtonHeight.secondary)
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
        
        var urls: [URL] = []
        var images: [UIImage] = []
        var collectedText = ""
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
                            urls.append(url)
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
                            collectedText += text + "\n"
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
                            images.append(image)
                        } else if let image = data as? UIImage {
                            print("✅ Extracted UIImage directly")
                            images.append(image)
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
                            collectedText += text + "\n"
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            print("🎯 Content extraction complete:")
            print("   URLs: \(urls.count)")
            print("   Images: \(images.count)")
            print("   Text length: \(collectedText.count)")
            
            self.extractedURLs = urls
            self.extractedImages = images
            self.extractedText = collectedText
            self.processExtractedContent()
        }
    }
    
    private func processExtractedContent() {
        if extractedURLs.isEmpty && extractedImages.isEmpty && extractedText.isEmpty {
            showError("No content found to process")
            return
        }
        
        // Update UI to show what we found
        var statusText = "Found: "
        if !extractedURLs.isEmpty {
            statusText += "\(extractedURLs.count) URL(s) "
        }
        if !extractedImages.isEmpty {
            statusText += "\(extractedImages.count) image(s) "
        }
        if !extractedText.isEmpty {
            statusText += "text content "
        }
        
        statusLabel?.text = statusText
        
        // Process content with RecipeExtractionService
        processWithRecipeExtraction()
    }
    
    private func processWithRecipeExtraction() {
        statusLabel?.text = "Importing..."
        progressView?.progress = 0.1
        
        print("🔄 Starting recipe extraction...")
        
        Task {
            do {
                // RecipeExtractionService doesn't have onProgressUpdate
                // We'll just show a simple progress indicator
                
                // Process using RecipeExtractionService
                let recipe = try await recipeExtractionService.processSharedContent(
                    urls: extractedURLs,
                    images: [], // Images handled separately for now
                    text: extractedText,
                    videos: [] // Videos not supported yet
                )
                
                print("✅ Recipe processed: \(recipe.title)")
                
                await MainActor.run {
                    self.processedRecipe = recipe
                    self.showRecipeEditingUI()
                }
                
            } catch {
                print("❌ Recipe extraction failed: \(error.localizedDescription)")
                
                await MainActor.run {
                    self.showError("Failed to process recipe: \(error.localizedDescription)")
                }
            }
        }
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
        scrollView.backgroundColor = TastoryUIColors.background

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Header card
        let headerCard = createCard()

        // Recipe image
        recipeImageView = UIImageView()
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = TastoryUIRadius.medium
        recipeImageView.backgroundColor = TastoryUIColors.lightGreenBg
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false

        // Title field
        recipeTitleField = UITextField()
        recipeTitleField.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        recipeTitleField.textColor = TastoryUIColors.primaryText
        recipeTitleField.placeholder = "Recipe Title"
        recipeTitleField.borderStyle = .none
        recipeTitleField.translatesAutoresizingMaskIntoConstraints = false

        headerCard.addSubview(recipeImageView)
        headerCard.addSubview(recipeTitleField)

        // Ingredients card
        let ingredientsCard = createCard()

        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "Ingredients"
        ingredientsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        ingredientsLabel.textColor = TastoryUIColors.primaryText
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false

        ingredientsStackView = UIStackView()
        ingredientsStackView.axis = .vertical
        ingredientsStackView.spacing = TastoryUISpacing.sm
        ingredientsStackView.translatesAutoresizingMaskIntoConstraints = false

        ingredientsCard.addSubview(ingredientsLabel)
        ingredientsCard.addSubview(ingredientsStackView)

        // Instructions card
        let stepsCard = createCard()

        let stepsLabel = UILabel()
        stepsLabel.text = "Instructions"
        stepsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        stepsLabel.textColor = TastoryUIColors.primaryText
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false

        stepsStackView = UIStackView()
        stepsStackView.axis = .vertical
        stepsStackView.spacing = TastoryUISpacing.md
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false

        stepsCard.addSubview(stepsLabel)
        stepsCard.addSubview(stepsStackView)

        // Tips card (light green background)
        let tipsCard = createCard()
        tipsCard.backgroundColor = TastoryUIColors.lightGreenBg

        tipsLabel = UILabel()
        tipsLabel.text = "Tips & Notes"
        tipsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tipsLabel.textColor = TastoryUIColors.primaryText
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false

        tipsStackView = UIStackView()
        tipsStackView.axis = .vertical
        tipsStackView.spacing = TastoryUISpacing.md
        tipsStackView.translatesAutoresizingMaskIntoConstraints = false

        tipsCard.addSubview(tipsLabel)
        tipsCard.addSubview(tipsStackView)

        // Save button (primary style)
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Recipe", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = TastoryUIColors.primaryGreen
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        saveButton.layer.cornerRadius = TastoryUIRadius.button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveRecipe), for: .touchUpInside)

        // Add all views
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerCard)
        contentView.addSubview(ingredientsCard)
        contentView.addSubview(stepsCard)
        contentView.addSubview(tipsCard)

        // Add save button to main view (fixed position)
        view.addSubview(saveButton)

        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -TastoryUISpacing.md),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Header card
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: TastoryUISpacing.md),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TastoryUISpacing.md),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TastoryUISpacing.md),

            // Recipe image inside header
            recipeImageView.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: TastoryUISpacing.md),
            recipeImageView.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: TastoryUISpacing.md),
            recipeImageView.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -TastoryUISpacing.md),
            recipeImageView.widthAnchor.constraint(equalToConstant: 100),
            recipeImageView.heightAnchor.constraint(equalToConstant: 100),

            // Title field inside header
            recipeTitleField.centerYAnchor.constraint(equalTo: recipeImageView.centerYAnchor),
            recipeTitleField.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: TastoryUISpacing.md),
            recipeTitleField.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -TastoryUISpacing.md),

            // Ingredients card
            ingredientsCard.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: TastoryUISpacing.md),
            ingredientsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TastoryUISpacing.md),
            ingredientsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TastoryUISpacing.md),

            ingredientsLabel.topAnchor.constraint(equalTo: ingredientsCard.topAnchor, constant: TastoryUISpacing.md),
            ingredientsLabel.leadingAnchor.constraint(equalTo: ingredientsCard.leadingAnchor, constant: TastoryUISpacing.md),
            ingredientsLabel.trailingAnchor.constraint(equalTo: ingredientsCard.trailingAnchor, constant: -TastoryUISpacing.md),

            ingredientsStackView.topAnchor.constraint(equalTo: ingredientsLabel.bottomAnchor, constant: TastoryUISpacing.md),
            ingredientsStackView.leadingAnchor.constraint(equalTo: ingredientsCard.leadingAnchor, constant: TastoryUISpacing.md),
            ingredientsStackView.trailingAnchor.constraint(equalTo: ingredientsCard.trailingAnchor, constant: -TastoryUISpacing.md),
            ingredientsStackView.bottomAnchor.constraint(equalTo: ingredientsCard.bottomAnchor, constant: -TastoryUISpacing.md),

            // Steps card
            stepsCard.topAnchor.constraint(equalTo: ingredientsCard.bottomAnchor, constant: TastoryUISpacing.md),
            stepsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TastoryUISpacing.md),
            stepsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TastoryUISpacing.md),

            stepsLabel.topAnchor.constraint(equalTo: stepsCard.topAnchor, constant: TastoryUISpacing.md),
            stepsLabel.leadingAnchor.constraint(equalTo: stepsCard.leadingAnchor, constant: TastoryUISpacing.md),
            stepsLabel.trailingAnchor.constraint(equalTo: stepsCard.trailingAnchor, constant: -TastoryUISpacing.md),

            stepsStackView.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: TastoryUISpacing.md),
            stepsStackView.leadingAnchor.constraint(equalTo: stepsCard.leadingAnchor, constant: TastoryUISpacing.md),
            stepsStackView.trailingAnchor.constraint(equalTo: stepsCard.trailingAnchor, constant: -TastoryUISpacing.md),
            stepsStackView.bottomAnchor.constraint(equalTo: stepsCard.bottomAnchor, constant: -TastoryUISpacing.md),

            // Tips card
            tipsCard.topAnchor.constraint(equalTo: stepsCard.bottomAnchor, constant: TastoryUISpacing.md),
            tipsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: TastoryUISpacing.md),
            tipsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -TastoryUISpacing.md),
            tipsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -TastoryUISpacing.md),

            tipsLabel.topAnchor.constraint(equalTo: tipsCard.topAnchor, constant: TastoryUISpacing.md),
            tipsLabel.leadingAnchor.constraint(equalTo: tipsCard.leadingAnchor, constant: TastoryUISpacing.md),
            tipsLabel.trailingAnchor.constraint(equalTo: tipsCard.trailingAnchor, constant: -TastoryUISpacing.md),

            tipsStackView.topAnchor.constraint(equalTo: tipsLabel.bottomAnchor, constant: TastoryUISpacing.md),
            tipsStackView.leadingAnchor.constraint(equalTo: tipsCard.leadingAnchor, constant: TastoryUISpacing.md),
            tipsStackView.trailingAnchor.constraint(equalTo: tipsCard.trailingAnchor, constant: -TastoryUISpacing.md),
            tipsStackView.bottomAnchor.constraint(equalTo: tipsCard.bottomAnchor, constant: -TastoryUISpacing.md),

            // Save button
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: TastoryUISpacing.md),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -TastoryUISpacing.md),
            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -TastoryUISpacing.sm),
            saveButton.heightAnchor.constraint(equalToConstant: TastoryUIButtonHeight.primary)
        ])
    }

    private func createCard() -> UIView {
        let card = UIView()
        card.backgroundColor = TastoryUIColors.cardBackground
        card.layer.cornerRadius = TastoryUIRadius.large
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
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

        // Add tips
        for tip in recipe.tips {
            addTipRow(text: tip)
        }

        // Load the recipe image if available
        if let imageURLString = recipe.imageURL, let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL)
        } else {
            // Set a placeholder image with Tastory styling
            recipeImageView.image = UIImage(systemName: "photo")
            recipeImageView.tintColor = TastoryUIColors.primaryGreen
            recipeImageView.contentMode = .center
        }
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                DispatchQueue.main.async {
                    self?.recipeImageView.image = UIImage(systemName: "photo")
                    self?.recipeImageView.tintColor = UIColor.systemGray3
                }
                return
            }
            
            DispatchQueue.main.async {
                self.recipeImageView.image = image
                self.recipeImageView.contentMode = .scaleAspectFill
            }
        }
        task.resume()
    }
    
    private func addIngredientRow(text: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Green bullet
        let bulletView = UIView()
        bulletView.backgroundColor = TastoryUIColors.primaryGreen
        bulletView.layer.cornerRadius = 4
        bulletView.translatesAutoresizingMaskIntoConstraints = false

        let textField = UITextField()
        textField.text = text
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = TastoryUIColors.primaryText
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(bulletView)
        containerView.addSubview(textField)

        NSLayoutConstraint.activate([
            bulletView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bulletView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bulletView.widthAnchor.constraint(equalToConstant: 8),
            bulletView.heightAnchor.constraint(equalToConstant: 8),

            textField.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: TastoryUISpacing.md),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36)
        ])

        ingredientsStackView.addArrangedSubview(containerView)
    }

    private func addStepRow(number: Int, text: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Green number badge
        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        numberLabel.textColor = .white
        numberLabel.backgroundColor = TastoryUIColors.primaryGreen
        numberLabel.textAlignment = .center
        numberLabel.layer.cornerRadius = 14
        numberLabel.clipsToBounds = true
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = TastoryUIColors.primaryText
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
            numberLabel.widthAnchor.constraint(equalToConstant: 28),
            numberLabel.heightAnchor.constraint(equalToConstant: 28),

            textView.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: TastoryUISpacing.md),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])

        stepsStackView.addArrangedSubview(containerView)
    }
    
    private func addTipRow(text: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Lightbulb icon in green circle
        let iconContainer = UIView()
        iconContainer.backgroundColor = TastoryUIColors.primaryGreen.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 14
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        iconImageView.tintColor = TastoryUIColors.primaryGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        let textView = UITextView()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = TastoryUIColors.primaryText
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconContainer)
        containerView.addSubview(textView)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 28),
            iconContainer.heightAnchor.constraint(equalToConstant: 28),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),

            textView.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: TastoryUISpacing.md),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])

        tipsStackView.addArrangedSubview(containerView)
    }
    
    @objc private func saveRecipe() {
        guard let originalRecipe = processedRecipe else { return }
        
        // Collect updated data
        let updatedTitle = recipeTitleField.text ?? originalRecipe.title
        var updatedIngredients: [String] = []
        var updatedSteps: [String] = []
        var updatedTips: [String] = []
        
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
        
        // Collect tips from text views
        for case let containerView as UIView in tipsStackView.arrangedSubviews {
            for subview in containerView.subviews {
                if let textView = subview as? UITextView, !textView.text.isEmpty {
                    updatedTips.append(textView.text)
                }
            }
        }
        
        // Create updated recipe - assign default "New recipes" category
        let updatedRecipe = Recipe(
            id: originalRecipe.id,
            title: updatedTitle,
            ingredients: updatedIngredients.isEmpty ? originalRecipe.ingredients : updatedIngredients,
            steps: updatedSteps.isEmpty ? originalRecipe.steps : updatedSteps,
            imageURL: originalRecipe.imageURL,
            categoryIds: originalRecipe.categoryIds,
            primaryCategoryId: originalRecipe.primaryCategoryId,
            category: originalRecipe.category,
            servings: originalRecipe.servings,
            sourceURL: originalRecipe.sourceURL,
            tips: updatedTips.isEmpty ? originalRecipe.tips : updatedTips,
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