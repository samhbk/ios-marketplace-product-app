# Architecture

## Overview

The app follows **MVVM** with a thin **service layer** and protocol-based dependency injection. Views are SwiftUI; view models are `@MainActor` `ObservableObject` types; networking and persistence live in **Core**.

```
┌─────────────────────────────────────────────────────────┐
│  SwiftUI Views (Features + Shared components)         │
└───────────────────────────┬─────────────────────────────┘
                            │ @StateObject / bindings
┌───────────────────────────▼─────────────────────────────┐
│  ViewModels (@MainActor, Combine subscriptions)           │
└───────────────────────────┬─────────────────────────────┘
                            │ protocols
┌───────────────────────────▼─────────────────────────────┐
│  Services (Auth, Product, Favorites)                      │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│  HTTPClient (Alamofire) + APIConfiguration                │
│  KeychainTokenStorage                                     │
└─────────────────────────────────────────────────────────┘
```

## Layers

| Layer | Responsibility |
|-------|----------------|
| **App** | `@main`, `AppEnvironment` composition root, tab navigation |
| **Features** | Screen-specific views and view models |
| **Core** | Models, REST client, services, Keychain, pagination |
| **Shared** | Reusable UI, theme, formatters |

## Data flow examples

**Login:** `LoginView` → `AuthViewModel` → `AuthService` → `HTTPClient` → token saved via `KeychainTokenStorage` → `AppEnvironment.applySignedInState()`.

**Catalog:** `ProductListView` → `ProductListViewModel` → `ProductService` → paginated `GET /api/products` → infinite scroll loads next page near list end.

**Favorites:** Heart toggle → `FavoritesService` → optimistic local ID cache (`UserDefaults`) + `POST/DELETE /api/favorites` → tab sync via `GET /api/favorites`.

## Testability

- Services depend on `HTTPClienting`, not concrete `HTTPClient`.
- `AppEnvironment` accepts injected dependencies (used in unit tests via mocks in `IOSMarketplaceProductAppTests`).
- View models take service protocols in `init` — no singletons.

## API contract

Documented in the root [README](../README.md#api-contract). The client targets a **Laravel-style JSON API** (Sanctum/JWT bearer token, length-aware pagination, validation error shape).

## UIKit usage

UIKit appears only where SwiftUI bridges system APIs (`Color(uiColor:)`, `UIImage` pipeline via `AsyncImage` + `URLCache`). No UIKit view controllers.
