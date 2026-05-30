import SwiftUI

@MainActor
final class RewardedAdManager: ObservableObject {
    @Published var isShowingAd = false

    private var completionHandler: ((Bool) -> Void)?

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard !isShowingAd else { return }
        completionHandler = completion
        isShowingAd = true
    }

    func finishRewardedAd(granted: Bool) {
        isShowingAd = false
        completionHandler?(granted)
        completionHandler = nil
    }
}

struct SimulatedRewardedAdView: View {
    let onFinished: (Bool) -> Void

    @State private var secondsRemaining = 3

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.35))

                Text("Rewarded Ad")
                    .font(.custom("AvenirNext-Heavy", size: 24))
                    .foregroundStyle(.white)

                Text("Watch to keep your orders and continue")
                    .font(.custom("AvenirNext-Medium", size: 15))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Resuming in \(secondsRemaining)s…")
                    .font(.custom("AvenirNext-DemiBold", size: 17))
                    .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.35))
            }
        }
        .onAppear {
            tick()
        }
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            onFinished(true)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            secondsRemaining -= 1
            tick()
        }
    }
}
