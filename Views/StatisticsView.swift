import SwiftUI
import SwiftData
import Charts

// MARK: - Row frame tracking (so the popup can anchor above the tapped row)

private struct RowFramePreferenceKey: PreferenceKey {
    static var defaultValue: [PersistentIdentifier: CGRect] = [:]
    static func reduce(value: inout [PersistentIdentifier: CGRect], nextValue: () -> [PersistentIdentifier: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - StatisticsView

struct StatisticsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.totalDuration, order: .reverse) private var projects: [Project]

    @State private var editingProjectID: PersistentIdentifier?
    @State private var tempColor: Color = .white
    @State private var rowFrames: [PersistentIdentifier: CGRect] = [:]
    @State private var hoveredProjectID: PersistentIdentifier?

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 12) {
                if totalTime == 0 {
                    Text("No data yet")
                        .foregroundColor(settings.textColor.opacity(0.6))
                        .frame(height: 160)
                } else {
                    pieChart
                        .frame(height: 160)

                    VStack(spacing: 6) {
                        ForEach(projects, id: \.persistentModelID) { project in
                            HStack {
                                colorSwatchButton(for: project)
                                Text(project.name)
                                Spacer()
                                Text(TimeFormatter.hoursMinutesSecondsString(from: project.totalDuration))
                            }
                            .foregroundColor(settings.textColor)
                        }
                    }
                }
            }

            if let editingID = editingProjectID,
               let project = projects.first(where: { $0.persistentModelID == editingID }),
               let frame = rowFrames[editingID] {
                colorEditor(for: project)
                    .position(x: max(100, frame.minX + 77), y: frame.minY - 105)
            }
        }
        .coordinateSpace(name: "legend")
        .onPreferenceChange(RowFramePreferenceKey.self) { rowFrames = $0 }
    }

    // MARK: - Pie chart with hover-to-expand

    private var pieChart: some View {
        ZStack {
            Chart(projects) { project in
                SectorMark(
                    angle: .value("Time", project.totalDuration),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(project.persistentModelID == hoveredProjectID ? 1.08 : 1.0)
                )
                .foregroundStyle(project.displayColor)
                .opacity(hoveredProjectID == nil || project.persistentModelID == hoveredProjectID ? 1.0 : 0.6)
            }
            .animation(.easeOut(duration: 0.15), value: hoveredProjectID)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onContinuousHover { phase in
                            guard let anchor = proxy.plotFrame else {
                                hoveredProjectID = nil
                                return
                            }
                            let plotRect = geo[anchor]
                            switch phase {
                            case .active(let location):
                                hoveredProjectID = hitTest(location: location, in: plotRect)
                            case .ended:
                                hoveredProjectID = nil
                            }
                        }
                }
            }

            if let hoveredID = hoveredProjectID,
               let hovered = projects.first(where: { $0.persistentModelID == hoveredID }) {
                GeometryReader { geo in
                    let innerDiameter = min(geo.size.width, geo.size.height) * 0.5
                    let safeWidth = innerDiameter - 16 // padding so text never touches the ring

                    VStack(spacing: 2) {
                        Text(hovered.name)
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.center)
                        Text(TimeFormatter.hoursMinutesSecondsString(from: hovered.totalDuration))
                            .font(.system(size: 11))
                            .foregroundColor(settings.textColor.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundColor(settings.textColor)
                    .frame(width: max(safeWidth, 0))
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .allowsHitTesting(false)
            }
        }
    }
    
    /// Maps a hover point to the project whose slice contains it, based on
    /// cumulative angle (matches SectorMark's own ordering/inset) and radius
    /// (must land within the donut ring, not the empty center or outside it).
    private func hitTest(location: CGPoint, in plotRect: CGRect) -> PersistentIdentifier? {
        let center = CGPoint(x: plotRect.midX, y: plotRect.midY)
        let dx = location.x - center.x
        let dy = location.y - center.y
        let radius = sqrt(dx * dx + dy * dy)

        let maxRadius = min(plotRect.width, plotRect.height) / 2
        let innerRadius = maxRadius * 0.5
        guard radius >= innerRadius, radius <= maxRadius else { return nil }

        var angle = atan2(dx, -dy) * 180 / .pi
        if angle < 0 { angle += 360 }

        guard totalTime > 0 else { return nil }

        var cumulative: Double = 0
        for project in projects {
            let sliceAngle = (project.totalDuration / totalTime) * 360
            if angle >= cumulative && angle < cumulative + sliceAngle {
                return project.persistentModelID
            }
            cumulative += sliceAngle
        }
        return nil
    }

    // MARK: - Legend swatch button

    @ViewBuilder
    private func colorSwatchButton(for project: Project) -> some View {
        Button {
            if editingProjectID == project.persistentModelID {
                editingProjectID = nil
            } else {
                tempColor = project.displayColor
                editingProjectID = project.persistentModelID
            }
        } label: {
            Circle()
                .fill(project.displayColor)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: RowFramePreferenceKey.self,
                    value: [project.persistentModelID: geo.frame(in: .named("legend"))]
                )
            }
        )
    }

    // MARK: - Floating color editor popup

    @ViewBuilder
    private func colorEditor(for project: Project) -> some View {
        let pickerWidth: CGFloat = 130
        let padding: CGFloat = 10

        VStack(spacing: 10) {
            CustomColorPicker(color: $tempColor)

            HStack(spacing: 8) {
                Button("Cancel") {
                    editingProjectID = nil
                }
                .frame(width: pickerWidth * 0.4)

                Button("Confirm") {
                    project.colorHex = tempColor.toHex()
                    try? modelContext.save()
                    editingProjectID = nil
                }
                .frame(width: pickerWidth * 0.6)
                .buttonStyle(.borderedProminent)
            }
            .frame(height: 28)
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 8)
        )
        .frame(width: pickerWidth + padding * 2)
    }

    private var totalTime: TimeInterval {
        projects.reduce(0) { $0 + $1.totalDuration }
    }
}
