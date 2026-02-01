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

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(TastoryColors.primaryGreen)
    }
}

struct ProfileView: View {
    @StateObject private var storageManager = RecipeStorageManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                TastoryColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TastorySpacing.md) {
                        // App Information Card
                        TastoryCard {
                            VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                                HStack(spacing: TastorySpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(TastoryColors.lightGreenBg)
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "book.closed.fill")
                                            .foregroundColor(TastoryColors.primaryGreen)
                                            .font(.system(size: 24))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Tastory AI")
                                            .font(TastoryTypography.title)
                                            .foregroundColor(TastoryColors.primaryText)
                                        Text("Your Digital Cookbook")
                                            .font(TastoryTypography.caption)
                                            .foregroundColor(TastoryColors.secondaryText)
                                    }
                                    Spacer()
                                }

                                HStack {
                                    TastoryBadge(text: "\(storageManager.recipes.count) recipes saved")
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, TastorySpacing.md)

                        // Preferences Section
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            TastorySectionHeader(title: "Preferences")
                                .padding(.horizontal, TastorySpacing.md)

                            VStack(spacing: 0) {
                                TastoryListItemRow(
                                    title: "Unit System",
                                    subtitle: "US Imperial",
                                    leadingIcon: "ruler.fill"
                                )
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.vertical, TastorySpacing.xs)

                                Divider().padding(.leading, 56)

                                TastoryListItemRow(
                                    title: "Default Servings",
                                    subtitle: "4 people",
                                    leadingIcon: "person.2.fill"
                                )
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.vertical, TastorySpacing.xs)
                            }
                            .background(TastoryColors.cardBackground)
                            .cornerRadius(TastoryRadius.large)
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        // Development Section
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            TastorySectionHeader(title: "Development")
                                .padding(.horizontal, TastorySpacing.md)

                            NavigationLink(destination: DebugMenuView()) {
                                HStack(spacing: TastorySpacing.sm) {
                                    ZStack {
                                        Circle()
                                            .fill(TastoryColors.lightGreenBg)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "hammer.fill")
                                            .foregroundColor(TastoryColors.primaryGreen)
                                            .font(.system(size: TastoryIconSize.medium))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Debug & Testing")
                                            .font(TastoryTypography.body)
                                            .foregroundColor(TastoryColors.primaryText)
                                        Text("API tests, scaling tests")
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
                            .background(TastoryColors.cardBackground)
                            .cornerRadius(TastoryRadius.large)
                            .padding(.horizontal, TastorySpacing.md)
                        }

                        // Support Section
                        VStack(alignment: .leading, spacing: TastorySpacing.sm) {
                            TastorySectionHeader(title: "Support")
                                .padding(.horizontal, TastorySpacing.md)

                            VStack(spacing: 0) {
                                TastoryListItemRow(
                                    title: "Help & FAQ",
                                    subtitle: "Get help using Tastory AI",
                                    leadingIcon: "questionmark.circle.fill"
                                )
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.vertical, TastorySpacing.xs)

                                Divider().padding(.leading, 56)

                                TastoryListItemRow(
                                    title: "About",
                                    subtitle: "Version 1.0",
                                    leadingIcon: "info.circle.fill"
                                )
                                .padding(.horizontal, TastorySpacing.md)
                                .padding(.vertical, TastorySpacing.xs)
                            }
                            .background(TastoryColors.cardBackground)
                            .cornerRadius(TastoryRadius.large)
                            .padding(.horizontal, TastorySpacing.md)
                        }
                    }
                    .padding(.top, TastorySpacing.md)
                    .padding(.bottom, TastorySpacing.lg)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Settings Components (Legacy - kept for compatibility)

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
        HStack(spacing: TastorySpacing.sm) {
            ZStack {
                Circle()
                    .fill(TastoryColors.lightGreenBg)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(TastoryColors.primaryGreen)
                    .font(.system(size: TastoryIconSize.medium))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TastoryTypography.body)
                    .foregroundColor(TastoryColors.primaryText)

                Text(subtitle)
                    .font(TastoryTypography.caption)
                    .foregroundColor(TastoryColors.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(TastoryColors.secondaryText)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    MainTabView()
}