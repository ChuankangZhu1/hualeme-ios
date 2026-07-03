import SwiftUI

struct CustomAmountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amountText = ""
    @State private var errorText: String?

    let onSave: (Decimal) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("金额") {
                    TextField("例如 12.50", text: $amountText)
                        .keyboardType(.decimalPad)

                    if let errorText {
                        Text(errorText)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("保存") {
                        save()
                    }
                    .disabled(amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("自定义金额")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func save() {
        guard let amount = MoneyFormatting.decimal(from: amountText) else {
            errorText = "请输入有效金额。"
            return
        }

        onSave(amount)
    }
}

#Preview {
    CustomAmountView { _ in }
}
