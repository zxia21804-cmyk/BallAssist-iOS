球球大作战 AI 智能辅助 - iOS 第一阶段源码骨架
================================================

这不是已签名、已安装或已通过真机测试的 IPA。本包提供第一阶段源码：
- iOS 主界面
- ReplayKit 屏幕广播扩展
- Vision 轮廓检测：输出“圆形候选区域”
- App Group 共享最近一次检测结果
- 中文测试说明

重要限制
--------
1. 当前只能检测画面中近似圆形的候选区域，不能可靠区分队友、敌人、地图装饰或特效。
2. 尚未实现可靠的跨帧目标 ID、锁定算法、合球时机模型。
3. iOS 不允许普通 App 任意覆盖游戏界面或代替用户点击游戏按钮。
4. ReplayKit 广播扩展必须由用户通过系统界面主动启动，实际游戏画面采集效果必须在 iPhone 12 上验证。
5. 当前未编译、未签名、未做真机测试。不要把本包当作可直接安装的 IPA。

在 Mac / 云端 macOS 构建
-----------------------
推荐使用 XcodeGen：
1. 安装 Xcode，并登录你的 Apple ID。
2. 安装 XcodeGen。
3. 在本目录运行：xcodegen generate
4. 打开生成的 BallAssist.xcodeproj。
5. 在主 App 和 Broadcast Extension 的 Signing & Capabilities 中：
   - 选择你的 Team
   - 启用 App Groups
   - 两个 target 都添加同一个群组：group.com.example.BallAssist
   - 如群组标识不能使用，请改成你自己的唯一标识，并同步修改两处 Swift 文件和两个 entitlements 文件。
6. 将 Bundle Identifier 改成你自己的唯一标识。
7. 选择 iPhone 12 真机，Build & Run。

测试
----
1. 打开 App。
2. 点击系统广播按钮。
3. 选择“球球AI助手屏幕识别”并开始广播。
4. 切换到游戏进行测试。
5. 回到 App 查看候选目标数量。

若广播扩展未显示：
- 检查 extension target 是否成功嵌入主 App。
- 检查 extension Info.plist 中 NSExtensionPointIdentifier。
- 检查 Bundle ID 和签名 Team。
- 检查 App Groups 是否在两个 target 中一致。

下一阶段
--------
必须先用实际游戏录像/授权广播画面测试，再采集标注数据，开发：
- 球体候选过滤
- 跨帧目标追踪
- 手动锁定目标
- 队友/敌人识别（需可靠的游戏内可见特征）
- 合球距离与时机提示

Windows 用户说明
----------------
Windows 本身不能运行 Xcode，也不能直接完成 iOS 原生签名。
需要可信的云端 macOS 构建服务或借用 Mac 完成构建和签名。
