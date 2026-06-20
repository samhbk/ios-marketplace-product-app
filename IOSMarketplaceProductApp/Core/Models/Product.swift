import Foundation

struct Product: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let price: Decimal
    let compareAtPrice: Decimal?
    let currencyCode: String?
    let imageURL: URL?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case compareAtPrice = "compare_at_price"
        case currencyCode = "currency"
        case imageURL = "image_url"
        case category
    }

    var isOnSale: Bool {
        guard let compareAtPrice else { return false }
        return compareAtPrice > price
    }

    init(
        id: Int,
        name: String,
        description: String?,
        price: Decimal,
        compareAtPrice: Decimal? = nil,
        currencyCode: String?,
        imageURL: URL?,
        category: String?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.compareAtPrice = compareAtPrice
        self.currencyCode = currencyCode
        self.imageURL = imageURL
        self.category = category
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        category = try c.decodeIfPresent(String.self, forKey: .category)
        currencyCode = try c.decodeIfPresent(String.self, forKey: .currencyCode)
        price = Self.decodeDecimal(from: c, forKey: .price) ?? 0
        compareAtPrice = Self.decodeDecimal(from: c, forKey: .compareAtPrice)

        if let urlString = try c.decodeIfPresent(String.self, forKey: .imageURL) {
            imageURL = URL(string: urlString)
        } else {
            imageURL = nil
        }
    }

    private static func decodeDecimal(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Decimal? {
        if let dec = try? container.decode(Decimal.self, forKey: key) {
            return dec
        }
        if let d = try? container.decode(Double.self, forKey: key) {
            return Decimal(d)
        }
        if let s = try? container.decode(String.self, forKey: key) {
            return Decimal(string: s)
        }

        return nil
    }
}
