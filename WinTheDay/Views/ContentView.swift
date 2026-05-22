import SwiftUI

enum Tab: String, CaseIterable {
    case timer
    case log
    case stats

    var label: String {
        switch self {
        case .timer: return "Timer"
        case .log: return "Log"
        case .stats: return "Stats"
        }
    }

    var icon: String {
        switch self {
        case .timer: return "clock"
        case .log: return "list.bullet"
        case .stats: return "chart.bar"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var settings: UserSettings
    @StateObject private var timerViewModel = TimerViewModel()
    @State private var selectedTab: Tab = .timer
    @State private var showSettings = false

    private let accentColor = Color(hue: 35/360, saturation: 0.8, brightness: 0.55)

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            Group {
                switch selectedTab {
                case .timer:
                    TimerView(viewModel: timerViewModel)
                case .log:
                    BlockLogView(onSwitchToTimer: { selectedTab = .timer })
                case .stats:
                    StatsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Bottom tab bar
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tabButton(tab)
                }

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 36)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
