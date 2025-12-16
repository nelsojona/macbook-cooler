import SwiftUI
import AppKit

@main
struct MacBookCoolerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var eventMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Check Homebrew installation status
        AppState.shared.checkHomebrewStatus()
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateStatusBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover with glassmorphism view
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 340, height: 480)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(AppState.shared)
        )
        
        // Start monitoring
        AppState.shared.startMonitoring { [weak self] in
            DispatchQueue.main.async {
                self?.updateStatusBarIcon()
            }
        }
        
        // Monitor for clicks outside popover
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover?.isShown == true {
                self?.popover?.performClose(nil)
            }
        }
        
        // Show onboarding if needed
        if !AppState.shared.hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.togglePopover()
            }
        }
    }
    
    func updateStatusBarIcon() {
        guard let button = statusItem?.button else { return }
        let temp = AppState.shared.currentTemperature
        
        let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        
        if temp >= 90 {
            button.image = NSImage(systemSymbolName: "thermometer.sun.fill", accessibilityDescription: "Critical")?
                .withSymbolConfiguration(config)
            button.contentTintColor = .systemRed
        } else if temp >= 75 {
            button.image = NSImage(systemSymbolName: "thermometer.high", accessibilityDescription: "High")?
                .withSymbolConfiguration(config)
            button.contentTintColor = .systemOrange
        } else if temp >= 60 {
            button.image = NSImage(systemSymbolName: "thermometer.medium", accessibilityDescription: "Normal")?
                .withSymbolConfiguration(config)
            button.contentTintColor = .labelColor
        } else {
            button.image = NSImage(systemSymbolName: "thermometer.low", accessibilityDescription: "Cool")?
                .withSymbolConfiguration(config)
            button.contentTintColor = .systemGreen
        }
        
        button.title = String(format: " %.0f°", temp)
        button.imagePosition = .imageLeading
    }
    
    @objc func togglePopover() {
        if let popover = popover, let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        AppState.shared.stopMonitoring()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
