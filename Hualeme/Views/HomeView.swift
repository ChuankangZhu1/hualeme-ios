import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ExpenseStore
    @State private var isShowingCustomAmount = false
    @State private var lastRecordedAmount: Decimal?

    private let quickAmounts: [Decimal] = [
        Decimal(0),
        Decimal(5),
        Decimal(10),
        Decimal(20),
        Decimal(50)
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    quickAmountSection
                    feedbackSection
                    summarySection
                    recent7DaysSection
                    recentRecordsSection
                }
                .padding()
            }
            .navigationTitle("花了么")
            .sheet(isPresented: $isShowingCustomAmount) {
                CustomAmountView { amount in
                    record(amount: amount)
                    isShowingCustomAmount = false
                }
            }
        }
    }

    private var headerSection: some View {
        let status = store.walletStatus

        return VStack(spacing: 14) {
            VStack(spacing: 6) {
                Text("今天花了么？")
                    .font(.title2.weight(.bold))

                Text("给钱包测个体温。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text("钱包 HP：\(status.hp) / 100")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(status.title)
                    .font(.headline)

                Text(status.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text(store.checkInStatusText)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var quickAmountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷记录")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    Button {
                        record(amount: amount)
                    } label: {
                        Text(MoneyFormatting.string(from: amount))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button {
                    isShowingCustomAmount = true
                } label: {
                    Text("自定义")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    @ViewBuilder
    private var feedbackSection: some View {
        if let lastRecordedAmount {
            WalletFeedbackCard(
                recordedAmount: lastRecordedAmount,
                todayTotal: store.todayTotal,
                walletStatus: store.walletStatus
            )
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日 / 本周 / 本月")
                .font(.headline)

            HStack(spacing: 12) {
                SummaryCard(title: "今日", amount: store.todayTotal)
                SummaryCard(title: "本周", amount: store.weekTotal)
                SummaryCard(title: "本月", amount: store.monthTotal)
            }
        }
    }

    private var recent7DaysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近 7 天")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(store.recent7DayTotals) { dayTotal in
                    DailyTotalRow(dayTotal: dayTotal)

                    if dayTotal.id != store.recent7DayTotals.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var recentRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.headline)

            if store.recentEntries.isEmpty {
                Text("还没有记录。点上面的快捷金额开始。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(store.recentEntries) { entry in
                        RecentEntryRow(entry: entry)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete(entry: entry)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }

                        if entry.id != store.recentEntries.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private func record(amount: Decimal) {
        if let entry = store.add(amount: amount) {
            lastRecordedAmount = entry.amount
        }
    }
}

private struct WalletFeedbackCard: View {
    let recordedAmount: Decimal
    let todayTotal: Decimal
    let walletStatus: WalletStatus

    private var title: String {
        recordedAmount == Decimal(0) ? "今日打卡完成" : "记录成功"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Text("你刚刚记录了：\(MoneyFormatting.string(from: recordedAmount))")
                Text("今日累计：\(MoneyFormatting.string(from: todayTotal))")
                Text("钱包 HP：\(walletStatus.hp) / 100")
                Text("\(walletStatus.title)：\(walletStatus.message)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct SummaryCard: View {
    let title: String
    let amount: Decimal

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(MoneyFormatting.string(from: amount))
                .font(.headline)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct DailyTotalRow: View {
    let dayTotal: DailyExpenseTotal

    var body: some View {
        HStack {
            Text(Self.dayFormatter.string(from: dayTotal.date))
                .font(.subheadline)

            Spacer()

            Text(MoneyFormatting.string(from: dayTotal.total))
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 10)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "M/d E"
        return formatter
    }()
}

private struct RecentEntryRow: View {
    let entry: ExpenseEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Self.dateFormatter.string(from: entry.createdAt))
                    .font(.subheadline)

                Text(Self.timeFormatter.string(from: entry.createdAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(MoneyFormatting.string(from: entry.amount))
                .font(.headline)
        }
        .padding(.vertical, 10)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    HomeView()
        .environmentObject(ExpenseStore())
}
