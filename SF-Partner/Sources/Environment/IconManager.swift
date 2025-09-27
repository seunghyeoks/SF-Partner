import Foundation
import Observation

@Observable
class IconManager {
    var currentIcon: String = "cellularbars" 
    var iconVariableValue: Double = 0.0
    private let userDefaults = UserDefaults.standard
    private let iconKey = "SF-Partner-CurrentMenuBarIcon"

    init() {
        if let savedIcon = userDefaults.string(forKey: iconKey), !savedIcon.isEmpty {
            currentIcon = savedIcon
        }
    }
    
    func updateIcon(to newIcon: String) {
        userDefaults.set(currentIcon, forKey: iconKey)
        currentIcon = newIcon 
    }
    
    func updateIconVariableValue(basedOn usage: Double) {
        iconVariableValue = usage / 100.0   // 0.0 ~ 1.0 
    }
}