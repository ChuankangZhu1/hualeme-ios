import Foundation

struct ExpenseEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var amount: Decimal
    var note: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Decimal,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.note = note
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case amount
        case note
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        amount = try container.decode(Decimal.self, forKey: .amount)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? createdAt
    }
}

struct DailyExpenseTotal: Identifiable, Equatable {
    let date: Date
    let total: Decimal

    var id: Date {
        date
    }
}
