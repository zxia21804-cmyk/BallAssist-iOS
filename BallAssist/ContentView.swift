import SwiftUI
import ReplayKit

struct ContentView: View {
    @State private var latest = SharedDetection.read()
    @State private var isShowingHelp = false

    private let refresh = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("球球 AI 智能辅助")
                            .font(.largeTitle.bold())
                        Text("第一阶段：屏幕广播采集与球体候选识别验证")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    BroadcastPicker()
                        .frame(height: 54)

                    HStack(spacing: 12) {
                        StatusCard(title: "候选目标", value: "\(latest.count)", symbol: "scope")
                        StatusCard(title: "画面采集", value: latest.updatedAt == nil ? "未开始" : "收到画面", symbol: "dot.radiowaves.left.and.right")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("识别结果")
                            .font(.headline)
                        if latest.boxes.isEmpty {
                            Text("尚未收到识别结果。请点击上方“开始广播”，在系统广播菜单中选择本应用的广播扩展，然后返回游戏测试。")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(latest.boxes.enumerated()), id: \.offset) { index, box in
                                HStack {
                                    Text("候选球体 \(index + 1)")
                                    Spacer()
                                    Text("中心：\(Int(box.midX * 100))%、\(Int((1 - box.midY) * 100))%")
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                                .font(.callout)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 6) {
                        Label("当前版本限制", systemImage: "info.circle")
                            .font(.headline)
                        Text("本版本只输出画面中的圆形候选区域，不会自动判断队友/敌人，也不会点击游戏按钮。不同地图、皮肤、特效和画质会影响识别准确率。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))

                    Button("查看安装与测试说明") { isShowingHelp = true }
                        .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(refresh) { _ in latest = SharedDetection.read() }
            .sheet(isPresented: $isShowingHelp) {
                HelpView()
            }
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol).font(.title2)
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct BroadcastPicker: UIViewRepresentable {
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: .zero)
        picker.preferredExtension = "com.example.BallAssist.Broadcast"
        picker.showsMicrophoneButton = false
        return picker
    }

    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("测试步骤") {
                    Text("1. 在 Xcode 中使用你的 Apple ID 登录，并选择你的开发团队。")
                    Text("2. 确认主 App 和 Broadcast Extension 的 App Group 都启用同一个群组标识。")
                    Text("3. 将应用安装到 iPhone 12。")
                    Text("4. 打开本应用，点击“开始广播”，在系统菜单中选择球球 AI 助手并开始广播。")
                    Text("5. 切换到游戏，观察返回本应用后是否出现候选球体数量。")
                }
                Section("重要说明") {
                    Text("iOS 屏幕广播扩展由系统控制。应用不能在游戏画面上随意绘制悬浮层，也不能代替用户点击游戏操作按钮。")
                    Text("普通 Apple ID 的免费签名通常有有效期限制；安装和重新签名方式以 Apple 当前规则为准。")
                    Text("本工程是第一阶段源码骨架，尚未在真实 iPhone 12 上编译或验证。")
                }
            }
            .navigationTitle("帮助")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}
