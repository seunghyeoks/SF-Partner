import SwiftUI

struct DashBoardView: View {
    @Environment(AppMonitor.self) private var appMonitor
    @State private var showingIconEditor = false
    
    var body: some View {
        if !showingIconEditor {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cpu")
                        .font(.title3)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("localize/title/cpu_usage")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(appMonitor.cpuName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%.1f%@", appMonitor.cpuUsage, "%"))
                        .font(.title2)
                        .foregroundStyle(colorForCpuUsage(appMonitor.cpuUsage))
                }
                
                HStack {
                    Image(systemName: "memorychip")
                        .font(.title3)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("localize/title/memory_usage")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(String(format: "%d%@", appMonitor.memorySize, "GB"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(String(format: "%.1f%@", appMonitor.memoryPressure, "%"))
                        .font(.title2)
                        .foregroundStyle(colorForMemoryUsage(appMonitor.memoryPressure))
                }
                
                Divider()
                
                Group {
                    Button("localize/title/activity_monitor", systemImage: "waveform.path.ecg") {
                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ActivityMonitor") {
                            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration()) { _, _ in }
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    
                    Button("localize/title/Setting", systemImage: "gearshape") {
                        showingIconEditor = true
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    
                    Button("localize/title/quit_app", systemImage: "xmark.circle") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                }
            }
            .padding(16)
            .frame(width: 200)
        } else {
            SettingsView(showingIconEditor: $showingIconEditor)
        }
    }

    private func colorForCpuUsage(_ usage: Double) -> Color {
        let upperBound: Double = min(100.0, max(90, appMonitor.cpuUsageThreshold + 10.0))
        
        if usage < appMonitor.cpuUsageThreshold {
            return .green
        } else if usage < upperBound {
            return .orange
        } else {
            return .red
        }
    }

    private func colorForMemoryUsage(_ usage: Double) -> Color {
        let upperBound: Double = min(100.0, max(90, appMonitor.memoryUsageThreshold + 10.0))

        if usage < appMonitor.memoryUsageThreshold {
            return .green
        } else if usage < upperBound {
            return .orange
        } else {
            return .red
        }
    }
    
}
