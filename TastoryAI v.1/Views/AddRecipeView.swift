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
                TastoryColors.background
                    .ignoresSafeArea()

                VStack(spacing: TastorySpacing.xxl) {
                    VStack(spacing: TastorySpacing.lg) {
                        Text("Add a Recipe")
                            .font(TastoryTypography.largeTitle)
                            .foregroundColor(TastoryColors.primaryText)

                        Text("Choose how you'd like to add your recipe")
                            .font(TastoryTypography.body)
                            .foregroundColor(TastoryColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, TastorySpacing.xxl)

                    VStack(spacing: TastorySpacing.md) {
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
                    .padding(.horizontal, TastorySpacing.lg)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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
            HStack(spacing: TastorySpacing.md) {
                // Icon in light green circle
                ZStack {
                    Circle()
                        .fill(TastoryColors.lightGreenBg)
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: TastoryIconSize.large))
                        .foregroundColor(TastoryColors.primaryGreen)
                }

                VStack(alignment: .leading, spacing: TastorySpacing.xxs) {
                    Text(title)
                        .font(TastoryTypography.headline)
                        .foregroundColor(TastoryColors.primaryText)

                    Text(subtitle)
                        .font(TastoryTypography.callout)
                        .foregroundColor(TastoryColors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(TastoryColors.tertiaryText)
            }
            .padding(TastorySpacing.md)
            .background(TastoryColors.cardBackground)
            .cornerRadius(TastoryRadius.large)
            .tastoryShadow(TastoryShadow.small)
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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                if extractionService.isProcessing {
                    // Full-screen loading view
                    TastoryLoadingView(
                        title: "Importing Recipe",
                        message: extractionService.processingStatus,
                        showProgress: true,
                        progress: extractionService.processingProgress
                    )
                } else {
                    VStack(spacing: TastorySpacing.lg) {
                        VStack(spacing: TastorySpacing.md) {
                            Text("Add Recipe from URL")
                                .font(TastoryTypography.title)
                                .foregroundColor(TastoryColors.primaryText)

                            Text("Paste a link from any recipe website, Instagram, TikTok, or other cooking source")
                                .font(TastoryTypography.body)
                                .foregroundColor(TastoryColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, TastorySpacing.lg)

                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            Text("Recipe URL")
                                .font(TastoryTypography.headline)
                                .foregroundColor(TastoryColors.primaryText)

                            TextField("https://www.example.com/recipe", text: $urlText)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(TastorySpacing.md)
                                .background(TastoryColors.cardBackground)
                                .cornerRadius(TastoryRadius.medium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: TastoryRadius.medium)
                                        .stroke(TastoryColors.border, lineWidth: 1)
                                )

                            // Paste from clipboard button
                            Button(action: pasteFromClipboard) {
                                HStack(spacing: TastorySpacing.xs) {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Paste from Clipboard")
                                }
                                .font(TastoryTypography.callout)
                                .foregroundColor(TastoryColors.primaryGreen)
                            }

                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.errorRed)
                            }
                        }
                        .padding(.horizontal, TastorySpacing.lg)

                        TastoryButton(
                            title: "Import Recipe",
                            style: .primary,
                            icon: "arrow.down.circle.fill",
                            isDisabled: !isValidURL,
                            action: processURL
                        )
                        .padding(.horizontal, TastorySpacing.lg)

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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

    private func pasteFromClipboard() {
        if let clipboardText = UIPasteboard.general.string {
            urlText = clipboardText
        }
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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                if isProcessingOCR || extractionService.isProcessing {
                    // Full-screen loading view
                    TastoryLoadingView(
                        title: "Extracting Recipe",
                        message: getProcessingText(),
                        icon: "doc.text.magnifyingglass",
                        showProgress: extractionService.isProcessing,
                        progress: extractionService.processingProgress
                    )
                } else {
                    ScrollView {
                        VStack(spacing: TastorySpacing.lg) {
                            VStack(spacing: TastorySpacing.md) {
                                Text("Add Recipe from Photo")
                                    .font(TastoryTypography.title)
                                    .foregroundColor(TastoryColors.primaryText)

                                Text("Take a photo or select from your library to extract recipe details")
                                    .font(TastoryTypography.body)
                                    .foregroundColor(TastoryColors.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, TastorySpacing.lg)

                            // Image Selection Area
                            TastoryCard {
                                VStack(spacing: TastorySpacing.md) {
                                    if let selectedImage = selectedImage {
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 200)
                                            .cornerRadius(TastoryRadius.medium)
                                    } else {
                                        RoundedRectangle(cornerRadius: TastoryRadius.medium)
                                            .fill(TastoryColors.border)
                                            .frame(height: 200)
                                            .overlay(
                                                VStack(spacing: TastorySpacing.sm) {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: TastoryIconSize.xLarge))
                                                        .foregroundColor(TastoryColors.tertiaryText)

                                                    Text("No image selected")
                                                        .font(TastoryTypography.callout)
                                                        .foregroundColor(TastoryColors.tertiaryText)
                                                }
                                            )
                                    }

                                    TastoryButton(
                                        title: selectedImage == nil ? "Select Photo" : "Change Photo",
                                        style: .secondary,
                                        icon: "camera.fill",
                                        action: { isShowingActionSheet = true }
                                    )
                                }
                            }
                            .padding(.horizontal, TastorySpacing.lg)

                            // Process Button
                            if selectedImage != nil {
                                TastoryButton(
                                    title: extractedText.isEmpty ? "Extract Recipe" : "Generate Recipe",
                                    style: .primary,
                                    icon: "text.viewfinder",
                                    action: processImage
                                )
                                .padding(.horizontal, TastorySpacing.lg)
                            }

                            // Extracted Text Display
                            if !extractedText.isEmpty {
                                TastoryCard {
                                    VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                                        Text("Extracted Text:")
                                            .font(TastoryTypography.headline)
                                            .foregroundColor(TastoryColors.primaryText)

                                        Text(extractedText)
                                            .font(TastoryTypography.bodyRegular)
                                            .foregroundColor(TastoryColors.primaryText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .padding(.horizontal, TastorySpacing.lg)
                            }

                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.errorRed)
                                    .padding(.horizontal, TastorySpacing.lg)
                            }
                        }
                        .padding(.bottom, TastorySpacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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