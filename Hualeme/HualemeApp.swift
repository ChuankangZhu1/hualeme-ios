import SwiftUI

@main
struct HualemeApp: App {
    @StateObject private var expenseStore = ExpenseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(expenseStore)
        }
    }
}
