import GoogleMobileAds
import SwiftUI
import UIKit

@MainActor
final class RewardedAdManager: ObservableObject {
    @Published var isShowingAd = false

    private var completionHandler: ((Bool) -> Void)?
    private(set) var preloadedAd: RewardedAd?

    func prepare() {
        MobileAds.shared.start()
        preloadRewardedAd()
    }

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard !isShowingAd else { return }
        completionHandler = completion
        isShowingAd = true
    }

    func finishRewardedAd(granted: Bool) {
        isShowingAd = false
        completionHandler?(granted)
        completionHandler = nil
        preloadedAd = nil
        preloadRewardedAd()
    }

    func takePreloadedAd() -> RewardedAd? {
        let ad = preloadedAd
        preloadedAd = nil
        return ad
    }

    private func preloadRewardedAd() {
        guard preloadedAd == nil else { return }

        RewardedAd.load(with: AdMobConfig.rewardedAdUnitID, request: Request()) { [weak self] ad, error in
            Task { @MainActor in
                if let error {
                    print("Rewarded ad failed to load: \(error.localizedDescription)")
                    return
                }
                self?.preloadedAd = ad
            }
        }
    }
}

// MARK: - SwiftUI bridge (same fullScreenCover flow as the old fake ad)

struct RewardedAdCover: View {
    @EnvironmentObject private var adManager: RewardedAdManager

    var body: some View {
        RewardedAdPresenter(
            adManager: adManager,
            onFinished: { granted in
                adManager.finishRewardedAd(granted: granted)
            }
        )
        .ignoresSafeArea()
    }
}

private struct RewardedAdPresenter: UIViewControllerRepresentable {
    let adManager: RewardedAdManager
    let onFinished: (Bool) -> Void

    func makeUIViewController(context: Context) -> RewardedAdViewController {
        RewardedAdViewController(adManager: adManager, onFinished: onFinished)
    }

    func updateUIViewController(_ uiViewController: RewardedAdViewController, context: Context) {}
}

@MainActor
private final class RewardedAdViewController: UIViewController, FullScreenContentDelegate {
    private let adManager: RewardedAdManager
    private let onFinished: (Bool) -> Void
    private var rewardedAd: RewardedAd?
    private var earnedReward = false
    private var didFinish = false
    private var didAttemptPresentation = false

    init(adManager: RewardedAdManager, onFinished: @escaping (Bool) -> Void) {
        self.adManager = adManager
        self.onFinished = onFinished
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAttemptPresentation else { return }
        didAttemptPresentation = true
        presentRewardedAd()
    }

    private func presentRewardedAd() {
        if let preloaded = adManager.takePreloadedAd() {
            show(preloaded)
            return
        }

        RewardedAd.load(with: AdMobConfig.rewardedAdUnitID, request: Request()) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
                if let ad {
                    self.show(ad)
                } else {
                    print("Rewarded ad failed to load: \(error?.localizedDescription ?? "unknown")")
                    self.complete(granted: false)
                }
            }
        }
    }

    private func show(_ ad: RewardedAd) {
        rewardedAd = ad
        ad.fullScreenContentDelegate = self
        ad.present(from: self) { [weak self] in
            self?.earnedReward = true
        }
    }

    private func complete(granted: Bool) {
        guard !didFinish else { return }
        didFinish = true
        onFinished(granted)
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        complete(granted: earnedReward)
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Rewarded ad failed to present: \(error.localizedDescription)")
        complete(granted: false)
    }
}
