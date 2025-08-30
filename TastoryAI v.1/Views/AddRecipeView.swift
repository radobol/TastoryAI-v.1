//
//  AddRecipeView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI
import Vision

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingManualEntry = false
    @State private var showingURLEntry = false
    @State private var showingPhotoEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.xLarge) {
                    VStack(spacing: Theme.Spacing.large) {
                        Text("Add a Recipe")
                            .font(Typography.Title1.bold)
                            .foregroundColor(Theme.Colors.text)
                        
                        Text("Choose how you'd like to add your recipe")
                            .font(Typography.Body.regular)
                            .foregroundColor(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Theme.Spacing.xLarge)
                    
                    VStack(spacing: Theme.Spacing.medium) {
                        AddOptionButton(
                            icon: "link",
                            title: "From URL",
                            subtitle: "Paste a link from any website",
                            action: { showingURLEntry = true }
                        )
                        
                        AddOptionButton(
                            icon: "camera.fill",
                            title: "From Photo",
                            subtitle: "Take or select a photo",
                            action: { showingPhotoEntry = true }
                        )
                        
                        AddOptionButton(
                            icon: "square.and.pencil",
                            title: "Manual Entry",
                            subtitle: "Type or paste your recipe",
                            action: { showingManualEntry = true }
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.large)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualRecipeEntryView()
        }
        .sheet(isPresented: $showingURLEntry) {
            URLRecipeEntryView()
        }
        .sheet(isPresented: $showingPhotoEntry) {
            PhotoRecipeEntryView()
        }
    }
}

struct ManualRecipeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = RecipeStorageManager.shared
    
    var body: some View {
        RecipeEditingView(
            recipe: Recipe(
                title: "",
                ingredients: [""],
                steps: [""],
                categoryIds: [CategoryManager.shared.getNewRecipesCategory().id],
                primaryCategoryId: CategoryManager.shared.getNewRecipesCategory().id,
                servings: 4
            ),
            onSave: { recipe in
                storageManager.addRecipe(recipe)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
    }
}

struct AddOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(Theme.Colors.accent.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                    Text(title)
                        .font(Typography.Headline.regular)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text(subtitle)
                        .font(Typography.Subheadline.regular)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.tertiaryText)
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(
                color: Theme.Shadow.small.color,
                radius: Theme.Shadow.small.radius,
                x: Theme.Shadow.small.x,
                y: Theme.Shadow.small.y
            )
        }
    }
}

