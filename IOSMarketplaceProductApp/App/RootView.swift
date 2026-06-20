import SwiftUI

struct RootView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        Group {
            if environment.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView(
                        viewModel: AuthViewModel(
                            authService: environment.authService,
                            tokenStorage: environment.tokenStorage,
                            favoritesService: environment.favoritesService,
                            onSignedIn: { user in environment.applySignedIn(user: user) }
                        )
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: environment.isAuthenticated)
    }
}
