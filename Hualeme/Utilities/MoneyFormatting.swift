import Foundation

enum MoneyFormatting {
    static func string(from amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }

    static func decimal(from input: String) -> Decimal? {
        var cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "$", with: "")
        cleaned = cleaned.replacingOccurrences(of: "￥", with: "")
        cleaned = cleaned.replacingOccurrences(of: "¥", with: "")
        cleaned = cleaned.replacingOccurrences(of: " ", with: "")

        if cleaned.contains(",") && cleaned.contains(".") {
            cleaned = cleaned.replacingOccurrences(of: ",", with: "")
        } else if cleaned.contains(",") && !cleaned.contains(".") {
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        }

        guard let decimal = Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX")) else {
            return nil
        }

        guard decimal >= Decimal(0) else {
            return nil
        }

        return decimal.roundedMoneyScale()
    }
}

extension Decimal {
    func roundedMoneyScale() -> Decimal {
        var input = self
        var output = Decimal()
        NSDecimalRound(&output, &input, 2, .bankers)
        return output
    }
}
