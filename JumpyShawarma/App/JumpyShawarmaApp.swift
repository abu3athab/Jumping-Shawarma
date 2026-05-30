import SwiftUI
import SpriteKit

@main
struct JumpyShawarmaApp: App {
    @StateObject private var rewardedAdManager = RewardedAdManager()

    init() {
        migrateLegacyUserDefaults()
        UIWindow.appearance().backgroundColor = UIColor(red: 0.42, green: 0.2, blue: 0.16, alpha: 1)
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
    @State private var scene: GameScene
    @State private var showsLevelsButton = true
    @State private var safeAreaTop: CGFloat = 0
    @State private var freezesSceneLayout = false

    init(level: LevelConfig, onExit: @escaping () -> Void, onNextLevel: @escaping (LevelConfig) -> Void) {
        self.level = level
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        _scene = State(initialValue: GameScene(size: CGSize(width: 393, height: 852), level: level))
    }

    var body: some View {
        ZStack {
            level.theme.swiftUIBackground
                .ignoresSafeArea()

            GameSpriteView(scene: scene, backgroundColor: level.theme.background)
                .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            if showsLevelsButton {
                Button(action: onExit) {
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
                .padding(
                    .top,
                    GameHUDLayout.scoreBadgeTopFromScreenTop(
                        sceneHeight: scene.size.height,
                        safeAreaTop: safeAreaTop
                    )
                )
            }
        }
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        updateSceneLayout(size: proxy.size, safeAreaTop: proxy.safeAreaInsets.top)
                    }
                    .onChange(of: proxy.size) { _, newSize in
                        updateSceneLayout(size: newSize, safeAreaTop: proxy.safeAreaInsets.top)
                    }
                    .onChange(of: proxy.safeAreaInsets.top) { _, newTop in
                        updateSceneLayout(size: proxy.size, safeAreaTop: newTop)
                    }
            }
        }
        .onAppear {
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
        .fullScreenCover(isPresented: $rewardedAdManager.isShowingAd) {
            SimulatedRewardedAdView { granted in
                rewardedAdManager.finishRewardedAd(granted: granted)
            }
        }
    }

    private func updateSceneLayout(size: CGSize, safeAreaTop: CGFloat) {
        guard size.width > 0, size.height > 0 else { return }
        guard !freezesSceneLayout else { return }
        self.safeAreaTop = safeAreaTop
        scene.size = size
        scene.applySafeArea(top: safeAreaTop)
    }
}
