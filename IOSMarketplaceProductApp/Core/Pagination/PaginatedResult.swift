import Foundation

/// Laravel length-aware paginator JSON (`data` + `meta`).
struct PaginatedResult<T: Decodable>: Decodable {
    let data: [T]
    let meta: Meta?

    struct Meta: Decodable {
        let currentPage: Int
        let lastPage: Int
        let perPage: Int?
        let total: Int?

        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case lastPage = "last_page"
            case perPage = "per_page"
            case total
        }
    }

    var currentPage: Int {
        meta?.currentPage ?? 1
    }

    var lastPage: Int {
        meta?.lastPage ?? 1
    }

    var hasMorePages: Bool {
        currentPage < lastPage
    }
}
