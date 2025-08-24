//
//  MainTabView.swift
//  TastoryAI
//
//  Created by Denis Radabolski on 7/23/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(Theme.Colors.accent)
    }
}

struct SearchView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Search coming soon")
                    .font(Typography.Body.regular)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .navigationTitle("Search")
            .background(Theme.Colors.background)
        }
    }
}

struct ProfileView: View {
    @StateObject private var storageManager = RecipeStorageManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // App Information Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .foregroundColor(Theme.Colors.accent)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Tastory AI")
                                    .font(.headline)
                                Text("Your Digital Cookbook")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        Text("\(storageManager.recipes.count) recipes saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Preferences Section
                Section("Preferences") {
                    SettingsRow(
                        icon: "ruler.fill",
                        title: "Unit System",
                        subtitle: "US Imperial",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "person.2.fill",
                        title: "Default Servings",
                        subtitle: "4 people",
                        action: {}
                    )
                }
                
                // Debug Section (for development)
                Section("Development") {
                    NavigationLink(destination: DebugMenuView()) {
                        SettingsRowContent(
                            icon: "hammer.fill",
                            title: "Debug & Testing",
                            subtitle: "API tests, scaling tests"
                        )
                    }
                }
                
                // Support Section
                Section("Support") {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        title: "Help & FAQ",
                        subtitle: "Get help using Tastory AI",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                        title: "About",
                        subtitle: "Version 1.0",
                        action: {}
                    )
                }
            }
            .navigationTitle("Profile")
            .background(Theme.Colors.background)
        }
    }
}

// MARK: - Settings Components

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SettingsRowContent(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsRowContent: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.Colors.accent)
                .font(.title3)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(subtitle)
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

#Preview {
    MainTabView()
}