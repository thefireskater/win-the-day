import SwiftUI

struct DurationPickerView: View {
    let selectedMinutes: Int
    let onSelect: (Int) -> Void
    let onCancel: () -> Void
    @Binding var customText: String
    @FocusState private var isCustomFieldFocused: Bool

    private let presets = [15, 25, 45, 60]
    private let accentColor: Color = .appAccent

    var body: some View {
        VStack(spacing: 16) {
            TextField("min", text: $customText)
                .font(.system(size: 72, weight: .ultraLight))
                .monospacedDigit()
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .focused($isCustomFieldFocused)
                .onSubmit {
                    if let value = Int(customText), value > 0, value <= 120 {
                        onSelect(value)
                    }
                }
                .onExitCommand {
                    onCancel()
                }

            HStack(spacing: 12) {
                ForEach(presets, id: \.self) { minutes in
                    Button {
                        onSelect(minutes)
                    } label: {
                        Text("\(minutes)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(minutes == selectedMinutes ? accentColor : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(minutes == selectedMinutes ? accentColor.opacity(0.15) : .clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            customText = "\(selectedMinutes)"
            isCustomFieldFocused = true
        }
    }
}
