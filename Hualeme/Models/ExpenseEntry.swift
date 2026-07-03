import Foundation

struct ExpenseEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var amount: Decimal
    var createdAt: Date

    init(id: UUID = UUID(), amount: Decimal, createdAt: Date = Date()) {
        self.id = id
        self.amount = amount
        self.createdAt = createdAt
    }
}

struct DailyExpenseTotal: Identifiable, Equatable {
    let date: Date
    let total: Decimal

    var id: Date {
        date
    }
}
