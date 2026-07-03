import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ExpenseStore

    @AppStorage("hualeme.dailyReminder.enabled")
    private var reminderEnabled = false

    @AppStorage("hualeme.dailyReminder.hour")
    private var reminderHour = 21

    @AppStorage("hualeme.dailyReminder.minute")
    private var reminderMinute = 0

    @State private var reminderTime = Date()
    @State private var showingDeleteConfirmation = false
    @State private var notificationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("每日提醒") {
                    Toggle("开启每日提醒", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { newValue in
                            handleReminderEnabledChange(newValue)
                        }

                    DatePicker(
                        "提醒时间",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!reminderEnabled)
                    .onChange(of: reminderTime) { newValue in
                        updateReminderTime(newValue)
                    }

                    if let notificationMessage {
                        Text(notificationMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("数据") {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("删除所有数据")
                    }
                }

                Section("隐私说明") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("「花了么」Beta 0.1 只在本机保存你手动输入的消费金额。")
                        Text("本版本不创建账号、不连接后端、不做云同步、不读取银行、短信、通知、相册或 OCR 内容。")
                        Text("每日提醒使用 iOS 本地通知。删除所有数据后，记录无法恢复。")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                }

                Section("版本") {
                    HStack {
                        Text("Beta")
                        Spacer()
                        Text("0.1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .onAppear {
                reminderTime = makeDate(hour: reminderHour, minute: reminderMinute)
            }
            .alert("删除所有数据？", isPresented: $showingDeleteConfirmation) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    store.deleteAll()
                }
            } message: {
                Text("这会清空所有本地消费记录，无法恢复。")
            }
        }
    }

    private func handleReminderEnabledChange(_ enabled: Bool) {
        if enabled {
            Task {
                let success = await NotificationManager.shared.scheduleDailyReminder(
                    hour: reminderHour,
                    minute: reminderMinute
                )

                await MainActor.run {
                    if success {
                        notificationMessage = "每日提醒已开启。"
                    } else {
                        reminderEnabled = false
                        notificationMessage = "通知权限未开启，无法设置每日提醒。"
                    }
                }
            }
        } else {
            NotificationManager.shared.cancelDailyReminder()
            notificationMessage = "每日提醒已关闭。"
        }
    }

    private func updateReminderTime(_ date: Date) {
        let components = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: date)
        reminderHour = components.hour ?? 21
        reminderMinute = components.minute ?? 0

        guard reminderEnabled else {
            return
        }

        Task {
            let success = await NotificationManager.shared.scheduleDailyReminder(
                hour: reminderHour,
                minute: reminderMinute
            )

            await MainActor.run {
                notificationMessage = success ? "提醒时间已更新。" : "提醒时间更新失败。"
            }
        }
    }

    private func makeDate(hour: Int, minute: Int) -> Date {
        var components = Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day],
            from: Date()
        )
        components.hour = hour
        components.minute = minute

        return Calendar.autoupdatingCurrent.date(from: components) ?? Date()
    }
}

#Preview {
    SettingsView()
        .environmentObject(ExpenseStore())
}
