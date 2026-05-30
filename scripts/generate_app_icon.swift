import AppKit
import CoreGraphics

let size = 1024
let outputURL = URL(fileURLWithPath: "/Users/abu_3athab/Desktop/Projects/jumpy-shawarma/JumpyShawarma/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
let shawarmaURL = URL(fileURLWithPath: "/Users/abu_3athab/Desktop/Projects/jumpy-shawarma/JumpyShawarma/Assets.xcassets/ShawarmaPlayer.imageset/shawarma-player.png")

guard let shawarma = NSImage(contentsOf: shawarmaURL) else {
    fputs("Failed to load shawarma image\n", stderr)
    exit(1)
}

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fputs("Failed to create context\n", stderr)
    exit(1)
}

context.setFillColor(CGColor(red: 0.42, green: 0.2, blue: 0.16, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: size, height: size))

let margin: CGFloat = 52
let borderRect = CGRect(x: margin, y: margin, width: CGFloat(size) - margin * 2, height: CGFloat(size) - margin * 2)
context.setStrokeColor(CGColor(red: 1.0, green: 0.84, blue: 0.35, alpha: 0.35))
context.setLineWidth(10)
context.addPath(CGPath(roundedRect: borderRect, cornerWidth: 180, cornerHeight: 180, transform: nil))
context.strokePath()

let targetWidth = CGFloat(size) * 0.62
let shawarmaSize = shawarma.size
let scale = min(targetWidth / shawarmaSize.width, targetWidth / shawarmaSize.height)
let drawWidth = shawarmaSize.width * scale
let drawHeight = shawarmaSize.height * scale
let drawRect = CGRect(
    x: (CGFloat(size) - drawWidth) / 2,
    y: (CGFloat(size) - drawHeight) / 2 - 18,
    width: drawWidth,
    height: drawHeight
)

context.interpolationQuality = .high
if let cgImage = shawarma.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    context.draw(cgImage, in: drawRect)
}

guard let finalImage = context.makeImage() else {
    fputs("Failed to make image\n", stderr)
    exit(1)
}

let rep = NSBitmapImageRep(cgImage: finalImage)
guard let pngData = rep.representation(using: .png, properties: [:]) else {
    fputs("Failed to encode png\n", stderr)
    exit(1)
}

try pngData.write(to: outputURL)
print("Saved \(outputURL.path)")
