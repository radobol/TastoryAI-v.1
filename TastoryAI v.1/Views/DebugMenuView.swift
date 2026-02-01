//
//  DebugMenuView.swift
//  TastoryAI
//
//  Created by Claude on 8/24/25.
//

import SwiftUI

struct DebugMenuView: View {
    @State private var showingAPITest = false
    @State private var apiTestResult = ""
    @State private var showingImageExtractorView = false

    var body: some View {
        ZStack {
            TastoryColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: TastorySpacing.md) {
                    // API Testing Section
                    VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                        TastorySectionHeader(title: "API Testing")
                            .padding(.horizontal, TastorySpacing.md)

                        TastoryListItem(
                            title: "Test OpenAI API",
                            subtitle: "Verify API connection and response",
                            leadingIcon: "network",
                            showChevron: false,
                            action: testAPI
                        )
                        .padding(.horizontal, TastorySpacing.md)
                    }

                    // Image Extraction Testing Section
                    VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                        TastorySectionHeader(title: "Image Extraction")
                            .padding(.horizontal, TastorySpacing.md)

                        TastoryListItem(
                            title: "Test Image URL Extraction",
                            subtitle: "Extract images from recipe URLs",
                            leadingIcon: "photo.badge.arrow.down",
                            showChevron: false
                        ) {
                            showingImageExtractorView = true
                        }
                        .padding(.horizontal, TastorySpacing.md)
                    }

                    // Scaling System Testing Section
                    VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                        TastorySectionHeader(title: "Scaling System")
                            .padding(.horizontal, TastorySpacing.md)

                        VStack(spacing: 0) {
                            Button(action: testScaling) {
                                HStack(spacing: TastorySpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(TastoryColors.lightGreenBg)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "scalemass.fill")
                                            .foregroundColor(TastoryColors.primaryGreen)
                                            .font(.system(size: TastoryIconSize.medium))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Quick Scaling Test")
                                            .font(TastoryTypography.body)
                                            .foregroundColor(TastoryColors.primaryText)
                                        Text("Test ingredient scaling system")
                                            .font(TastoryTypography.caption)
                                            .foregroundColor(TastoryColors.secondaryText)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.vertical, TastorySpacing.sm)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider().padding(.leading, 56)

                            NavigationLink(destination: ScalingDebugView()) {
                                HStack(spacing: TastorySpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(TastoryColors.lightGreenBg)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "wrench.and.screwdriver.fill")
                                            .foregroundColor(TastoryColors.primaryGreen)
                                            .font(.system(size: TastoryIconSize.medium))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Advanced Scaling Tests")
                                            .font(TastoryTypography.body)
                                            .foregroundColor(TastoryColors.primaryText)
                                        Text("Detailed testing interface")
                                            .font(TastoryTypography.caption)
                                            .foregroundColor(TastoryColors.secondaryText)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(TastoryColors.secondaryText)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.vertical, TastorySpacing.sm)
                            }
                        }
                        .background(TastoryColors.cardBackground)
                        .cornerRadius(TastoryRadius.large)
                        .padding(.horizontal, TastorySpacing.md)
                    }

                    // System Information Section
                    VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                        TastorySectionHeader(title: "System Information")
                            .padding(.horizontal, TastorySpacing.md)

                        HStack(spacing: TastorySpacing.sm) {
                            ZStack {
                                Circle()
                                    .fill(TastoryColors.lightGreenBg)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(TastoryColors.primaryGreen)
                                    .font(.system(size: TastoryIconSize.medium))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("App Version")
                                    .font(TastoryTypography.body)
                                    .foregroundColor(TastoryColors.primaryText)
                                Text("1.0 (Debug Build)")
                                    .font(TastoryTypography.caption)
                                    .foregroundColor(TastoryColors.secondaryText)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, TastorySpacing.md)
                        .padding(.vertical, TastorySpacing.sm)
                        .background(TastoryColors.cardBackground)
                        .cornerRadius(TastoryRadius.large)
                        .padding(.horizontal, TastorySpacing.md)
                    }
                }
                .padding(.top, TastorySpacing.md)
                .padding(.bottom, TastorySpacing.lg)
            }
        }
        .navigationTitle("Debug & Testing")
        .navigationBarTitleDisplayMode(.inline)
        .alert("API Test Result", isPresented: $showingAPITest) {
            Button("OK") {}
        } message: {
            Text(apiTestResult)
        }
        .sheet(isPresented: $showingImageExtractorView) {
            ImageExtractorTestView()
        }
    }
    
    // MARK: - Test Functions
    
    private func testAPI() {
        Task {
            do {
                print("🧪 Testing OpenAI API...")
                let openAIService = OpenAIService.shared
                
                let testPrompt = """
                Extract recipe information from this text and return it in JSON format:
                
                "Chocolate Chip Cookies
                Ingredients: 2 cups flour, 1 cup sugar, 1/2 cup butter, 2 eggs, 1 cup chocolate chips
                Instructions: Mix dry ingredients. Add wet ingredients. Fold in chocolate chips. Bake at 350°F for 12 minutes."
                """
                
                let result = try await openAIService.generateRecipeFromText(testPrompt)
                
                await MainActor.run {
                    apiTestResult = "✅ API Test Successful!\n\nResponse:\n\(String(result.prefix(200)))..."
                    showingAPITest = true
                }
                
            } catch {
                await MainActor.run {
                    apiTestResult = "❌ API Test Failed:\n\n\(error.localizedDescription)"
                    showingAPITest = true
                }
            }
        }
    }
    
    private func testScaling() {
        print("🧪 Starting scaling tests...")
        ScalingSystemTester.runAllTests()
    }
}

#Preview {
    NavigationView {
        DebugMenuView()
    }
}