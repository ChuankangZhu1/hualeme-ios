# 花了么 Beta 0.1 - iPhone-only SwiftUI 最小版本

## 使用方式

1. 打开 Xcode。
2. File → New → Project。
3. 选择 iOS → App。
4. Product Name 填：`Hualeme`
5. Interface 选择：SwiftUI。
6. Language 选择：Swift。
7. Minimum Deployment 建议 iOS 16.0 或以上。
8. 删除模板自动生成的 `ContentView.swift` 和 `HualemeApp.swift`。
9. 把本压缩包里的所有 `.swift` 文件拖进 Xcode 项目。
10. 勾选 `Copy items if needed` 和你的 App target。
11. 运行到 iPhone Simulator。

## Beta 0.1 范围

已包含：

- SwiftUI 首页
- 快捷金额：$0 / $5 / $10 / $20 / $50 / 自定义金额
- 本地保存 ExpenseEntry
- 今日、本周、本月统计
- 最近 7 天统计
- 最近记录列表
- 设置页
- 每日提醒
- 删除所有数据
- 隐私说明

刻意不包含：

- Apple Watch
- 后端
- 账号
- 广告
- analytics
- 订阅
- 云同步
- 银行绑定
- 短信读取
- 通知读取
- OCR
- AI 自动读取
- 复杂分类
- Android / 华为

## 技术约束

- 金额逻辑使用 `Decimal`
- 日期统计使用 `Calendar.autoupdatingCurrent`
- 消费金额和记录不会被 `print` 到 console
- 数据保存在本机 `UserDefaults`
- 每日提醒使用 iOS 本地通知
