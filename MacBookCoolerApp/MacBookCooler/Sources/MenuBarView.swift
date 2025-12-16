import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingOnboarding = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Glassmorphism background
            VisualEffectBlur(material: .popover, blendingMode: .behindWindow)
            
            VStack(spacing: 0) {
                // Show onboarding or main view based on status
                if !appState.hasCompletedOnboarding || appState.homebrewStatus == .notInstalled || appState.homebrewStatus == .installed {
                    OnboardingView(showAlert: $showAlert, alertMessage: $alertMessage)
                } else {
                    MainDashboardView(showAlert: $showAlert, alertMessage: $alertMessage)
                }
            }
        }
        .frame(width: 340, height: 480)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App icon and title
            VStack(spacing: 16) {
                Image(systemName: "thermometer.sun.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("MacBook Cooler")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                
                Text("Thermal Management Suite")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status card
            VStack(spacing: 16) {
                statusCard
                
                if appState.isInstalling {
                    installingView
                } else {
                    actionButton
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Footer
            footerLinks
        }
        .padding(.vertical, 20)
    }
    
    private var statusCard: some View {
        HStack(spacing: 12) {
            statusIcon
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.system(size: 14, weight: .semibold))
                Text(statusSubtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var statusIcon: some View {
        Group {
            switch appState.homebrewStatus {
            case .checking:
                ProgressView()
                    .scaleEffect(0.8)
            case .notInstalled:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            case .installed:
                Image(systemName: "shippingbox.fill")
                    .foregroundColor(.blue)
            case .cliToolsInstalled:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .cliToolsOutdated:
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .font(.system(size: 24))
    }
    
    private var statusTitle: String {
        switch appState.homebrewStatus {
        case .checking: return "Checking..."
        case .notInstalled: return "Homebrew Required"
        case .installed: return "Ready to Install"
        case .cliToolsInstalled: return "All Set!"
        case .cliToolsOutdated: return "Update Available"
        }
    }
    
    private var statusSubtitle: String {
        switch appState.homebrewStatus {
        case .checking: return "Detecting installation status"
        case .notInstalled: return "Install Homebrew first"
        case .installed: return "CLI tools not installed"
        case .cliToolsInstalled: return "Version \(appState.cliVersion)"
        case .cliToolsOutdated: return "\(appState.cliVersion) → \(appState.latestVersion)"
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch appState.homebrewStatus {
        case .notInstalled:
            Link(destination: URL(string: "https://brew.sh")!) {
                HStack {
                    Image(systemName: "safari.fill")
                    Text("Install Homebrew")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
        case .installed:
            Button(action: installCLI) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Install CLI Tools")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
        case .cliToolsOutdated:
            Button(action: upgradeCLI) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Upgrade to \(appState.latestVersion)")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
        case .cliToolsInstalled:
            Button(action: continueToApp) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Continue")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
        default:
            EmptyView()
        }
    }
    
    private var installingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text(appState.installProgress)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(height: 60)
    }
    
    private var footerLinks: some View {
        HStack(spacing: 16) {
            Link("GitHub", destination: URL(string: "https://github.com/nelsojona/macbook-cooler")!)
            Text("•").foregroundColor(.secondary)
            Link("Documentation", destination: URL(string: "https://github.com/nelsojona/macbook-cooler#readme")!)
        }
        .font(.system(size: 11))
        .foregroundColor(.secondary)
    }
    
    private func installCLI() {
        appState.installCLITools { success, message in
            if !success {
                alertMessage = message
                showAlert = true
            }
        }
    }
    
    private func upgradeCLI() {
        appState.upgradeCLITools { success, message in
            alertMessage = message
            showAlert = true
        }
    }
    
    private func continueToApp() {
        appState.hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Main Dashboard View
struct MainDashboardView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
                .padding(.horizontal, 16)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Temperature card
                    temperatureCard
                    
                    // Stats grid
                    statsGrid
                    
                    // Power mode selector
                    powerModeSection
                    
                    // Service control
                    serviceControlSection
                    
                    // Quick actions
                    quickActionsSection
                }
                .padding(16)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Footer
            footerView
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("MacBook Cooler")
                    .font(.system(size: 15, weight: .semibold))
                Text(appState.isServiceRunning ? "Service Running" : "Service Stopped")
                    .font(.system(size: 11))
                    .foregroundColor(appState.isServiceRunning ? .green : .secondary)
            }
            
            Spacer()
            
            // Refresh button
            Button(action: { appState.checkHomebrewStatus() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Refresh status")
        }
        .padding(16)
    }
    
    private var temperatureCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CPU Temperature")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.0f", appState.currentTemperature))
                            .font(.system(size: 48, weight: .light, design: .rounded))
                        Text("°C")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                temperatureIndicator
            }
            
            // Temperature bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(temperatureGradient)
                        .frame(width: geometry.size.width * min(appState.currentTemperature / 100, 1.0))
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var temperatureIndicator: some View {
        VStack(spacing: 4) {
            Image(systemName: temperatureIcon)
                .font(.system(size: 28))
                .foregroundColor(temperatureColor)
            
            Text(appState.thermalPressure)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var temperatureIcon: String {
        if appState.currentTemperature >= 90 { return "thermometer.sun.fill" }
        if appState.currentTemperature >= 75 { return "thermometer.high" }
        if appState.currentTemperature >= 60 { return "thermometer.medium" }
        return "thermometer.low"
    }
    
    private var temperatureColor: Color {
        if appState.currentTemperature >= 90 { return .red }
        if appState.currentTemperature >= 75 { return .orange }
        if appState.currentTemperature >= 60 { return .yellow }
        return .green
    }
    
    private var temperatureGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .yellow, .orange, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "GPU", value: String(format: "%.0f°C", appState.gpuTemperature), icon: "gpu")
            StatCard(title: "CPU Usage", value: String(format: "%.0f%%", appState.cpuUsage), icon: "cpu")
            StatCard(title: "Fan Speed", value: "\(appState.fanSpeed) RPM", icon: "fan.fill")
            StatCard(title: "Power Mode", value: appState.powerMode.rawValue, icon: "bolt.fill")
        }
    }
    
    private var powerModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Power Mode")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            
            Picker("", selection: $appState.powerMode) {
                ForEach(PowerMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appState.powerMode) { newValue in
                appState.setPowerMode(newValue)
            }
        }
    }
    
    private var serviceControlSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Background Service")
                    .font(.system(size: 13, weight: .medium))
                Text(appState.isServiceRunning ? "Running" : "Stopped")
                    .font(.system(size: 11))
                    .foregroundColor(appState.isServiceRunning ? .green : .secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { appState.isServiceRunning },
                set: { _ in
                    appState.toggleService { success in
                        if !success {
                            alertMessage = "Failed to toggle service"
                            showAlert = true
                        }
                    }
                }
            ))
            .toggleStyle(.switch)
            .scaleEffect(0.8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Actions")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                QuickActionButton(title: "Throttle", icon: "gauge.with.dots.needle.33percent", action: {})
                QuickActionButton(title: "Optimize", icon: "wand.and.stars", action: {})
                QuickActionButton(title: "Schedule", icon: "calendar.badge.clock", action: {})
            }
        }
    }
    
    private var footerView: some View {
        HStack {
            if appState.homebrewStatus == .cliToolsOutdated {
                Button(action: {
                    appState.upgradeCLITools { success, message in
                        alertMessage = message
                        showAlert = true
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Update Available")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            } else {
                Text("v\(appState.cliVersion)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { NSApp.terminate(nil) }) {
                Text("Quit")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Visual Effect Blur
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ThresholdsSettingsView()
                .tabItem {
                    Label("Thresholds", systemImage: "thermometer")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showTemperatureInMenuBar") private var showTemperatureInMenuBar = true
    
    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
            Toggle("Show temperature in menu bar", isOn: $showTemperatureInMenuBar)
        }
        .padding()
    }
}

struct ThresholdsSettingsView: View {
    @AppStorage("highThreshold") private var highThreshold = 80.0
    @AppStorage("lowThreshold") private var lowThreshold = 65.0
    @AppStorage("criticalThreshold") private var criticalThreshold = 95.0
    
    var body: some View {
        Form {
            Section("Temperature Thresholds (°C)") {
                HStack {
                    Text("Low Power Mode Trigger")
                    Spacer()
                    TextField("", value: $highThreshold, format: .number)
                        .frame(width: 60)
                }
                
                HStack {
                    Text("Normal Mode Return")
                    Spacer()
                    TextField("", value: $lowThreshold, format: .number)
                        .frame(width: 60)
                }
                
                HStack {
                    Text("Critical Alert")
                    Spacer()
                    TextField("", value: $criticalThreshold, format: .number)
                        .frame(width: 60)
                }
            }
        }
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "thermometer.sun.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            Text("MacBook Cooler")
                .font(.title2.bold())
            
            Text("Thermal Management Suite")
                .foregroundColor(.secondary)
            
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Link("View on GitHub", destination: URL(string: "https://github.com/nelsojona/macbook-cooler")!)
        }
        .padding()
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AppState.shared)
        .frame(width: 340, height: 480)
}
