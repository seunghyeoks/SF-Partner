import SwiftUI
import Foundation
import Observation

@Observable
class AppMonitor {
    var cpuName: String = "Unknown"
    var cpuUsage: Double = 0.0
    var cpuUsageThreshold: Double = 50.0

    var memorySize: Int = 0
    var memoryPressure: Double = 0.0
    var memoryUsageThreshold: Double = 80.0
    
    private let iconManager: IconManager
    private let systemObserver = SystemObserver()
    private let userDefaults = UserDefaults.standard
    private let cpuThKey = "SF-Partner-CpuUsageThreshold"
    private let memoryThKey = "SF-Partner-MemoryUsageThreshold"
    private var timer: Timer?
    
    init(_ iconManager: IconManager) {
        self.iconManager = iconManager
        Task {
            let cpuName = await systemObserver.getCPUName()
            let memorySize = await systemObserver.getTotalMemoryGB()
            self.cpuName = cpuName
            self.memorySize = memorySize
        }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await self.updateSystemStats()
                await self.updateIconBasedOnUsage()
            }
        }
        if userDefaults.object(forKey: cpuThKey) != nil {
            cpuUsageThreshold = userDefaults.double(forKey: cpuThKey)
        }
        if userDefaults.object(forKey: memoryThKey) != nil {
            memoryUsageThreshold = userDefaults.double(forKey: memoryThKey)
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func updateCpuThresholds(newThreshold: Double) {
        userDefaults.set(newThreshold, forKey: cpuThKey)
        cpuUsageThreshold = newThreshold
    }
    
    func updateMemoryThresholds(newThreshold: Double) {
        userDefaults.set(newThreshold, forKey: memoryThKey)
        memoryUsageThreshold = newThreshold
    }
    
    private func updateSystemStats() async {
        cpuUsage = await systemObserver.getCPUUsage()
        memoryPressure = await systemObserver.getMemoryPressure()
    }
    
    private func updateIconBasedOnUsage() {
        var decrements = 0
        if cpuUsage > cpuUsageThreshold { decrements += 1 }
        if memoryPressure > memoryUsageThreshold { decrements += 1 }

        if decrements == 0 {
            iconManager.updateIconVariableValue(basedOn: 100.0)
        } else if decrements > 0 {
            iconManager.updateIconVariableValue(basedOn: max(0.0, 100 - 25 * Double(decrements)))
        }
    }
}
