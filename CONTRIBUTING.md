# Contributing

Thank you for your interest in this project. It is primarily a **portfolio sample**, but focused contributions are welcome.

## Before you start

1. Check existing [issues](https://github.com/sameh-bakleh/ios-marketplace-product-app/issues) to avoid duplicate work.
2. For large changes (new features, architecture shifts), open an issue first to align on scope.
3. Do **not** commit secrets, API keys, signing certificates, or production URLs.

## Development setup

```bash
brew install xcodegen
git clone https://github.com/sameh-bakleh/ios-marketplace-product-app.git
cd ios-marketplace-product-app
xcodegen generate
open IOSMarketplaceProductApp.xcodeproj
```

See [README.md](README.md) for API configuration and run instructions.

## Making changes

1. Create a branch from `main`:
   ```bash
   git checkout -b fix/short-description
   ```
2. Keep changes focused — one concern per pull request.
3. Match existing style: SwiftUI + MVVM, protocol-based services, `@MainActor` view models.
4. Add or update **unit tests** when changing view models, services, or model decoding.
5. Run tests locally before opening a PR:

   ```bash
   xcodegen generate
   xcodebuild test \
     -project IOSMarketplaceProductApp.xcodeproj \
     -scheme IOSMarketplaceProductApp \
     -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
     CODE_SIGNING_ALLOWED=NO
   ```

6. Regenerate the Xcode project if you edit `project.yml`:
   ```bash
   xcodegen generate
   ```

## Pull requests

Use the [pull request template](.github/pull_request_template.md). CI must pass (build + unit tests).

A maintainer will review for:

- Correctness and test coverage
- Consistency with project architecture
- No secrets or personal signing settings
- Reasonable scope (no drive-by refactors)

## What we are unlikely to merge

- New product features not aligned with the marketplace client scope (e.g. payments, chat) without prior discussion
- Dependency swaps without clear benefit
- Changes that break CI or require manual Team IDs in committed files

## Code of conduct

Be respectful and constructive. This is an open portfolio repository.

## Security

Report vulnerabilities privately — see [SECURITY.md](SECURITY.md). Do not file public issues with exploit details.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
