# Security Policy

## Supported versions

| Version | Supported |
| ------- | --------- |
| 1.0.x   | Yes       |

## Reporting a vulnerability

If you discover a security issue in this repository, please **do not** open a public GitHub issue with exploit details.

Instead, contact the maintainer privately (GitHub profile contact or email on the portfolio site) with:

- A description of the issue
- Steps to reproduce
- Impact assessment (if known)

You should receive an acknowledgment within a reasonable timeframe.

## Scope

This project is a **portfolio sample iOS client**. It is not a production service with SLAs. Reports about missing certificate pinning, lack of token refresh, or demo API configuration are noted but may be accepted as known limitations unless they expose committed secrets or enable trivial remote compromise of end users.

## What we protect

- **No secrets in git** — API keys, tokens, and signing credentials must not be committed (see `.gitignore` and `.env.example`).
- **Keychain for bearer tokens** — access tokens are stored in the iOS Keychain, not `UserDefaults`.
- **HTTPS in production** — use TLS endpoints in real deployments; local HTTP is limited to development via App Transport Security exceptions.

## Safe configuration

| Setting | Where | Notes |
|---------|-------|-------|
| API base URL | Xcode scheme env `MARKETPLACE_API_BASE_URL` or UserDefaults | Never commit production URLs with credentials |
| Demo login | Your backend only | Do not commit real passwords |
| Apple Team ID | Xcode locally | `DEVELOPMENT_TEAM` stays empty in `project.yml` |

## Out of scope

- Denial-of-service against a third-party API you configure
- Social engineering
- Issues in backend APIs not maintained in this repository

## Contributing securely

See [CONTRIBUTING.md](CONTRIBUTING.md). Pull requests containing secrets, keys, or `GoogleService-Info.plist` will be rejected.
