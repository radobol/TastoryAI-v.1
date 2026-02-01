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
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.lg) {
                        // URL Input Card
                        TastoryCard {
                            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                                Text("Test URL")
                                    .font(TastoryTypography.headline)
                                    .foregroundColor(TastoryColors.primaryText)

                                TextField("Enter recipe URL", text: $urlText)
                                    .font(TastoryTypography.body)
                                    .padding(TastorySpacing.md)
                                    .background(TastoryColors.background)
                                    .cornerRadius(TastoryRadius.medium)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                Text("Enter a recipe website URL to test image extraction")
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.secondaryText)
                            }
                        }
                        .padding(.horizontal, TastorySpacing.md)

                        // Extract Button
                        TastoryButton(
                            title: isLoading ? "Extracting..." : "Extract Image",
                            style: .primary,
                            icon: isLoading ? nil : "photo.badge.arrow.down",
                            isDisabled: urlText.isEmpty || isLoading
                        ) {
                            extractImage()
                        }
                        .padding(.horizontal, TastorySpacing.md)

                        // Error Message
                        if !errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(TastoryColors.errorRed)
                                Text(errorMessage)
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.errorRed)
                                Spacer()
                            }
                            .padding(TastorySpacing.md)
                            .background(TastoryColors.errorRed.opacity(0.1))
                            .cornerRadius(TastoryRadius.medium)
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        // Results
                        if showingResult {
                            TastoryCard {
                                VStack(alignment: .leading, spacing: TastorySpacing.md) {
                                    Text("Extracted Image URL:")
                                        .font(TastoryTypography.headline)
                                        .foregroundColor(TastoryColors.primaryText)

                                    ScrollView(.horizontal, showsIndicators: true) {
                                        Text(extractedImageURL.isEmpty ? "No image found" : extractedImageURL)
                                            .font(TastoryTypography.caption)
                                            .foregroundColor(TastoryColors.secondaryText)
                                            .textSelection(.enabled)
                                    }
                                    .padding(TastorySpacing.sm)
                                    .background(TastoryColors.background)
                                    .cornerRadius(TastoryRadius.small)

                                    if !extractedImageURL.isEmpty, let url = URL(string: extractedImageURL) {
                                        Text("Image Preview:")
                                            .font(TastoryTypography.headline)
                                            .foregroundColor(TastoryColors.primaryText)

                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(maxWidth: .infinity, minHeight: 200)
                                                    .background(TastoryColors.background)
                                                    .cornerRadius(TastoryRadius.medium)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(maxWidth: .infinity)
                                                    .cornerRadius(TastoryRadius.medium)
                                            case .failure(let error):
                                                VStack(spacing: TastorySpacing.sm) {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(TastoryColors.secondaryText)
                                                    Text("Failed to load image")
                                                        .font(TastoryTypography.caption)
                                                        .foregroundColor(TastoryColors.secondaryText)
                                                    Text(error.localizedDescription)
                                                        .font(TastoryTypography.caption)
                                                        .foregroundColor(TastoryColors.secondaryText)
                                                }
                                                .frame(maxWidth: .infinity, minHeight: 200)
                                                .background(TastoryColors.background)
                                                .cornerRadius(TastoryRadius.medium)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        Spacer()
                    }
                    .padding(.top, TastorySpacing.md)
                }
            }
            .navigationTitle("Image Extractor Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(TastoryColors.primaryGreen)
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
