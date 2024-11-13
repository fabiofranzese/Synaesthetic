//import SwiftUI
//import AVFAudio
//
//struct GMicrophonePermissionView: View {
//    @Binding var permissionGranted: Bool // To communicate microphone state with ContentView
//    @State private var showSettingsAlert = false // Alert for denied permissions
//
//    var body: some View {
//        VStack {
//            Button(action: {
//                requestMicrophonePermission()
//            }) {
//                Text(permissionGranted ? "Microphone Access Granted" : "Request Microphone Access")
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(permissionGranted ? Color.green : Color.blue)
//                    .cornerRadius(10)
//            }
//            .accessibilityLabel(permissionGranted ? "Microphone Access Granted" : "Request Microphone Access")
//        }
//        .alert(isPresented: $showSettingsAlert) {
//            Alert(
//                title: Text("Microphone Access Denied"),
//                message: Text("Please enable microphone access in Settings to use this feature."),
//                primaryButton: .default(Text("Go to Settings")) {
//                    openSettings()
//                },
//                secondaryButton: .cancel()
//            )
//        }
//    }
//
//    func requestMicrophonePermission() {
//        if #available(iOS 17.0, *) {
//            // Use AVAudioApplication for iOS 17+
//            let permissionStatus = AVAudioApplication.shared.recordPermission // Correct access
//            switch permissionStatus {
//            case .undetermined:
//                print("Microphone permission status: Undetermined. Requesting access...")
//                AVAudioApplication.requestRecordPermission { granted in
//                    DispatchQueue.main.async {
//                        self.permissionGranted = granted
//                        if granted {
//                            print("Microphone access granted.")
//                        } else {
//                            print("Microphone access denied.")
//                            self.showSettingsAlert = true
//                        }
//                    }
//                }
//            case .denied:
//                print("Microphone permission status: Denied.")
//                self.permissionGranted = false
//                self.showSettingsAlert = true
//            case .granted:
//                print("Microphone permission status: Granted.")
//                self.permissionGranted = true
//            @unknown default:
//                print("Unknown microphone permission status.")
//                self.permissionGranted = false
//            }
//        } else {
//            // Use AVAudioSession for earlier iOS versions
//            let audioSession = AVAudioSession.sharedInstance()
//            switch audioSession.recordPermission {
//            case .undetermined:
//                print("Microphone permission status: Undetermined. Requesting access...")
//                audioSession.requestRecordPermission { granted in
//                    DispatchQueue.main.async {
//                        self.permissionGranted = granted
//                        if granted {
//                            print("Microphone access granted.")
//                        } else {
//                            print("Microphone access denied.")
//                            self.showSettingsAlert = true
//                        }
//                    }
//                }
//            case .denied:
//                print("Microphone permission status: Denied.")
//                self.permissionGranted = false
//                self.showSettingsAlert = true
//            case .granted:
//                print("Microphone permission status: Granted.")
//                self.permissionGranted = true
//            @unknown default:
//                print("Unknown microphone permission status.")
//                self.permissionGranted = false
//            }
//        }
//    }
//
//    func openSettings() {
//        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
//        if UIApplication.shared.canOpenURL(settingsURL) {
//            UIApplication.shared.open(settingsURL)
//        }
//    }
//}
