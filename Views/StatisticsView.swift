import SwiftUI
import SwiftData
import Charts

// MARK: - StatisticsView

struct StatisticsView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Query(sort: \Project.totalDuration, order: .reverse) private var projects: [Project]

    /// Fixed palette so a project's chart slice and its list dot always match.
    /// Cycles if there are more projects than colors.
    private let palette: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow, .teal, .indigo, .red, .mint]

    var body: some View {
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
                    .foregroundStyle(by: .value("Project", project.name))
                }
                .chartForegroundStyleScale(
                    domain: projects.map { $0.name },
                    range: colors(for: projects.count)
                )
                .chartLegend(.hidden)
                .frame(height: 160)

                VStack(spacing: 6) {
                    ForEach(Array(projects.enumerated()), id: \.element.persistentModelID) { index, project in
                        HStack {
                            Circle()
                                .fill(color(at: index))
                                .frame(width: 8, height: 8)
                            Text(project.name)
                            Spacer()
                            Text(TimeFormatter.hoursMinutesSecondsString(from: project.totalDuration))
                        }
                        .foregroundColor(settings.textColor)
                    }
                }
            }
        }
    }

    private var totalTime: TimeInterval {
        projects.reduce(0) { $0 + $1.totalDuration }
    }

    private func color(at index: Int) -> Color {
        palette[index % palette.count]
    }

    private func colors(for count: Int) -> [Color] {
        (0..<count).map { color(at: $0) }
    }
}
