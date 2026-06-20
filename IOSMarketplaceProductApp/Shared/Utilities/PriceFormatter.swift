import Foundation

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return f
    }()

    static func string(for price: Decimal, currencyCode: String?) -> String {
        formatter.currencyCode = currencyCode ?? Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "\(price)"
    }
}
