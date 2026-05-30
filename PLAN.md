# Jumpy Shawarma — Game Plan

## Concept
An arcade game for iOS. The player taps to keep a **shawarma** flying through gaps between vertical obstacles (grill poles / pita walls). One mistake = game over.

## Tech stack
| Layer | Choice | Why |
|-------|--------|-----|
| Platform | iOS 17+ | Modern SwiftUI app shell |
| Engine | **SpriteKit** | Built-in 2D physics for arcade gameplay |
| UI shell | SwiftUI `SpriteView` | Simple launch, full-screen game |
| Language | Swift | Native performance |
| Assets | Code-drawn + emoji | No external art required for MVP |

## Core mechanics
1. **Gravity** pulls the shawarma down constantly.
2. **Tap** applies upward impulse (flap).
3. **Obstacle pairs** scroll left with a fixed gap.
4. **Score +1** when passing each gap (invisible score trigger).
5. **Collision** with pipe or ground → game over.
6. **Tap to restart** on game over screen.

## Game states
```
ready → playing → gameOver → ready
```
- **Ready:** “Tap to start” overlay.
- **Playing:** Physics active, pipes spawning.
- **Game over:** Show score + best score, tap to retry.

## Milestones

### MVP (this project) ✅
- [x] Jumpy shawarma with physics
- [x] Scrolling pipe obstacles
- [x] Score + best score (UserDefaults)
- [x] Game over + restart
- [x] Sky / ground visuals

### v1.1 — Polish
- [ ] Custom shawarma sprite (PNG)
- [ ] Sound effects (flap, score, crash)
- [ ] Haptic feedback on flap / death
- [ ] Parallax background ( kitchen / street )

### v1.2 — Retention
- [ ] Daily best leaderboard (Game Center)
- [ ] Skins (falafel, kebab, etc.)
- [ ] Difficulty modes (gap size, speed)

### v2 — Monetization (optional)
- [ ] Remove ads IAP
- [ ] Extra skins IAP
- [ ] Interstitial every N deaths (AdMob)

## Architecture
```
JumpyShawarmaApp.swift     → App entry, hosts SpriteView
GameScene.swift            → All game logic (SpriteKit)
Assets.xcassets            → App icon, accent color
```

Single-scene design keeps MVP simple. Split into `BirdNode`, `PipePairNode`, `GameState` later if the project grows.

## App Store checklist (later)
- [ ] Apple Developer account
- [ ] App icon 1024×1024
- [ ] Privacy policy URL (if ads/analytics)
- [ ] Screenshots (6.7", 6.5", iPad if universal)
- [ ] Age rating: 4+ (arcade)
- [ ] Bundle ID: `com.ahmed.jumpyShawarma`

## How to run
1. Open `JumpyShawarma.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. **Product → Run** (⌘R).
4. Click/tap in the simulator to flap.

## Controls
- **Simulator:** mouse click = tap
- **Device:** touch anywhere on screen
