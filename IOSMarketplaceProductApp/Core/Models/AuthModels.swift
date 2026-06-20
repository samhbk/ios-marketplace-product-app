import Foundation

/// Supports flat `{ token, user }`, `{ access_token, user }`, or wrapped `{ data: { token, user } }`.
struct AuthResponse: Decodable {
    let token: String?
    let accessToken: String?
    let user: User?

    var bearerToken: String? {
        token ?? accessToken
    }

    enum CodingKeys: String, CodingKey {
        case token
        case accessToken = "access_token"
        case user
        case data
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        var token = try c.decodeIfPresent(String.self, forKey: .token)
        var accessToken = try c.decodeIfPresent(String.self, forKey: .accessToken)
        var user = try c.decodeIfPresent(User.self, forKey: .user)

        if token == nil, accessToken == nil, let nested = try c.decodeIfPresent(Nested.self, forKey: .data) {
            token = nested.token
            accessToken = nested.accessToken
            if user == nil { user = nested.user }
        }

        self.init(storedToken: token, storedAccessToken: accessToken, user: user)
    }

    private init(storedToken: String?, storedAccessToken: String?, user: User?) {
        self.token = storedToken
        self.accessToken = storedAccessToken
        self.user = user
    }

    private struct Nested: Decodable {
        let token: String?
        let accessToken: String?
        let user: User?

        enum CodingKeys: String, CodingKey {
            case token
            case accessToken = "access_token"
            case user
        }
    }
}
