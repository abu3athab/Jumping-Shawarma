import SwiftUI
import SpriteKit

@main
struct JumpyShawarmaApp: App {
    @StateObject private var rewardedAdManager = RewardedAdManager()

    init() {
        migrateLegacyUserDefaults()
        UIWindow.appearance().backgroundColor = UIColor(red: 0.42, green: 0.2, blue: 0.16, alpha: 1)
        GameAudioManager.shared.prepare()
    }

    private func migrateLegacyUserDefaults() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: GameConstants.bestScoreKey) == nil,
           defaults.object(forKey: "jumping_shawarma_best") != nil {
            defaults.set(defaults.integer(forKey: "jumping_shawarma_best"), forKey: GameConstants.bestScoreKey)
        }

        if defaults.object(forKey: "jumpy_shawarma_completed_levels") == nil,
           let completedLevels = defaults.array(forKey: "jumping_shawarma_completed_levels") {
            defaults.set(completedLevels, forKey: "jumpy_shawarma_completed_levels")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .background(AppColors.dashboard.ignoresSafeArea())
                .environmentObject(rewardedAdManager)
                .onAppear {
                    rewardedAdManager.prepare()
                }
        }
    }
}

private enum AppColors {
    static let dashboard = Color(red: 0.42, green: 0.2, blue: 0.16)
}

struct RootView: View {
    @State private var activeLevel: LevelConfig?

    var body: some View {
        ZStack {
            AppColors.dashboard
                .ignoresSafeArea()

            LevelSelectView { level in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    activeLevel = level
                }
            }

            if let level = activeLevel {
                GameContainerView(
                    level: level,
                    onExit: {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            activeLevel = nil
                        }
                    },
                    onNextLevel: { nextLevel in
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            activeLevel = nextLevel
                        }
                    }
                )
                .id(level)
            }
        }
        .task {
            GameAssetLoader.preloadIfNeeded()
        }
    }
}

private extension ThemePalette {
    var swiftUIBackground: Color {
        Color(uiColor: background)
    }

    var swiftUIAccent: Color {
        Color(uiColor: accent)
    }
}

struct GameContainerView: View {
    let level: LevelConfig
    let onExit: () -> Void
    let onNextLevel: (LevelConfig) -> Void

    @EnvironmentObject private var rewardedAdManager: RewardedAdManager
    @State private var scene: GameScene?
    @State private var showsLevelsButton = true
    @State private var safeAreaTop: CGFloat = 0
    @State private var freezesSceneLayout = false

    private let fallbackSceneHeight: CGFloat = 852

    init(level: LevelConfig, onExit: @escaping () -> Void, onNextLevel: @escaping (LevelConfig) -> Void) {
        self.level = level
        self.onExit = onExit
        self.onNextLevel = onNextLevel
    }

    var body: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top

            ZStack {
                level.theme.swiftUIBackground
                    .ignoresSafeArea()

                if let scene {
                    GameSpriteView(scene: scene, backgroundColor: level.theme.background)
                        .ignoresSafeArea()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                if showsLevelsButton {
                    Button(action: {
                        GameAudioManager.shared.playButtonTap()
                        onExit()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Levels")
                        }
                        .font(.custom("AvenirNext-DemiBold", size: 15))
                        .foregroundStyle(level.theme.swiftUIAccent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(level.theme.swiftUIAccent.opacity(0.18), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(level.theme.swiftUIAccent.opacity(0.55), lineWidth: 1.5)
                        )
                    }
                    .padding(.leading, 16)
                    .padding(.top, GameHUDLayout.hudTopPadding(safeAreaTop: safeTop))
                }
            }
            .onAppear {
                syncLayout(size: proxy.size, safeAreaTop: safeTop)
            }
            .onChange(of: proxy.size) { _, newSize in
                syncLayout(size: newSize, safeAreaTop: proxy.safeAreaInsets.top)
            }
            .onChange(of: proxy.safeAreaInsets.top) { _, newTop in
                syncLayout(size: proxy.size, safeAreaTop: newTop)
            }
            .onChange(of: scene != nil) { _, _ in
                syncLayout(size: proxy.size, safeAreaTop: proxy.safeAreaInsets.top)
            }
        }
        .task(id: level.id) {
            GameAssetLoader.preloadIfNeeded()
            let newScene = GameScene(size: CGSize(width: 393, height: fallbackSceneHeight), level: level)
            wireScene(newScene)
            scene = newScene
        }
        .fullScreenCover(isPresented: $rewardedAdManager.isShowingAd) {
            RewardedAdCover()
                .environmentObject(rewardedAdManager)
        }
    }

    private func syncLayout(size: CGSize, safeAreaTop: CGFloat) {
        self.safeAreaTop = safeAreaTop
        guard let scene else { return }
        guard size.width > 0, size.height > 0 else { return }

        if !freezesSceneLayout {
            scene.size = size
        }
        scene.applySafeArea(top: safeAreaTop)
    }

    private func wireScene(_ scene: GameScene) {
        scene.onNextLevel = onNextLevel
        scene.onWatchAdToContinue = { completion in
            rewardedAdManager.showRewardedAd(completion: completion)
        }
        scene.onStateChange = { state in
            freezesSceneLayout = state == .gameOver || state == .continueCountdown
            showsLevelsButton = state == .ready
                || state == .gameOver
                || state == .levelComplete
        }
        showsLevelsButton = true
    }
}
