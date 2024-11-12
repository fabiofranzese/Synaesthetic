// FileManager+Bundle.swift
import Foundation

extension FileManager {
    static func loadFile(named filename: String, withExtension ext: String = "js") -> String? {
        guard let path = Bundle.main.path(forResource: filename, ofType: ext) else {
            print("Failed to find \(filename).\(ext)")
            return nil
        }
        
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            print("Failed to load \(filename).\(ext): \(error)")
            return nil
        }
    }
}

// P5HTMLTemplate.swift
struct P5HTMLTemplate {
    static func generate(scripts: [String]) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>P5 Visualization</title>
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    overflow: hidden;
                    background: transparent;
                }
                canvas {
                    display: block;
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
                    w = windowWidth;
                    h = windowHeight;
                    createCanvas(w, h);
                    background(30);
                    initParticles();
                }
                
                function draw() {
                    background(30, 20);
                    updateParticles();
                }
                
                // Mock audio values for visualization
                function updateAudioValues() {
                    sub_freq = 128 + 127 * sin(millis() * 0.001);
                    low_freq = 128 + 127 * sin(millis() * 0.002);
                    mid_freq = 128 + 127 * sin(millis() * 0.003);
                    hi_freq = 128 + 127 * sin(millis() * 0.004);
                    treble_freq = 128 + 127 * sin(millis() * 0.005);
                }
                
                // Add this to the draw loop
                let originalDraw = draw;
                draw = function() {
                    updateAudioValues();
                    originalDraw();
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

// P5View.swift
import SwiftUI
import WebKit

@Observable
class P5ViewModel {
    let scripts: [String]
    
    init(scripts: [String]) {
        self.scripts = scripts
    }
}

struct P5View: View {
    let viewModel: P5ViewModel
    
    var body: some View {
        TimelineView(.animation) { _ in
            P5WebViewContainer(scripts: viewModel.scripts)
        }
    }
}

struct P5WebViewContainer: UIViewRepresentable {
    let scripts: [String]
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        
        let html = P5HTMLTemplate.generate(scripts: scripts)
        webView.loadHTMLString(html, baseURL: nil)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}

//USE THIS VIEW TO BUILD
struct SampleWebViewWParticles: View {
    let viewModel: P5ViewModel
    
    init() {
        // Load all required JavaScript files
        let scriptFiles = ["aP", "psystem"]
        let loadedScripts = scriptFiles.compactMap { filename in
            FileManager.loadFile(named: filename)
        }.map { "<script>\($0)</script>" }
        
        viewModel = P5ViewModel(scripts: loadedScripts)
    }
    
    var body: some View {
        P5View(viewModel: viewModel)
            .ignoresSafeArea()
    }
}
