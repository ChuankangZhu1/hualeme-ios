import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let dailyReminderIdentifier = "hualeme.dailyReminder"

    private init() {}

    func scheduleDailyReminder(hour: Int, minute: Int) async -> Bool {
        let granted = await requestAuthorization()

        guard granted else {
            cancelDailyReminder()
            return false
        }

        cancelDailyReminder()

        let content = UNMutableNotificationContent()
        content.title = "今天花了么？"
        content.body = "花 10 秒记录一下今天的大概消费。"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            return true
        } catch {
            return false
        }
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [dailyReminderIdentifier]
        )
    }

    private func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }
}
