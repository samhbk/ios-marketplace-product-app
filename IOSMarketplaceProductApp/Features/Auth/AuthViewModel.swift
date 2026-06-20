import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService: AuthServicing
    private let tokenStorage: TokenStoring
    private let favoritesService: FavoritesServicing?
    private let onSignedIn: (User?) -> Void
    private var cancellables = Set<AnyCancellable>()

    init(
        authService: AuthServicing,
        tokenStorage: TokenStoring,
        favoritesService: FavoritesServicing? = nil,
        onSignedIn: @escaping (User?) -> Void
    ) {
        self.authService = authService
        self.tokenStorage = tokenStorage
        self.favoritesService = favoritesService
        self.onSignedIn = onSignedIn
    }

    func fillDemoCredentials() {
        email = "demo@example.com"
        password = "password"
    }

    func login() {
        errorMessage = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Enter email and password."
            return
        }

        isLoading = true
        authService
            .login(email: trimmedEmail, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.userMessage
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                guard let token = response.bearerToken else {
                    errorMessage = "Missing token in response."
                    return
                }
                tokenStorage.save(accessToken: token)
                onSignedIn(response.user)
                favoritesService?.syncFromServer()
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                    .store(in: &cancellables)
            }
            .store(in: &cancellables)
    }
}
