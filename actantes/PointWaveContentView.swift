//
//  ContentView.swift
//  pointsquares
//
//  Created by Gabriele Fiore on 18/11/24.
//
import SwiftUI

struct PointWaveContentView: View {
    @State private var permissionGranted = false
    @StateObject private var audioProcessor = AudioProcessor()
    @State private var audioEngineError: Error?

    var body: some View {
        if permissionGranted {
            PointWaveEffectView(audioProcessor: audioProcessor)
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
                .onChange(of: permissionGranted) { _, newValue in
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

#Preview {
    PointWaveContentView()
}
