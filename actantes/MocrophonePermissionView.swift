import SwiftUI
import AVFAudio

struct MocrophonePermissionView: View {
    @State private var permissionGranted = false
    
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
            
            if permissionGranted {
                Text("Microphone access granted!")
                    .foregroundColor(.green)
                    .padding()
            }
        }
    }
    
    func requestMicrophonePermission() {
        // Check current permission status
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            // Request permission
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                }
            }
        case .denied:
            // Permission previously denied, user needs to enable it in Settings
            print("Microphone access denied. Please enable it in Settings.")
        case .granted:
            // Permission already granted
            self.permissionGranted = true
        @unknown default:
            print("Unknown permission status")
        }
    }
}

