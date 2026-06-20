import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        TabView {
            NavigationStack {
                ProductListView(
                    viewModel: ProductListViewModel(productService: environment.productService)
                )
            }
            .tabItem {
                Label("Browse", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                FavoritesView(
                    viewModel: FavoritesViewModel(
                        favoritesService: environment.favoritesService,
                        productService: environment.productService
                    )
                )
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }

            NavigationStack {
                ProfileView(onSignOut: { environment.signOut() })
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle.fill")
            }
        }
        .tint(.marketplaceAccent)
    }
}

private struct ProfileView: View {
    @EnvironmentObject private var environment: AppEnvironment
    let onSignOut: () -> Void

    var body: some View {
        List {
            if let user = environment.currentUser {
                Section {
                    HStack(spacing: MarketplaceSpacing.sm + 2) {
                        ZStack {
                            Circle()
                                .fill(Color.marketplaceAccentMuted)
                                .frame(width: 52, height: 52)
                            Text(user.name.prefix(1).uppercased())
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.marketplaceAccent)
                        }

                        VStack(alignment: .leading, spacing: MarketplaceSpacing.xxs) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(Color.marketplaceTextSecondary)
                        }
                    }
                    .padding(.vertical, MarketplaceSpacing.xxs)
                } header: {
                    Text("Profile")
                        .textCase(nil)
                }
            }

            Section("App") {
                LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                LabeledContent("API host", value: environment.configuration.baseURL.host ?? "Local")
            }

            Section {
                Button(role: .destructive, action: onSignOut) {
                    Text("Sign out")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .marketplaceScreenBackground()
        .navigationTitle("Account")
    }
}
