import SwiftUI
import AppKit

// MARK: - CustomColorPicker

struct CustomColorPicker: View {
    @Binding var color: Color

    @State private var hue: Double = 0
    @State private var saturation: Double = 1
    @State private var brightness: Double = 1

    private let boxSize: CGFloat = 130
    private let barHeight: CGFloat = 14

    var body: some View {
        VStack(spacing: 10) {
            svBox
            hueBar
        }
        .onAppear {
            let (h, s, b) = color.hsbComponents()
            hue = h
            saturation = s
            brightness = b
        }
    }

    private var svBox: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [.white, Color(hue: hue, saturation: 1, brightness: 1)],
                startPoint: .leading, endPoint: .trailing
            )
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .top, endPoint: .bottom
            )
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 14, height: 14)
                .shadow(radius: 1)
                .position(x: saturation * boxSize, y: (1 - brightness) * boxSize)
        }
        .frame(width: boxSize, height: boxSize)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    saturation = min(max(0, value.location.x), boxSize) / boxSize
                    brightness = 1 - (min(max(0, value.location.y), boxSize) / boxSize)
                    updateColor()
                }
        )
    }

    private var hueBar: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: stride(from: 0.0, through: 1.0, by: 0.02)
                    .map { Color(hue: $0, saturation: 1, brightness: 1) },
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: boxSize, height: barHeight)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: barHeight, height: barHeight)
                .shadow(radius: 1)
                .offset(x: hue * boxSize - barHeight / 2)
        }
        .frame(width: boxSize, height: barHeight)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    hue = min(max(0, value.location.x), boxSize) / boxSize
                    updateColor()
                }
        )
    }

    private func updateColor() {
        color = Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

// MARK: - HSB extraction helper

extension Color {
    func hsbComponents() -> (hue: Double, saturation: Double, brightness: Double) {
        let nsColor = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        nsColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h), Double(s), Double(b))
    }
}
