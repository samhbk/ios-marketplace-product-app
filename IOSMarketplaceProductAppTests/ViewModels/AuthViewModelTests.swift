import Combine
import XCTest
@testable import IOSMarketplaceProductApp

@MainActor
final class AuthViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testLoginRejectsEmptyCredentials() {
        let viewModel = AuthViewModel(
            authService: MockAuthService(),
            tokenStorage: MockTokenStorage(),
            onSignedIn: { _ in }
        )
        viewModel.email = "   "
        viewModel.password = ""
        viewModel.login()
        XCTAssertEqual(viewModel.errorMessage, "Enter email and password.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoginSavesTokenAndNotifiesSignedIn() {
        let auth = MockAuthService()
        auth.loginResult = .success(
            try! JSONDecoder().decode(
                AuthResponse.self,
                from: Data(#"{"token":"secret-token","user":{"id":1,"name":"Demo","email":"demo@example.com"}}"#.utf8)
            )
        )
        let storage = MockTokenStorage()
        var didSignIn = false

        let viewModel = AuthViewModel(
            authService: auth,
            tokenStorage: storage,
            onSignedIn: { _ in didSignIn = true }
        )
        viewModel.email = "demo@example.com"
        viewModel.password = "password"

        let expectation = expectation(description: "signed in")
        viewModel.$isLoading
            .dropFirst()
            .sink { loading in
                if !loading, didSignIn {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login()
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(storage.accessToken, "secret-token")
        XCTAssertEqual(auth.lastLogin?.email, "demo@example.com")
    }

    func testLoginSurfacesMissingTokenError() {
        let auth = MockAuthService()
        auth.loginResult = .success(
            try! JSONDecoder().decode(AuthResponse.self, from: Data(#"{"user":{"id":1,"name":"Demo","email":"demo@example.com"}}"#.utf8))
        )

        let viewModel = AuthViewModel(
            authService: auth,
            tokenStorage: MockTokenStorage(),
            onSignedIn: { _ in }
        )
        viewModel.email = "demo@example.com"
        viewModel.password = "password"

        let expectation = expectation(description: "error shown")
        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { message in
                if message == "Missing token in response." {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login()
        wait(for: [expectation], timeout: 2)
    }
}
