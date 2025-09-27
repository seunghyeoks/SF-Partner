import Foundation
import Darwin

actor SystemObserver {
    private var previousCPULoadInfo: host_cpu_load_info_data_t?

    func getCPUName() -> String {
        var brandLen: size_t = 0
        if sysctlbyname("machdep.cpu.brand_string", nil, &brandLen, nil, 0) == 0, brandLen > 0 {
            var brand = [CChar](repeating: 0, count: Int(brandLen))
            if sysctlbyname("machdep.cpu.brand_string", &brand, &brandLen, nil, 0) == 0 {
                let name = String(cString: brand).trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty { return name }
            }
        }
        // Fallback: Hardware model name
        var modelLen: size_t = 0
        if sysctlbyname("hw.model", nil, &modelLen, nil, 0) == 0, modelLen > 0 {
            var model = [CChar](repeating: 0, count: Int(modelLen))
            if sysctlbyname("hw.model", &model, &modelLen, nil, 0) == 0 {
                let fallback = String(cString: model).trimmingCharacters(in: .whitespacesAndNewlines)
                if !fallback.isEmpty { return fallback }
            }
        }
        return "Unknown CPU"
    }

    func getCPUUsage() -> Double {
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        var cpuInfo = host_cpu_load_info()
        let kr: kern_return_t = withUnsafeMutablePointer(to: &cpuInfo) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return 0.0 }

        let user = Double(cpuInfo.cpu_ticks.0)
        let system = Double(cpuInfo.cpu_ticks.1)
        let idle = Double(cpuInfo.cpu_ticks.2)
        let nice = Double(cpuInfo.cpu_ticks.3)

        if let prev = previousCPULoadInfo {
            let deltaUser = max(0.0, user - Double(prev.cpu_ticks.0))
            let deltaSystem = max(0.0, system - Double(prev.cpu_ticks.1))
            let deltaIdle = max(0.0, idle - Double(prev.cpu_ticks.2))
            let deltaNice = max(0.0, nice - Double(prev.cpu_ticks.3))
            let total = deltaUser + deltaSystem + deltaIdle + deltaNice
            if total > 0 {
                let busy = deltaUser + deltaSystem + deltaNice
                let usage = (busy / total) * 100.0
                previousCPULoadInfo = cpuInfo
                return min(max(usage, 0.0), 100.0)
            }
        }
        previousCPULoadInfo = cpuInfo
        return 0.0
    }

    func getTotalMemoryGB() -> Int {
        var memSize: UInt64 = 0
        var len = MemoryLayout<UInt64>.size
        if sysctlbyname("hw.memsize", &memSize, &len, nil, 0) == 0, memSize > 0 {
            let gb = Int((Double(memSize) / 1024.0 / 1024.0 / 1024.0).rounded())
            return max(gb, 1)
        }
        return 0
    }
    
    func getMemoryPressure() -> Double {
        let hostPort = mach_host_self()
        var pageSize: vm_size_t = 0
        guard host_page_size(hostPort, &pageSize) == KERN_SUCCESS else { return 0.0 }

        // Try 64-bit VM statistics first
        var count64 = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        var vmStat64 = vm_statistics64()
        let kr64: kern_return_t = withUnsafeMutablePointer(to: &vmStat64) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count64)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count64)
            }
        }
        if kr64 == KERN_SUCCESS {
            let active = Double(vmStat64.active_count)
            let inactive = Double(vmStat64.inactive_count)
            let wired = Double(vmStat64.wire_count)
            let free = Double(vmStat64.free_count)
            let speculative = Double(vmStat64.speculative_count)
            let totalPages = active + inactive + wired + free + speculative
            guard totalPages > 0 else { return 0.0 }
            let usedPages = active + wired
            let pressure = (usedPages / totalPages) * 100.0
            return min(max(pressure, 0.0), 100.0)
        }

        // Fall back, try 32-bit statistics
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
        var vmStat = vm_statistics_data_t()
        let kr: kern_return_t = withUnsafeMutablePointer(to: &vmStat) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(hostPort, HOST_VM_INFO, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return 0.0 }
        let active = Double(vmStat.active_count)
        let inactive = Double(vmStat.inactive_count)
        let wired = Double(vmStat.wire_count)
        let free = Double(vmStat.free_count)
        let totalPages = active + inactive + wired + free
        guard totalPages > 0 else { return 0.0 }
        let usedPages = active + wired
        let pressure = (usedPages / totalPages) * 100.0
        return min(max(pressure, 0.0), 100.0)
    }
}
