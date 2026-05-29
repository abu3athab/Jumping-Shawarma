import SwiftUI
import SpriteKit

@main
struct JumpingShawarmaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

private enum AppScreen: Equatable {
    case dashboard
    case game(LevelConfig)
}

struct RootView: View {
    @State private var screen: AppScreen = .dashboard

    var body: some View {
        switch screen {
        case .dashboard:
            LevelSelectView { level in
                screen = .game(level)
            }
        case .game(let level):
            GameContainerView(
                level: level,
                onExit: { screen = .dashboard },
                onNextLevel: { screen = .game($0) }
            )
        }
    }
}

struct GameContainerView: View {
    let level: LevelConfig
    let onExit: () -> Void
    let onNextLevel: (LevelConfig) -> Void

    @State private var scene: GameScene
    @State private var showsLevelsButton = true

    init(level: LevelConfig, onExit: @escaping () -> Void, onNextLevel: @escaping (LevelConfig) -> Void) {
        self.level = level
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        _scene = State(initialValue: GameScene(size: CGSize(width: 393, height: 852), level: level))
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                if showsLevelsButton {
                    Button(action: onExit) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Levels")
                        }
                        .font(.custom("AvenirNext-DemiBold", size: 15))
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.35))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.35), in: Capsule())
                    }
                    .padding(.leading, 16)
                    .padding(
                        .top,
                        GameHUDLayout.scoreBadgeTopFromScreenTop(
                            sceneHeight: proxy.size.height,
                            safeAreaTop: proxy.safeAreaInsets.top
                        )
                    )
                }
            }
            .onAppear {
                scene.onNextLevel = onNextLevel
                scene.onStateChange = { state in
                    showsLevelsButton = state != .playing
                }
                showsLevelsButton = true
                updateSceneLayout(proxy: proxy)
            }
            .onChange(of: proxy.size) { _, _ in
                updateSceneLayout(proxy: proxy)
            }
            .onChange(of: proxy.safeAreaInsets.top) { _, _ in
                updateSceneLayout(proxy: proxy)
            }
        }
    }

    private func updateSceneLayout(proxy: GeometryProxy) {
        guard proxy.size.width > 0, proxy.size.height > 0 else { return }
        scene.size = proxy.size
        scene.applySafeArea(top: proxy.safeAreaInsets.top)
    }
}
