import SwiftUI

struct ContentView: View {
    @State private var showWebView = true
    @State private var sketchName = "index" // Name of the HTML file to load
    @State private var isDarkMode = false

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
                
                // Display WebView
                if showWebView {
                    WebView(htmlFile: sketchName)
                        .frame(height: 400)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                } else {
                    Text("WebView is Hidden")
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
            }
            .padding()
            .navigationBarHidden(true)
            .background(isDarkMode ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all))
        }
    }
    
    // Placeholder reload functionality
    func reloadSketch() {
        // Future enhancement: dynamically reload HTML file or apply live changes
        print("Reload sketch requested.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

