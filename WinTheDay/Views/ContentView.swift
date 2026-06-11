import SwiftUI

enum Tab: String, CaseIterable {
    case timer
    case log
    case stats
    case settings

    var label: String {
        switch self {
        case .timer: return "Timer"
        case .log: return "Timeline"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .timer: return "clock"
        case .log: return "list.bullet"
        case .stats: return "chart.bar"
        case .settings: return "gearshape"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var settings: UserSettings
    @ObservedObject var timerViewModel: TimerViewModel
    @State private var selectedTab: Tab = .timer

    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .timer:
                    TimerView(viewModel: timerViewModel, onBlockComplete: { selectedTab = .log })
                case .log:
                    BlockLogView(onSwitchToTimer: { selectedTab = .timer })
                case .stats:
                    StatsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(selectedTab)

            Divider()

            // Bottom tab bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 8)
        }
        .onAppear {
            timerViewModel.setDuration(minutes: settings.defaultDurationMinutes)
        }
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14))
                Text(tab.label)
                    .font(.system(size: 10))
            }
            .foregroundStyle(selectedTab == tab ? accentColor : .secondary)
            .frame(width: 60, height: 36)
        }
        .buttonStyle(.plain)
    }
}
