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
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile coming soon")
                    .font(Typography.Body.regular)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .navigationTitle("Profile")
            .background(Theme.Colors.background)
        }
    }
}

#Preview {
    MainTabView()
}