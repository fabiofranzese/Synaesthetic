import SwiftUI

struct GContentView: View {
    @State private var showWebView = true
    @State private var isDarkMode = false
    @State private var reloadTrigger = UUID() // Unique ID to force reload
    @State private var permissionGranted = false // Track microphone access

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Live p5.js Viewer")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()

                    Spacer()

                    Toggle(isOn: $isDarkMode) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }

                Divider()

                // Display SampleWebViewWParticles
                if permissionGranted {
                    if showWebView {
                        SampleWebViewWParticles()
                            .id(reloadTrigger) // Force recreate view on reload
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    } else {
                        Text("WebView is Hidden")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                } else {
                    Text("Microphone access is required to visualize the particles.")
                        .foregroundColor(.secondary)
                        .padding()
                }

                // Control Panel
                HStack {
                    Button(action: {
                        showWebView.toggle()
                    }) {
                        Label(showWebView ? "Hide Sketch" : "Show Sketch", systemImage: showWebView ? "eye.slash" : "eye")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Spacer()

                    Button(action: {
                        reloadSketch()
                    }) {
                        Label("Reload Sketch", systemImage: "arrow.clockwise")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                Spacer()

                // Microphone Access Section
                GMicrophonePermissionView(permissionGranted: $permissionGranted)
                    .padding()
            }
            .padding()
            .navigationBarHidden(true)
            .background(isDarkMode ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        }
    }

    // Reload functionality
    func reloadSketch() {
        // Change the reloadTrigger ID to force the view to reload
        reloadTrigger = UUID()
        print("Reloading sketch...")
    }
}; #Preview {GContentView()}
