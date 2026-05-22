import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject private var settings: UserSettings
    @State private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.system(size: 16, weight: .semibold))

            settingRow("Default Duration") {
                Stepper(
                    "\(settings.defaultDurationMinutes) min",
                    value: $settings.defaultDurationMinutes,
                    in: 5...120,
                    step: 5
                )
                .font(.system(size: 14))
            }

            settingRow("Daily Goal") {
                Stepper(
                    settings.dailyGoalMinutes == 0 ? "Disabled" : "\(settings.dailyGoalMinutes) min",
                    value: $settings.dailyGoalMinutes,
                    in: 0...480,
                    step: 15
                )
                .font(.system(size: 14))
            }

            settingRow("Launch at Login") {
                Toggle("", isOn: $launchAtLogin)
                    .toggleStyle(.switch)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 350, height: 300)
    }

    private func settingRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.primary)
            Spacer()
            content()
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLogin = !enabled
        }
    }
}
