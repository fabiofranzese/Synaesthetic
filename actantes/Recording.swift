//
//  Recording.swift
//  actantes
//
//  Created by Fabio on 12/11/24.
//
import UIKit
import AVFoundation
import MobileCoreServices
import Photos
import SwiftUI
import ReplayKit
import Photos

// Screen recorder class to handle recording logic
class ScreenRecorder: ObservableObject {
    
    private let recorder = RPScreenRecorder.shared()
    private var videoOutputURL: URL?
    
    @Published var isRecording = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Start screen recording
    func startRecording() {
        guard !isRecording else { return }
        
        // Request screen recording permission and start recording
        recorder.startRecording { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isRecording = true
                }
            }
        }
    }
    
    // Stop recording and save video
    func stopRecording() {
        guard isRecording else { return }
        
        // Create temporary URL for video output
        let tempDirectory = FileManager.default.temporaryDirectory
        videoOutputURL = tempDirectory.appendingPathComponent("screen_recording.mp4")
        
        guard let outputURL = videoOutputURL else {
            showError = true
            errorMessage = "Failed to create video file"
            return
        }
        
        // Remove any existing file
        try? FileManager.default.removeItem(at: outputURL)
        
        // Stop recording and save to temporary file
        recorder.stopRecording(withOutput: outputURL) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isRecording = false
                    self?.saveVideoToPhotos()
                }
            }
        }
    }
    
    // Save video to photo library
    private func saveVideoToPhotos() {
        guard let videoURL = videoOutputURL else { return }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self?.showError = true
                    self?.errorMessage = "Photo library access denied"
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .video, fileURL: videoURL, options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showError = true
                        self?.errorMessage = error.localizedDescription
                    }
                    
                    // Clean up temporary file
                    try? FileManager.default.removeItem(at: videoURL)
                    self?.videoOutputURL = nil
                }
            }
        }
    }
}
