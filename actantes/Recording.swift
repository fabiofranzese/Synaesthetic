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
    @Published var url: URL? //
    
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
        print(outputURL.absoluteString)
        // Stop recording and save to temporary file
        recorder.stopRecording(withOutput: outputURL) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isRecording = false
                    self?.url = outputURL
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

func convertMP4ToMOV(mp4URL: URL?) -> URL {
    let asset = AVAsset(url: mp4URL!)
    
    // Create the destination URL for the .mov file
    let tempDirectory = FileManager.default.temporaryDirectory
    let movURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    
    // Create an export session
    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
    
    exportSession!.outputURL = movURL
    exportSession!.outputFileType = .mov
    
    let group = DispatchGroup()
        group.enter()
    exportSession!.exportAsynchronously {
            group.leave()
        }
        group.wait()

    return movURL
}

func extractRandomFrameURL(from videoURL: URL?) -> URL? {
    let asset = AVAsset(url: videoURL!)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true // Corrects orientation
    
    if FileManager.default.fileExists(atPath: videoURL!.path) {
        print("File exists at: \(videoURL!.path)")
    } else {
        print("File does not exist at: \(videoURL!.path)")
        return nil
    }
    
    // Generate a random time within the video's duration
    let duration = CMTimeGetSeconds(asset.duration)
    guard duration > 0 else { return nil }
    
    let randomTime = CMTime(seconds: Double.random(in: 0..<duration), preferredTimescale: 600)
    
    do {
        let cgImage = try imageGenerator.copyCGImage(at: randomTime, actualTime: nil)
        let image = UIImage(cgImage: cgImage)
        
        // Convert the image to JPEG data
        guard let jpegData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        // Save the JPEG data to a temporary file
        let tempDirectory = FileManager.default.temporaryDirectory
        let jpgURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        try jpegData.write(to: jpgURL)
        
        return jpgURL
    } catch {
        return nil
    }
}

func saveJPGToPhotos(from url: URL, completion: @escaping (Bool) -> Void) {
    // Request photo library authorization
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        guard status == .authorized else {
            print("Photo library access not granted.")
            completion(false)
            return
        }
        
        PHPhotoLibrary.shared().performChanges {
            // Add the image file to the photo library
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: url, options: nil)
        } completionHandler: { success, error in
            if let error = error {
                print("Error saving photo: \(error.localizedDescription)")
            } else if success {
                print("Photo saved successfully!")
            }
            completion(success)
        }
    }
}

func saveMOVToPhotos(from url: URL, completion: @escaping (Bool) -> Void) {
    // Request photo library authorization
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        guard status == .authorized else {
            print("Photo library access not granted.")
            completion(false)
            return
        }
        
        PHPhotoLibrary.shared().performChanges {
            // Add the video file to the photo library
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: url, options: nil)
        } completionHandler: { success, error in
            if let error = error {
                print("Error saving video: \(error.localizedDescription)")
            } else if success {
                print("Video saved successfully!")
            }
            completion(success)
        }
    }
}
