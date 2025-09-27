import SwiftUI

@main
struct MainApp: App {
    @State private var iconManager: IconManager
    @State private var appMonitor: AppMonitor
    
    init() {
        let iconManager = IconManager()
        _iconManager = State(initialValue: iconManager)
        _appMonitor = State(initialValue: AppMonitor(iconManager))
    }
    
    var body: some Scene {
        MenuBarExtra() {
            DashBoardView()
                .environment(appMonitor)
                .environment(iconManager)
        } label: {
            Image(systemName: iconManager.currentIcon, variableValue: iconManager.iconVariableValue)
        }
        .menuBarExtraStyle(.window)
    }
}
