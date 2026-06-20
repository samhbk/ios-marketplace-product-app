import Foundation

struct User: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let email: String
}
