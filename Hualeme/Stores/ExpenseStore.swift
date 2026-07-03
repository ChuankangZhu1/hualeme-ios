import Foundation
import  Combine

@MainActor
final class ExpenseStore: ObservableObject {
    @Published private(set) var entries: [ExpenseEntry] = [] {
        didSet {
            save()
        }
    }

    private let storageKey = "hualeme.expenseEntries.v1"
    private var calendar: Calendar {
        Calendar.autoupdatingCurrent
    }

    init() {
        load()
    }

    func add(amount: Decimal, createdAt: Date = Date()) {
        guard amount >= Decimal(0) else {
            return
        }

        let roundedAmount = amount.roundedMoneyScale()
        let entry = ExpenseEntry(amount: roundedAmount, createdAt: createdAt)
        entries.insert(entry, at: 0)
    }

    func delete(entry: ExpenseEntry) {
        entries.removeAll { current in
            current.id == entry.id
        }
    }

    func deleteAll() {
        entries.removeAll()
    }

    var todayTotal: Decimal {
        guard let interval = calendar.dateInterval(of: .day, for: Date()) else {
            return Decimal(0)
        }

        return total(in: interval)
    }

    var weekTotal: Decimal {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return Decimal(0)
        }

        return total(in: interval)
    }

    var monthTotal: Decimal {
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else {
            return Decimal(0)
        }

        return total(in: interval)
    }

    var recent7DayTotals: [DailyExpenseTotal] {
        let todayStart = calendar.startOfDay(for: Date())

        return (-6...0).compactMap { offset in
            guard let dayStart = calendar.date(byAdding: .day, value: offset, to: todayStart),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                return nil
            }

            let interval = DateInterval(start: dayStart, end: dayEnd)
            return DailyExpenseTotal(date: dayStart, total: total(in: interval))
        }
    }

    var recentEntries: [ExpenseEntry] {
        Array(entries.prefix(30))
    }

    private func total(in interval: DateInterval) -> Decimal {
        entries
            .filter { entry in
                interval.contains(entry.createdAt)
            }
            .reduce(Decimal(0)) { partialResult, entry in
                partialResult + entry.amount
            }
            .roundedMoneyScale()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            entries = []
            return
        }

        guard let decodedEntries = try? JSONDecoder().decode([ExpenseEntry].self, from: data) else {
            entries = []
            return
        }

        entries = decodedEntries.sorted { lhs, rhs in
            lhs.createdAt > rhs.createdAt
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
