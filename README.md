# Jumpy Shawarma 🌯

Arcade iOS game built with **SwiftUI + SpriteKit**. Tap to flip the shawarma spit through grill obstacles and serve orders.

## Run

1. Open `JumpyShawarma.xcodeproj` in Xcode
2. Select an iPhone simulator
3. Press **⌘R**

**Controls:** tap / click to flap. Tap again after game over to retry.

## Project location

```
~/Desktop/Projects/jumpy-shawarma/
├── PLAN.md
├── JumpyShawarma.xcodeproj
└── JumpyShawarma/
    ├── App/JumpyShawarmaApp.swift
    ├── Game/GameScene.swift
    ├── Core/ …
    ├── Nodes/ …
    ├── Managers/ …
    ├── Environment/ …
    └── Assets.xcassets
```

## What's implemented

- Level dashboard with unlock logic
- Shawarma player with flap physics
- Themed grill obstacles
- Score + best score (saved locally)
- Level 1: 30 orders to complete
- Portrait-only

## Next steps

See **PLAN.md** for v1.1 polish (sounds, sprites, Game Center).

## Bundle ID

`com.ahmed.jumpyShawarma`