struct URLRecipeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var extractionService = RecipeExtractionService.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @State private var urlText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingRecipeEditor = false
    @State private var extractedRecipe: Recipe?
    
    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.large) {
                VStack(spacing: Theme.Spacing.medium) {
                    Text("Add Recipe from URL")
                        .font(Typography.Title2.bold)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text("Paste a link from any recipe website, Instagram, TikTok, or other cooking source")
                        .font(Typography.Body.regular)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.Spacing.large)
                
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Recipe URL")
                        .font(Typography.Subheadline.semibold)
                        .foregroundColor(Theme.Colors.text)
                    
                    TextField("https://www.example.com/recipe", text: $urlText)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(Typography.Caption1.regular)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
                
                Button(action: processURL) {
                    HStack {
                        if extractionService.isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 16))
                        }
                        
                        Text(extractionService.isProcessing ? extractionService.processingStatus : "Import Recipe")
                            .font(Typography.Subheadline.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                            .fill(isValidURL && !extractionService.isProcessing ? Theme.Colors.accent : Theme.Colors.tertiaryText)
                    )
                }
                .disabled(!isValidURL || extractionService.isProcessing)
                .padding(.horizontal, Theme.Spacing.large)
                
                // Progress indicator
                if extractionService.isProcessing {
                    VStack(spacing: Theme.Spacing.small) {
                        ProgressView(value: extractionService.processingProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal, Theme.Spacing.large)
                        
                        Text(extractionService.processingStatus)
                            .font(Typography.Caption1.regular)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
                
                Spacer()
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .onAppear {
                // Auto-paste from clipboard if it contains a URL
                if let clipboardText = UIPasteboard.general.string,
                   isValidURLString(clipboardText) {
                    urlText = clipboardText
                }
            }
            .sheet(isPresented: $showingRecipeEditor) {
                if let recipe = extractedRecipe {
                    RecipeEditingView(
                        recipe: recipe,
                        onSave: { updatedRecipe in
                            storageManager.addRecipe(updatedRecipe)
                            showingRecipeEditor = false
                            dismiss()
                        },
                        onCancel: {
                            showingRecipeEditor = false
                            urlText = ""
                            errorMessage = nil
                            extractedRecipe = nil
                        }
                    )
                }
            }
        }
    }
    
    private var isValidURL: Bool {
        isValidURLString(urlText)
    }
    
    private func isValidURLString(_ string: String) -> Bool {
        guard let url = URL(string: string.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased() else {
            return false
        }
        return scheme == "http" || scheme == "https"
    }
    
    private func processURL() {
        guard isValidURL else { return }
        
        errorMessage = nil
        
        Task {
            do {
                let recipe = try await extractionService.processURL(urlText.trimmingCharacters(in: .whitespacesAndNewlines))
                
                await MainActor.run {
                    extractedRecipe = recipe
                    showingRecipeEditor = true
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct PhotoRecipeEntryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var extractionService = RecipeExtractionService.shared
    @StateObject private var storageManager = RecipeStorageManager.shared
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isShowingActionSheet = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isProcessingOCR = false
    @State private var extractedText = ""
    @State private var errorMessage: String?
    @State private var showingRecipeEditor = false
    @State private var extractedRecipe: Recipe?
    
    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.large) {
                VStack(spacing: Theme.Spacing.medium) {
                    Text("Add Recipe from Photo")
                        .font(Typography.Title2.bold)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text("Take a photo or select from your library to extract recipe details")
                        .font(Typography.Body.regular)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.Spacing.large)
                
                // Image Selection Area
                VStack(spacing: Theme.Spacing.medium) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(Theme.CornerRadius.medium)
                            .shadow(
                                color: Theme.Shadow.small.color,
                                radius: Theme.Shadow.small.radius,
                                x: Theme.Shadow.small.x,
                                y: Theme.Shadow.small.y
                            )
                    } else {
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                            .fill(Theme.Colors.tertiaryBackground)
                            .frame(height: 200)
                            .overlay(
                                VStack(spacing: Theme.Spacing.small) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(Theme.Colors.tertiaryText)
                                    
                                    Text("No image selected")
                                        .font(Typography.Subheadline.regular)
                                        .foregroundColor(Theme.Colors.tertiaryText)
                                }
                            )
                    }
                    
                    Button(action: { isShowingActionSheet = true }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                            Text(selectedImage == nil ? "Select Photo" : "Change Photo")
                                .font(Typography.Subheadline.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .fill(Theme.Colors.accent)
                        )
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
                
                // Process Button
                if selectedImage != nil {
                    VStack(spacing: Theme.Spacing.medium) {
                        Button(action: processImage) {
                            HStack {
                                if isProcessingOCR || extractionService.isProcessing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "text.viewfinder")
                                        .font(.system(size: 16))
                                }
                                
                                Text(getProcessingText())
                                    .font(Typography.Subheadline.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                    .fill((isProcessingOCR || extractionService.isProcessing) ? Theme.Colors.tertiaryText : Theme.Colors.accent)
                            )
                        }
                        .disabled(isProcessingOCR || extractionService.isProcessing)
                        .padding(.horizontal, Theme.Spacing.large)
                        
                        // AI Processing Progress
                        if extractionService.isProcessing {
                            VStack(spacing: Theme.Spacing.small) {
                                ProgressView(value: extractionService.processingProgress)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .padding(.horizontal, Theme.Spacing.large)
                                
                                Text(extractionService.processingStatus)
                                    .font(Typography.Caption1.regular)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                        }
                    }
                }
                
                // Extracted Text Display
                if !extractedText.isEmpty {
                    VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                        Text("Extracted Text:")
                            .font(Typography.Subheadline.semibold)
                            .foregroundColor(Theme.Colors.text)
                        
                        ScrollView {
                            Text(extractedText)
                                .font(Typography.Body.regular)
                                .foregroundColor(Theme.Colors.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(Theme.Spacing.medium)
                                .background(Theme.Colors.secondaryBackground)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                        .frame(maxHeight: 150)
                    }
                    .padding(.horizontal, Theme.Spacing.large)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(Typography.Caption1.regular)
                        .foregroundColor(.red)
                        .padding(.horizontal, Theme.Spacing.large)
                }
                
                Spacer()
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .confirmationDialog("Select Image Source", isPresented: $isShowingActionSheet) {
                Button("Camera") {
                    imageSourceType = .camera
                    isShowingImagePicker = true
                }
                Button("Photo Library") {
                    imageSourceType = .photoLibrary
                    isShowingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: imageSourceType)
            }
            .sheet(isPresented: $showingRecipeEditor) {
                if let recipe = extractedRecipe {
                    RecipeEditingView(
                        recipe: recipe,
                        onSave: { updatedRecipe in
                            storageManager.addRecipe(updatedRecipe)
                            showingRecipeEditor = false
                            dismiss()
                        },
                        onCancel: {
                            showingRecipeEditor = false
                            selectedImage = nil
                            extractedText = ""
                            errorMessage = nil
                            extractedRecipe = nil
                        }
                    )
                }
            }
        }
    }
    
    private func getProcessingText() -> String {
        if isProcessingOCR {
            return "Extracting text..."
        } else if extractionService.isProcessing {
            return extractionService.processingStatus
        } else if !extractedText.isEmpty {
            return "Generate Recipe"
        } else {
            return "Extract Recipe"
        }
    }
    
    private func processImage() {
        guard let selectedImage = selectedImage else { return }
        
        if extractedText.isEmpty {
            // First extract text using OCR
            performOCR(on: selectedImage)
        } else {
            // Text already extracted, process with AI
            processWithAI()
        }
    }
    
    private func performOCR(on image: UIImage) {
        isProcessingOCR = true
        errorMessage = nil
        extractedText = ""
        
        // Convert UIImage to CGImage
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.isProcessingOCR = false
                self.errorMessage = "Failed to process image. Please try a different image."
            }
            return
        }
        
        // Create Vision text recognition request
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.isProcessingOCR = false
                
                if let error = error {
                    self.errorMessage = "OCR failed: \(error.localizedDescription)"
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    self.errorMessage = "No text found in the image."
                    return
                }
                
                // Extract text from observations
                let recognizedText = observations.compactMap { observation in
                    return observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                if recognizedText.isEmpty {
                    self.errorMessage = "No readable text found in the image."
                } else {
                    self.extractedText = recognizedText
                    // Automatically proceed to AI processing
                    self.processWithAI()
                }
            }
        }
        
        // Configure request for better accuracy
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        
        // Perform the request
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessingOCR = false
                    self.errorMessage = "OCR processing failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func processWithAI() {
        guard let image = selectedImage, !extractedText.isEmpty else { return }
        
        errorMessage = nil
        
        Task {
            do {
                let recipe = try await extractionService.processImage(image, withExtractedText: extractedText)
                
                await MainActor.run {
                    extractedRecipe = recipe
                    showingRecipeEditor = true
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddRecipeView()
}