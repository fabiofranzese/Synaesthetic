// P5HTMLTemplate.swift
struct P5HTMLTemplate {
    static func generate(sketch: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>P5 Sketch</title>
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
                \(sketch)
                
                // Override the default canvas creation to make it responsive
                let originalCreateCanvas = window.createCanvas;
                window.createCanvas = function() {
                    let canvas = originalCreateCanvas(window.innerWidth, window.innerHeight);
                    return canvas;
                }
                
                // Handle resize events
                window.addEventListener('resize', function() {
                    resizeCanvas(window.innerWidth, window.innerHeight);
                });
            </script>
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
    let sketch: String
    
    init(sketch: String) {
        self.sketch = sketch
    }
}

struct P5View: View {
    let viewModel: P5ViewModel
    
    var body: some View {
        TimelineView(.animation) { _ in
            P5WebViewContainer(sketch: viewModel.sketch)
        }
    }
}

struct P5WebViewContainer: UIViewRepresentable {
    let sketch: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()
        
        configuration.userContentController = controller
        
        // Set up webpage preferences correctly for iOS 14.0+
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true  // Enable JavaScript execution
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Load the HTML content
        let html = P5HTMLTemplate.generate(sketch: sketch)
        webView.loadHTMLString(html, baseURL: nil)
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Updates handled by TimelineView
    }
}

// Test View
struct SampleWebView: View {
    let viewModel = P5ViewModel(sketch: """
        let ball = {
            x: 100,
            y: 100,
            speedX: 6,
            speedY: 4,
            size: 40
        };
        
        function setup() {
            createCanvas(windowWidth, windowHeight);
            background(30);
        }
        
        function draw() {
            // Create fade effect
            background(30, 20);
            
            // Update ball position
            ball.x += ball.speedX;
            ball.y += ball.speedY;
            
            // Bounce off edges
            if (ball.x < 0 || ball.x > width) ball.speedX *= -1;
            if (ball.y < 0 || ball.y > height) ball.speedY *= -1;
            
            // Draw the ball
            fill(255, 100, 100);
            noStroke();
            circle(ball.x, ball.y, ball.size);
            
            // Add glow effect
            drawingContext.shadowBlur = 20;
            drawingContext.shadowColor = 'rgba(255, 100, 100, 0.5)';
        }
    """)
    
    var body: some View {
        P5View(viewModel: viewModel)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
