import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MarketplaceSpacing.xl) {
                header
                formCard
            }
            .padding(.horizontal, MarketplaceSpacing.md)
            .padding(.top, MarketplaceSpacing.xxl)
            .padding(.bottom, MarketplaceSpacing.xxl)
        }
        .marketplaceScreenBackground()
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(spacing: MarketplaceSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.marketplaceAccentMuted)
                    .frame(width: 88, height: 88)
                Image(systemName: "bag.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color.marketplaceAccent)
            }

            Text("Marketplace")
                .font(.largeTitle.weight(.bold))

            Text("Sign in to browse curated products from the Laravel demo store.")
                .font(.subheadline)
                .foregroundStyle(Color.marketplaceTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, MarketplaceSpacing.sm)
        }
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: MarketplaceSpacing.md) {
            VStack(alignment: .leading, spacing: MarketplaceSpacing.xs) {
                Text("Email")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.marketplaceTextSecondary)
                TextField("demo@example.com", text: $viewModel.email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(MarketplaceSpacing.sm)
                    .background(Color.marketplaceSurface, in: RoundedRectangle(cornerRadius: MarketplaceRadius.sm, style: .continuous))
            }

            VStack(alignment: .leading, spacing: MarketplaceSpacing.xs) {
                Text("Password")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.marketplaceTextSecondary)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .padding(MarketplaceSpacing.sm)
                    .background(Color.marketplaceSurface, in: RoundedRectangle(cornerRadius: MarketplaceRadius.sm, style: .continuous))
            }

            if let message = viewModel.errorMessage {
                ErrorBanner(message: message, onDismiss: { viewModel.errorMessage = nil })
            }

            PrimaryButton(title: "Sign in", isBusy: viewModel.isLoading) {
                viewModel.login()
            }
            .padding(.top, MarketplaceSpacing.xxs)

            Button {
                viewModel.fillDemoCredentials()
                viewModel.login()
            } label: {
                HStack(spacing: MarketplaceSpacing.xs) {
                    Image(systemName: "sparkles")
                    Text("Continue with demo account")
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, MarketplaceSpacing.sm)
            }
            .foregroundStyle(Color.marketplaceAccent)
        }
        .marketplaceCard()
    }
}
