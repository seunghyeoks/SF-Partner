import SwiftUI

struct SettingsView: View {
    @Environment(IconManager.self) private var iconManager
    @Environment(AppMonitor.self) private var appMonitor
    @State private var newIconName: String = ""
    @State private var newCpuUsageThreshold : Double = 80.0 
    @State private var newMemoryUsageThreshold : Double = 80.0
    @Binding var showingIconEditor : Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("localize/button/back") {
                    showingIconEditor = false
                }
                .buttonStyle(.plain)
                .controlSize(.small)
                .font(.subheadline)

                Spacer()
                
                Button("localize/button/confirm") {
                    applyIconChange(newIconName)
                    applyThresholdChange()
                    showingIconEditor = false
                }
                .disabled(!isValidIcon(newIconName) || (newIconName == iconManager.currentIcon && newCpuUsageThreshold == appMonitor.cpuUsageThreshold && newMemoryUsageThreshold == appMonitor.memoryUsageThreshold))
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .font(.subheadline)
            }
            .padding(.bottom, 6)
            
            Divider()
            
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 4) {
                    if newIconName.isEmpty {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                        Text("localize/desc/preview")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else if isValidIcon(newIconName) {
                        Image(systemName: newIconName)
                            .font(.system(size: 24))
                            .foregroundStyle(.green)
                        Text("localize/desc/valid")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 24))
                            .foregroundStyle(.red)
                        Text("localize/desc/not_valid")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Spacer()
            }
            
            // 텍스트 입력
            VStack(alignment: .leading, spacing: 6) {
                Text("localize/title/type-sf")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("localize/desc/eg_sf", text: $newIconName)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 1) {
                    ForEach(["cellularbars", "gauge.chart.leftthird.topthird.rightthird", "ring.dashed", "ellipsis", "timelapse", "rainbow"], id: \.self) { icon in
                        Button(action: {
                            newIconName = icon
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: icon)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                                    .frame(height: 10)
                                Text(icon.components(separatedBy: ".").first ?? icon)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(4)
                        .buttonStyle(.plain)
                        .frame(width: 60, height: 30)
                        .contentShape(RoundedRectangle(cornerRadius: 6))
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(newIconName == icon ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
                        )
                    }
                }
            }
            
            Divider()

            VStack {
                HStack {
                    Text("localize/title/cpu_threshold")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(newCpuUsageThreshold))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $newCpuUsageThreshold, in: 1...89, step: 1)
            }

            VStack {
                HStack {
                    Text("localize/title/mem_threshold")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(Int(newMemoryUsageThreshold))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $newMemoryUsageThreshold, in: 1...89, step: 1)
            }

        }
        .padding(16)
        .frame(width: 220)
        .onAppear {
            newIconName = iconManager.currentIcon
            newCpuUsageThreshold = appMonitor.cpuUsageThreshold
            newMemoryUsageThreshold = appMonitor.memoryUsageThreshold
        }
    }
    
    private func isValidIcon(_ iconName: String) -> Bool {
        let trimmedName = iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && (NSImage(systemSymbolName: trimmedName, accessibilityDescription: nil) != nil)
    }

    private func applyIconChange(_ newIconName: String) {
        let trimmedName = newIconName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty && isValidIcon(trimmedName) {
            iconManager.updateIcon(to: trimmedName)
        }
    }

    private func applyThresholdChange() {
        appMonitor.updateCpuThresholds(newThreshold: newCpuUsageThreshold)
        appMonitor.updateMemoryThresholds(newThreshold: newMemoryUsageThreshold)
    }
}
