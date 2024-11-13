import SwiftUI
import WebKit


struct P5HTMLTemplate {
    static func generate(scripts: [String]) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <title>P5 Visualization</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    position: fixed;
                    background: transparent;
                }
                
                canvas {
                    display: block;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100% !important;
                    height: 100% !important;
                }
                
                main {
                    width: 100%;
                    height: 100%;
                    position: fixed;
                    top: 0;
                    left: 0;
                }
            </style>
            <script src="https://cdn.jsdelivr.net/npm/p5@1.11.1/lib/p5.min.js"></script>
            <script>
                // Global variables needed by the scripts
                let w, h;
                let spectrum = [];
                let sub_freq = 0, low_freq = 0, mid_freq = 0, hi_freq = 0, treble_freq = 0;
                let amp_raw = 0, amp_smooth = 0;
                
                function setup() {
                    // Use windowWidth and windowHeight for full screen
                    w = windowWidth;
                    h = windowHeight;
                    createCanvas(w, h);
                    pixelDensity(1); // Ensure consistent rendering across devices
                    background(30);
                    initParticles();
                }
                
                function windowResized() {
                    // Handle window resizing
                    w = windowWidth;
                    h = windowHeight;
                    resizeCanvas(w, h);
                }
                
                function draw() {
                    background(30, 20);
                    updateParticles();
                }
            </script>
            \(scripts.joined(separator: "\n"))
        </head>
        <body>
        </body>
        </html>
        """
    }
}


// Updated P5View.swift
@Observable
class P5ViewModel {
    let scripts: [String]
    
    init(scripts: [String]) {
        self.scripts = scripts
    }
}


struct P5View: View {
    let viewModel: P5ViewModel
    @ObservedObject var audioProcessor: AudioProcessor
    
    var body: some View {
        TimelineView(.animation) { _ in
            P5WebViewContainer(scripts: viewModel.scripts, audioProcessor: audioProcessor)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct P5WebViewContainer: UIViewRepresentable {
    let scripts: [String]
    let audioProcessor: AudioProcessor
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: P5WebViewContainer
        var webView: WKWebView?
        
        init(_ parent: P5WebViewContainer) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // Handle any messages from JavaScript if needed
        }
        
        func updateAudioValues() {
            let bands = parent.audioProcessor.frequencyBands
            let js = """
                sub_freq = \(bands["sub"] ?? 0);
                low_freq = \(bands["low"] ?? 0);
                mid_freq = \(bands["mid"] ?? 0);
                hi_freq = \(bands["hi"] ?? 0);
                treble_freq = \(bands["treble"] ?? 0);
            """
            print("Updating JS with values: \(bands)")
            webView?.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("Error updating JS values: \(error)")
                }
            }
        }
    }
    
    // Moved outside of Coordinator
    func makeUIView(context: Context) -> WKWebView {
            let configuration = WKWebViewConfiguration()
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = preferences
            
            // Set the content mode to scale to fill
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.isScrollEnabled = false
            webView.scrollView.bounces = false
            
            // Disable viewport scaling
            webView.scrollView.contentInsetAdjustmentBehavior = .never
            webView.scrollView.zoomScale = 1.0
            webView.scrollView.minimumZoomScale = 1.0
            webView.scrollView.maximumZoomScale = 1.0
            
            let html = P5HTMLTemplate.generate(scripts: scripts)
            webView.loadHTMLString(html, baseURL: nil)
            
            context.coordinator.webView = webView
            
            Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
                context.coordinator.updateAudioValues()
            }
            
            return webView
        }
    
    // Moved outside of Coordinator
    func updateUIView(_ webView: WKWebView, context: Context) {
        }
}


// ContentView.swift
struct ContentView: View {
    @State private var permissionGranted = false
    @StateObject private var audioProcessor = AudioProcessor()
    @State private var audioEngineError: Error?
    
    var body: some View {
        if permissionGranted {
            visualizationView
                .onAppear {
                    startAudioEngine()
                }
                .alert("Audio Engine Error",
                       isPresented: .constant(audioEngineError != nil)) {
                    Button("OK") {
                        audioEngineError = nil
                    }
                } message: {
                    if let error = audioEngineError {
                        Text(error.localizedDescription)
                    }
                }
        } else {
            MicrophonePermissionView(permissionGranted: $permissionGranted)
                .onChange(of: permissionGranted) { oldValue, newValue in
                    if newValue {
                        startAudioEngine()
                    }
                }
        }
    }
    
    private func startAudioEngine() {
        print("Attempting to start audio engine...")
        do {
            try audioProcessor.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error)")
            audioEngineError = error
        }
    }
    
    private var visualizationView: some View {
            let scriptFiles = ["aP", "psystem", "sketch"]
            let loadedScripts = scriptFiles.compactMap { filename in
                print("Loading script: \(filename)")
                let script = FileManager.loadFile(named: filename)
                print("Script \(filename) loaded: \(script != nil)")
                return script
            }.map { "<script>\($0)</script>" }
            
            return P5View(
                viewModel: P5ViewModel(scripts: loadedScripts),
                audioProcessor: audioProcessor
            )
            .edgesIgnoringSafeArea(.all)  // Ignore safe area
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill entire space
            .background(Color.black) // Optional: ensure black background
        }
}

