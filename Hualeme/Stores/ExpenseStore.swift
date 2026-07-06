import Foundation
import Combine

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

    @discardableResult
    func add(amount: Decimal, createdAt: Date = Date()) -> ExpenseEntry? {
        guard amount >= Decimal(0) else {
            return nil
        }

        let roundedAmount = amount.roundedMoneyScale()
        let entry = ExpenseEntry(
            date: createdAt,
            amount: roundedAmount,
            createdAt: createdAt
        )
        entries.insert(entry, at: 0)
        return entry
    }

    func delete(entry: ExpenseEntry) {
        entries.removeAll { current in
            current.id == entry.id
        }
    }

    func deleteAll() {
        entries.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
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

    var walletStatus: WalletStatus {
        WalletStatus(total: todayTotal)
    }

    var hasCheckedInToday: Bool {
        guard let interval = calendar.dateInterval(of: .day, for: Date()) else {
            return false
        }

        return entries.contains { entry in
            interval.contains(entry.date)
        }
    }

    var checkInStreak: Int {
        let todayStart = calendar.startOfDay(for: Date())
        let recordedDays = Set(entries.map { entry in
            calendar.startOfDay(for: entry.date)
        })

        guard recordedDays.contains(todayStart) else {
            return 0
        }

        var streak = 0
        var currentDay = todayStart

        while recordedDays.contains(currentDay) {
            streak += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }

            currentDay = previousDay
        }

        return streak
    }

    var checkInStatusText: String {
        guard hasCheckedInToday else {
            return "今天还没给钱包量体温"
        }

        return "连续记录：\(checkInStreak) 天"
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
        Array(
            entries
                .sorted { lhs, rhs in
                    lhs.createdAt > rhs.createdAt
                }
                .prefix(30)
        )
    }

    private func total(in interval: DateInterval) -> Decimal {
        entries
            .filter { entry in
                interval.contains(entry.date)
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

struct WalletStatus: Equatable {
    let hp: Int
    let title: String
    let message: String

    init(total: Decimal) {
        let amount = total.roundedMoneyScale()

        if amount == Decimal(0) {
            hp = 100
            title = "满血钱包"
            message = "今天没花钱，钱包正在晒太阳。"
        } else if amount < Decimal(5) {
            hp = 95
            title = "几乎无伤"
            message = "这点伤害，钱包表示还能跑。"
        } else if amount < Decimal(10) {
            hp = 90
            title = "轻微擦伤"
            message = "钱包擦破点皮，但还能笑。"
        } else if amount < Decimal(20) {
            hp = 80
            title = "钱包掉皮"
            message = "钱包掉了点皮，但还站着。"
        } else if amount < Decimal(50) {
            hp = 70
            title = "钱包轻伤"
            message = "今天还行，钱包只是掉了点皮。"
        } else if amount < Decimal(100) {
            hp = 50
            title = "钱包中伤"
            message = "钱包正在深呼吸。"
        } else if amount < Decimal(200) {
            hp = 30
            title = "钱包大出血"
            message = "钱包血条报警，但不怪你。"
        } else {
            hp = 10
            title = "钱包省电模式"
            message = "钱包进入省电模式，明天还会回来。"
        }
    }
}
