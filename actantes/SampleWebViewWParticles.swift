//// FileManager+Bundle.swift
//import Foundation
//
//extension FileManager {
//    // Function to load a file's content from the app bundle
//    static func loadFile(named filename: String, withExtension ext: String = "js") -> String? {
//        // Get the file path for the resource in the bundle
//        guard let path = Bundle.main.path(forResource: filename, ofType: ext) else {
//            print("Failed to find \(filename).\(ext)") // Log if the file is not found
//            return nil
//        }
//        
//        do {
//            // Try reading the file's content as a string
//            return try String(contentsOfFile: path, encoding: .utf8)
//        } catch {
//            // Log and return nil if reading fails
//            print("Failed to load \(filename).\(ext): \(error)")
//            return nil
//        }
//    }
//}
//
//// P5HTMLTemplate.swift
//struct P5HTMLTemplate {
//    // Function to generate an HTML string with provided scripts
//    static func generate(scripts: [String]) -> String {
//        """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="utf-8"> <!-- Set character encoding -->
//            <meta name="viewport" content="width=device-width, initial-scale=1.0"> <!-- Make the page responsive -->
//            <title>P5 Visualization</title> <!-- Page title -->
//            <style>
//                html, body {
//                    margin: 0; /* Remove default margins */
//                    padding: 0; /* Remove default padding */
//                    overflow: hidden; /* Prevent scrollbars */
//                    background: transparent; /* Transparent background */
//                }
//                canvas {
//                    display: block; /* Make the canvas fill the parent */
//                }
//            </style>
//            <!-- Include the p5.js library -->
//            <script src="https://cdn.jsdelivr.net/npm/p5@1.11.1/lib/p5.min.js"></script>
//            <script>
//                // Declare global variables for use in sketches
//                let w, h;
//                let spectrum = [];
//                let sub_freq = 0, low_freq = 0, mid_freq = 0, hi_freq = 0, treble_freq = 0;
//                let amp_raw = 0, amp_smooth = 0;
//                
//                function setup() {
//                    // Initialize canvas size and background
//                    w = windowWidth;
//                    h = windowHeight;
//                    createCanvas(w, h);
//                    background(30);
//                    initParticles(); // Initialize particles (defined elsewhere)
//                }
//                
//                function draw() {
//                    // Update background and particles
//                    background(30, 20); // Transparent black background
//                    updateParticles(); // Update particle positions
//                }
//                
//                // Mock function to generate audio values for testing
//                function updateAudioValues() {
//                    // Generate fake audio values as sine waves
//                    sub_freq = 128 + 127 * sin(millis() * 0.001);
//                    low_freq = 128 + 127 * sin(millis() * 0.002);
//                    mid_freq = 128 + 127 * sin(millis() * 0.003);
//                    hi_freq = 128 + 127 * sin(millis() * 0.004);
//                    treble_freq = 128 + 127 * sin(millis() * 0.005);
//                }
//                
//                // Extend the draw loop to include audio updates
//                let originalDraw = draw;
//                draw = function() {
//                    updateAudioValues(); // Update mock audio values
//                    originalDraw(); // Call the original draw function
//                }
//            </script>
//            \(scripts.joined(separator: "\n")) <!-- Include additional scripts dynamically -->
//        </head>
//        <body>
//        </body>
//        </html>
//        """
//    }
//}
//
//// P5View.swift
//import SwiftUI
//import WebKit
//
//@Observable
//class P5ViewModel {
//    let scripts: [String] // Array of JavaScript scripts to include
//    
//    init(scripts: [String]) {
//        self.scripts = scripts // Initialize the view model with scripts
//    }
//}
//
//struct P5View: View {
//    let viewModel: P5ViewModel // ViewModel to hold scripts
//    
//    var body: some View {
//        // TimelineView for animation-driven updates
//        TimelineView(.animation) { _ in
//            P5WebViewContainer(scripts: viewModel.scripts) // Pass scripts to WebView container
//        }
//    }
//}
//
//struct P5WebViewContainer: UIViewRepresentable {
//    let scripts: [String] // JavaScript files to include
//    
//    func makeUIView(context: Context) -> WKWebView {
//        // Configure WebView to allow JavaScript
//        let configuration = WKWebViewConfiguration()
//        let preferences = WKWebpagePreferences()
//        preferences.allowsContentJavaScript = true // Enable JavaScript
//        configuration.defaultWebpagePreferences = preferences
//        
//        let webView = WKWebView(frame: .zero, configuration: configuration) // Initialize WebView
//        webView.isOpaque = false // Make the WebView background transparent
//        webView.backgroundColor = .clear
//        webView.scrollView.isScrollEnabled = false // Disable scrolling
//        
//        // Generate HTML and load it into the WebView
//        let html = P5HTMLTemplate.generate(scripts: scripts)
//        webView.loadHTMLString(html, baseURL: nil)
//        
//        return webView
//    }
//    
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        // No updates required for now
//    }
//}
//
////USE THIS VIEW TO BUILD
//struct SampleWebViewWParticles: View {
//    let viewModel: P5ViewModel
//    
//    init() {
//        // Load all required JavaScript files
//        let scriptFiles = ["aP", "psystem"]
//        let loadedScripts = scriptFiles.compactMap { filename in
//            FileManager.loadFile(named: filename)
//        }.map { "<script>\($0)</script>" }
//        
//        viewModel = P5ViewModel(scripts: loadedScripts)
//    }
//    
//    var body: some View {
//        P5View(viewModel: viewModel)
//            .ignoresSafeArea()
//    }
//}; #Preview { SampleWebViewWParticles()
//}
