import SwiftUI

private enum DashboardTheme {
    static let background = Color(red: 0.42, green: 0.2, blue: 0.16)
    static let card = Color(red: 0.12, green: 0.08, blue: 0.06).opacity(0.88)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.35)
    static let cream = Color(red: 0.98, green: 0.93, blue: 0.82)
    static let ember = Color(red: 1.0, green: 0.45, blue: 0.12)
    static let muted = Color.white.opacity(0.45)
}

struct LevelSelectView: View {
    let onSelectLevel: (LevelConfig) -> Void

    var body: some View {
        ZStack {
            DashboardTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Jumpy Shawarma")
                        .font(.custom("AvenirNext-Heavy", size: 32))
                        .foregroundStyle(DashboardTheme.cream)

                    Text("Choose a level")
                        .font(.custom("AvenirNext-Medium", size: 17))
                        .foregroundStyle(DashboardTheme.gold.opacity(0.9))
                }
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(LevelConfig.allCases, id: \.rawValue) { level in
                            LevelRow(
                                level: level,
                                isUnlocked: LevelProgress.isUnlocked(level),
                                isCompleted: LevelProgress.isCompleted(level),
                                onSelect: { onSelectLevel(level) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            .safeAreaPadding(.horizontal)
            .safeAreaPadding(.top, 8)
        }
    }
}

private struct LevelRow: View {
    let level: LevelConfig
    let isUnlocked: Bool
    let isCompleted: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? DashboardTheme.gold.opacity(0.18) : Color.white.opacity(0.06))
                    .frame(width: 52, height: 52)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DashboardTheme.gold)
                } else if isUnlocked {
                    Text("\(level.id)")
                        .font(.custom("AvenirNext-Bold", size: 22))
                        .foregroundStyle(DashboardTheme.gold)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(DashboardTheme.muted)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(level.id) · \(level.name)")
                    .font(.custom("AvenirNext-DemiBold", size: 18))
                    .foregroundStyle(isUnlocked ? DashboardTheme.cream : DashboardTheme.muted)

                Text(subtitle)
                    .font(.custom("AvenirNext-Medium", size: 14))
                    .foregroundStyle(isUnlocked ? DashboardTheme.gold.opacity(0.85) : DashboardTheme.muted)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DashboardTheme.gold.opacity(0.8))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(DashboardTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isCompleted ? DashboardTheme.gold.opacity(0.7) : DashboardTheme.gold.opacity(isUnlocked ? 0.25 : 0.1),
                            lineWidth: isCompleted ? 2 : 1
                        )
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {
            guard isUnlocked else { return }
            GameAudioManager.shared.playButtonTap()
            onSelect()
        }
        .opacity(isUnlocked ? 1 : 0.55)
    }

    private var subtitle: String {
        if isCompleted {
            return "Completed · \(level.ordersRequired) orders"
        }
        if isUnlocked {
            return level.levelDesciption
        }
        if let previous = level.previous {
            return "Complete Level \(previous.id) to unlock"
        }
        return "Locked"
    }
}

#Preview {
    LevelSelectView { _ in }
}
