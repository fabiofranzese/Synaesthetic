import SwiftUI

struct FluidEffectView: View {
    @State private var start = Date.now
    @ObservedObject var audioProcessor: AudioProcessor


    var body: some View {
        TimelineView(.animation) { timeline in
            let time = start.distance(to: timeline.date)
            
            let sub = Float(audioProcessor.frequencyBands["sub"] ?? 0) / 255.0
            let low = Float(audioProcessor.frequencyBands["low"] ?? 0) / 255.0
            let mid = Float(audioProcessor.frequencyBands["mid"] ?? 0) / 255.0
            let hi = Float(audioProcessor.frequencyBands["hi"] ?? 0) / 255.0
            let treble = Float(audioProcessor.frequencyBands["treble"] ?? 0) / 255.0
            
            Rectangle()
                .visualEffect { content, proxy in
                    content.colorEffect(
                        ShaderLibrary.fluidTexture(
                            .float2(proxy.size),
                            .float(time),
                            .float(sub),
                            .float(low),
                            .float(mid),
                            .float(hi),
                            .float(treble)
                        )
                    )
                }
                .ignoresSafeArea()
        }
    }
}



// Simplified ContentView
struct LiquidView: View {
    @State private var permissionGranted = false
    @StateObject private var audioProcessor = AudioProcessor()
    @State private var audioEngineError: Error?
    
    var body: some View {
        if permissionGranted {
            FluidEffectView(audioProcessor: audioProcessor)
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
        do {
            try audioProcessor.start()
        } catch {
            audioEngineError = error
        }
    }
}


