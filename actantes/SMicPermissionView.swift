import SwiftUI
import AVFAudio
import AVFoundation

struct MicrophonePermissionView: View {
    @Binding var permissionGranted: Bool
    @State private var showSettingsAlert = false
    
    var body: some View {
        VStack {
            Button(action: {
                requestMicrophonePermission()
            }) {
                Text("Request Microphone Access")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            checkInitialPermissionStatus()
        }
        .alert("Microphone Access Required",
               isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in Settings to use this feature.")
        }
    }
    
    private func checkInitialPermissionStatus() {
        print("Checking initial permission status...")
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        print("Current permission status: \(status)")
        
        switch status {
        case .authorized:
            print("Permission already granted")
            DispatchQueue.main.async {
                self.permissionGranted = true
            }
        case .denied:
            print("Permission previously denied")
            showSettingsAlert = true
        default:
            break
        }
    }
    
    private func requestMicrophonePermission() {
        print("Requesting microphone permission...")
        
        // First, configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        // Then, request permission
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            print("Permission request completed. Granted: \(granted)")
            DispatchQueue.main.async {
                self.permissionGranted = granted
                if granted {
                    print("Microphone access granted!")
                } else {
                    print("Microphone access denied.")
                    self.showSettingsAlert = true
                }
            }
        }
    }
}

