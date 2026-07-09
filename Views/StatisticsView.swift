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

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 12) {
                if totalTime == 0 {
                    Text("No data yet")
                        .foregroundColor(settings.textColor.opacity(0.6))
                        .frame(height: 160)
                } else {
                    Chart(projects) { project in
                        SectorMark(
                            angle: .value("Time", project.totalDuration),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(project.displayColor)
                    }
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
        let pickerWidth: CGFloat = 130   // must match boxSize above
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
        .frame(width: pickerWidth + padding * 2)   // <- ties outer width to inner content
    }
    
    private var totalTime: TimeInterval {
        projects.reduce(0) { $0 + $1.totalDuration }
    }
}
