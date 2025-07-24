//
//  ShareViewController.swift
//  TastoryShare
//
//  Created by Denis Radabolski on 7/24/25.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    private var titleLabel: UILabel!
    private var statusLabel: UILabel!
    private var progressView: UIProgressView!
    private var cancelButton: UIButton!
    private var openAppButton: UIButton!
    
    private var extractedContent: ExtractedContent?
    
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
        
        var content = ExtractedContent()
        let group = DispatchGroup()
        
        for item in extensionContext.inputItems {
            guard let inputItem = item as? NSExtensionItem else { continue }
            guard let attachments = inputItem.attachments else { continue }
            
            for attachment in attachments {
                // Handle URLs
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (data, error) in
                        if let url = data as? URL {
                            content.urls.append(url)
                        }
                        group.leave()
                    }
                }
                
                // Handle Images
                if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { (data, error) in
                        if let imageData = data as? Data, let image = UIImage(data: imageData) {
                            content.images.append(image)
                        } else if let image = data as? UIImage {
                            content.images.append(image)
                        }
                        group.leave()
                    }
                }
                
                // Handle Text
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (data, error) in
                        if let text = data as? String {
                            content.text += text + "\n"
                        }
                        group.leave()
                    }
                }
                
                // Handle Videos
                if attachment.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { (data, error) in
                        if let url = data as? URL {
                            content.videos.append(url)
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
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
        
        // TODO: In Phase 2, we'll send this content to AI processing
        // For now, show placeholder processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showSuccess()
        }
    }
    
    private func showSuccess() {
        statusLabel?.text = "Content ready for processing!"
        progressView?.isHidden = true
        openAppButton?.isHidden = false
    }
    
    private func showError(_ message: String) {
        statusLabel?.text = "Error: \(message)"
        progressView?.isHidden = true
        openAppButton?.isHidden = true
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
}
