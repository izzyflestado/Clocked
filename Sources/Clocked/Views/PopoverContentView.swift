import SwiftUI

// MARK: - PopoverContentView

struct PopoverContentView: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var selectedTab: Tab = .timer
    @State private var showingSettings = false

    private enum Tab: String, CaseIterable {
        case timer = "Timer"
        case statistics = "Statistics"
    }

    var body: some View {
        VStack(spacing: 12) {
            if showingSettings {
                SettingsView(onDone: { showingSettings = false })
                    .environmentObject(settings)
            } else {
                HStack {
                    Picker("", selection: $selectedTab) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()

                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top)

                Group {
                    switch selectedTab {
                    case .timer:
                        TimerView()
                    case .statistics:
                        StatisticsView()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .frame(width: 310)
        .background(settings.backgroundColor)
        .foregroundColor(settings.textColor)
    }
}
