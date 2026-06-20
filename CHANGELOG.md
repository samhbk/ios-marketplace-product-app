# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [1.0.0] - 2026-06-20

### Added

- SwiftUI marketplace client with auth gate, tab shell, and `AppEnvironment` composition root
- JWT sign-in with Keychain token storage and one-tap demo account flow
- Paginated product catalog with infinite scroll, pull-to-refresh, and category badges
- Product detail screen with hero image, sale pricing, and favorites CTA
- Favorites tab with local ID cache and server sync on login and tab open
- Account screen with profile, API host display, and sign-out
- `MarketplaceTheme` design system, `ProductPriceView`, `MarketplaceAsyncImage`, and shared empty/error states
- Alamofire-based `HTTPClient` with Laravel paginator decoding and flexible JSON envelope support
- Configurable API base URL via scheme env, UserDefaults, or default `http://127.0.0.1:8000`
- 34 XCTest cases across models, view models, services, and app environment
- GitHub Actions CI on `macos-15` (XcodeGen, build, unit tests)
- PNG screenshots and architecture documentation for portfolio review

[Unreleased]: https://github.com/sameh-bakleh/ios-marketplace-product-app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/sameh-bakleh/ios-marketplace-product-app/releases/tag/v1.0.0
