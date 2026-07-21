import SwiftUI

// MARK: - MenuBarLabel

struct MenuBarLabel: View {
    @ObservedObject private var timerManager = TimerManager.shared

    var body: some View {
        Image(nsImage: renderedImage)
    }

    private var renderedImage: NSImage {
        let content: AnyView
        if timerManager.isRunningAnything {
            content = AnyView(
                HStack(spacing: 4) {
                    Image(systemName: "stopwatch")
                    Text(TimeFormatter.menuBarString(from: timerManager.elapsed))
                        .monospacedDigit()
                }
                .font(.system(size: 13))
                .foregroundColor(.white)
            )
        } else {
            content = AnyView(
                Image(systemName: "stopwatch")
                    .foregroundColor(.white)
            )
        }

        let renderer = ImageRenderer(content: content)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
        return renderer.nsImage ?? NSImage()
    }
}
