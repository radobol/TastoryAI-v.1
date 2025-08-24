//
//  ImageExtractorTestView.swift
//  TastoryAI
//
//  Created by Claude on 8/24/25.
//

import SwiftUI

struct ImageExtractorTestView: View {
    @State private var urlText = ""
    @State private var extractedImageURL = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingResult = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.large) {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Test URL")
                        .font(Typography.Headline.regular)
                        .foregroundColor(Theme.Colors.text)
                    
                    TextField("Enter recipe URL", text: $urlText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Enter a recipe website URL to test image extraction")
                        .font(Typography.Caption1.regular)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                .padding(.horizontal)
                
                Button(action: extractImage) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "photo.badge.arrow.down")
                        }
                        Text(isLoading ? "Extracting..." : "Extract Image")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
                .disabled(urlText.isEmpty || isLoading)
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(Typography.Caption1.regular)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, Theme.Spacing.small)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.small)
                    .padding(.horizontal)
                }
                
                if showingResult {
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Text("Extracted Image URL:")
                            .font(Typography.Headline.regular)
                            .foregroundColor(Theme.Colors.text)
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            Text(extractedImageURL.isEmpty ? "No image found" : extractedImageURL)
                                .font(Typography.Caption1.regular)
                                .foregroundColor(Theme.Colors.secondaryText)
                                .textSelection(.enabled)
                        }
                        .padding()
                        .background(Theme.Colors.tertiaryBackground)
                        .cornerRadius(Theme.CornerRadius.small)
                        
                        if !extractedImageURL.isEmpty, let url = URL(string: extractedImageURL) {
                            Text("Image Preview:")
                                .font(Typography.Headline.regular)
                                .foregroundColor(Theme.Colors.text)
                            
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 200)
                                        .background(Theme.Colors.tertiaryBackground)
                                        .cornerRadius(Theme.CornerRadius.medium)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(Theme.CornerRadius.medium)
                                case .failure(let error):
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(Theme.Colors.tertiaryText)
                                        Text("Failed to load image")
                                            .font(Typography.Caption1.regular)
                                            .foregroundColor(Theme.Colors.tertiaryText)
                                        Text(error.localizedDescription)
                                            .font(Typography.Caption2.regular)
                                            .foregroundColor(Theme.Colors.tertiaryText)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 200)
                                    .background(Theme.Colors.tertiaryBackground)
                                    .cornerRadius(Theme.CornerRadius.medium)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Image Extractor Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func extractImage() {
        isLoading = true
        errorMessage = ""
        showingResult = false
        extractedImageURL = ""
        
        Task {
            do {
                let webScrapingService = WebScrapingService.shared
                let imageURL = try await webScrapingService.extractImageURL(from: urlText)
                
                await MainActor.run {
                    extractedImageURL = imageURL ?? ""
                    showingResult = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ImageExtractorTestView()
}