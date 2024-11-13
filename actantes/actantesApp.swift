

//import SwiftUI
//
//@main
//struct actantesApp: App {
//    var body: some Scene {
//        WindowGroup {
//            //Replace with corresponding view
//            GContentView()
//        }
//    }
//}


import SwiftUI
import AVFAudio

@main
struct YourApp: App {
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                          mode: .default,
                                                          options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured in app initialization")
        } catch {
            print("Failed to configure audio session in app initialization: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
