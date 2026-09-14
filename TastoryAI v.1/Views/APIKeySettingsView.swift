//
//  APIKeySettingsView.swift
//  TastoryAI
//

import SwiftUI

struct APIKeySettingsView: View {
    @State private var apiKey = ""
    @State private var hasSavedKey = false
    @State private var isKeyVisible = false
    @State private var isTesting = false
    @State private var showingDeleteConfirmation = false
    @State private var feedback: APIKeyFeedback?

    private let keyStore = OpenAIKeyStore.shared

    var body: some View {
        ZStack {
            TastoryColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: TastorySpacing.lg) {
                    statusCard
                    keyEntryCard
                    securityNote
                }
                .padding(TastorySpacing.md)
            }
        }
        .navigationTitle("OpenAI API Key")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: refreshStatus)
        .confirmationDialog(
            "Delete the saved API key?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete API Key", role: .destructive, action: deleteKey)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("AI recipe extraction will stop working until another key is saved.")
        }
        .alert(item: $feedback) { feedback in
            Alert(
                title: Text(feedback.title),
                message: Text(feedback.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var statusCard: some View {
        TastoryCard {
            HStack(spacing: TastorySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(hasSavedKey ? TastoryColors.lightGreenBg : TastoryColors.warningOrange.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: hasSavedKey ? "checkmark.shield.fill" : "key.fill")
                        .foregroundColor(hasSavedKey ? TastoryColors.successGreen : TastoryColors.warningOrange)
                        .font(.system(size: TastoryIconSize.large))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(hasSavedKey ? "API key saved" : "API key required")
                        .font(TastoryTypography.headline)
                        .foregroundColor(TastoryColors.primaryText)

                    Text(hasSavedKey ? "Stored securely in this device's Keychain" : "Add your own key to enable AI extraction")
                        .font(TastoryTypography.caption)
                        .foregroundColor(TastoryColors.secondaryText)
                }

                Spacer()
            }
        }
    }

    private var keyEntryCard: some View {
        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
            TastorySectionHeader(title: hasSavedKey ? "Replace key" : "Add key")

            TastoryCard {
                VStack(alignment: .leading, spacing: TastorySpacing.md) {
                    HStack(spacing: TastorySpacing.xs) {
                        Group {
                            if isKeyVisible {
                                TextField("sk-...", text: $apiKey)
                            } else {
                                SecureField("sk-...", text: $apiKey)
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .privacySensitive()

                        Button {
                            isKeyVisible.toggle()
                        } label: {
                            Image(systemName: isKeyVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(TastoryColors.secondaryText)
                        }
                        .accessibilityLabel(isKeyVisible ? "Hide API key" : "Show API key")
                    }
                    .padding(.horizontal, TastorySpacing.sm)
                    .frame(height: TastoryButtonHeight.secondary)
                    .background(TastoryColors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: TastoryRadius.medium)
                            .stroke(TastoryColors.border, lineWidth: 1)
                    )
                    .cornerRadius(TastoryRadius.medium)

                    Button(action: saveKey) {
                        Text(hasSavedKey ? "Replace API Key" : "Save API Key")
                            .font(TastoryTypography.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: TastoryButtonHeight.secondary)
                            .background(TastoryColors.primaryGreen)
                            .cornerRadius(TastoryRadius.full)
                    }
                    .disabled(trimmedKey.isEmpty || isTesting)
                    .opacity(trimmedKey.isEmpty || isTesting ? 0.5 : 1)

                    if hasSavedKey {
                        Button(action: testConnection) {
                            HStack {
                                if isTesting {
                                    ProgressView()
                                        .tint(TastoryColors.primaryGreen)
                                }
                                Text(isTesting ? "Testing Connection..." : "Test Connection")
                            }
                            .font(TastoryTypography.body)
                            .foregroundColor(TastoryColors.primaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: TastoryButtonHeight.secondary)
                            .overlay(
                                Capsule()
                                    .stroke(TastoryColors.primaryGreen, lineWidth: 1.5)
                            )
                        }
                        .disabled(isTesting)

                        Button("Delete API Key", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                        .font(TastoryTypography.callout)
                        .frame(maxWidth: .infinity)
                        .disabled(isTesting)
                    }
                }
            }
        }
    }

    private var securityNote: some View {
        VStack(alignment: .leading, spacing: TastorySpacing.xs) {
            Label("Your key is stored only in the iOS Keychain and is never added to the Tastory repository or app bundle.", systemImage: "lock.shield.fill")
                .font(TastoryTypography.caption)
                .foregroundColor(TastoryColors.secondaryText)

            Link("Create or manage OpenAI API keys", destination: URL(string: "https://platform.openai.com/api-keys")!)
                .font(TastoryTypography.caption)
                .foregroundColor(TastoryColors.primaryGreen)
        }
        .padding(.horizontal, TastorySpacing.xs)
    }

    private var trimmedKey: String {
        apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func refreshStatus() {
        hasSavedKey = keyStore.hasKey
    }

    private func saveKey() {
        do {
            try keyStore.save(trimmedKey)
            apiKey = ""
            isKeyVisible = false
            refreshStatus()
            feedback = APIKeyFeedback(
                title: "API Key Saved",
                message: "The key is now stored securely in this device's Keychain."
            )
        } catch {
            feedback = APIKeyFeedback(title: "Could Not Save Key", message: error.localizedDescription)
        }
    }

    private func deleteKey() {
        do {
            try keyStore.delete()
            apiKey = ""
            isKeyVisible = false
            refreshStatus()
            feedback = APIKeyFeedback(title: "API Key Deleted", message: "The key was removed from this device.")
        } catch {
            feedback = APIKeyFeedback(title: "Could Not Delete Key", message: error.localizedDescription)
        }
    }

    private func testConnection() {
        isTesting = true

        Task {
            defer { isTesting = false }

            do {
                try await OpenAIService.shared.testConnection()
                feedback = APIKeyFeedback(
                    title: "Connection Successful",
                    message: "Tastory can connect to OpenAI with the saved key."
                )
            } catch {
                feedback = APIKeyFeedback(title: "Connection Failed", message: error.localizedDescription)
            }
        }
    }
}

private struct APIKeyFeedback: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    NavigationView {
        APIKeySettingsView()
    }
}
