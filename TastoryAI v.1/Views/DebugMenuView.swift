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
        List {
            // API Testing Section
            Section("API Testing") {
                Button(action: testAPI) {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(Theme.Colors.accent)
                            .font(.title3)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Test OpenAI API")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Verify API connection and response")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Image Extraction Testing Section
            Section("Image Extraction") {
                Button(action: { showingImageExtractorView = true }) {
                    HStack {
                        Image(systemName: "photo.badge.arrow.down")
                            .foregroundColor(Theme.Colors.accent)
                            .font(.title3)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Test Image URL Extraction")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Extract images from recipe URLs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Scaling System Testing Section
            Section("Scaling System") {
                Button(action: testScaling) {
                    HStack {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(Theme.Colors.accent)
                            .font(.title3)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Scaling Test")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Test ingredient scaling system")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: ScalingDebugView()) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundColor(Theme.Colors.accent)
                            .font(.title3)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Advanced Scaling Tests")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Detailed testing interface")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 2)
                }
            }
            
            // System Information Section
            Section("System Information") {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Theme.Colors.accent)
                        .font(.title3)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("App Version")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("1.0 (Debug Build)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 2)
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