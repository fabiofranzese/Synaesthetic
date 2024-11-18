// AudioProcessor.swift
import AVFoundation

class AudioProcessor: ObservableObject {
    private var engine: AVAudioEngine
    private var fft: FFTProcessor
    private let bufferSize = 1024
    
    @Published var frequencyBands: [String: Float] = [
        "sub": 0,
        "low": 0,
        "mid": 0,
        "hi": 0,
        "treble": 0
    ]
    
    init() {
        self.engine = AVAudioEngine()
        self.fft = FFTProcessor(bufferSize: bufferSize)
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        //print("Setting up audio engine...")
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)
        //print("Input format: \(format)")
        
        inputNode.installTap(onBus: 0, bufferSize: UInt32(bufferSize), format: format) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }
        //print("Tap installed on input node")
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else {
            //print("No channel data available")
            return
        }
        let frameCount = UInt(buffer.frameLength)
        //print("Processing buffer with \(frameCount) frames")
        
        // Process audio data using FFT
        let frequencies = fft.process(data: Array(UnsafeBufferPointer(start: channelData, count: Int(frameCount))))
        
        // Group frequencies into bands
        let bands = groupFrequencyBands(frequencies)
        
        // Print some debug info about the bands
        //print("Band values - Sub: \(bands["sub"] ?? 0), Low: \(bands["low"] ?? 0), Mid: \(bands["mid"] ?? 0)")
        
        DispatchQueue.main.async {
            self.frequencyBands = bands
        }
    }
    
    private func groupFrequencyBands(_ frequencies: [Float]) -> [String: Float] {
        // Simplified frequency band grouping
        // You might want to adjust these ranges based on your needs
        let subRange = 0..<10     // 20-60 Hz
        let lowRange = 10..<80  // 60-250 Hz
        let midRange = 80..<250  // 250-2000 Hz
        let hiRange = 250..<500   // 2000-4000 Hz
        let trebleRange = 500..<frequencies.count // 4000-20000 Hz
        
        return [
            "sub": normalizeFrequencyBand(frequencies, range: subRange),
            "low": normalizeFrequencyBand(frequencies, range: lowRange),
            "mid": normalizeFrequencyBand(frequencies, range: midRange),
            "hi": normalizeFrequencyBand(frequencies, range: hiRange),
            "treble": normalizeFrequencyBand(frequencies, range: trebleRange)
        ]
    }
    
    private func normalizeFrequencyBand(_ frequencies: [Float], range: Range<Int>) -> Float {
        let values = frequencies[range]
        let sum = values.reduce(0, +)
        
        // Normalize to 0-255 range with smooth clamping
        let normalizedValue = sum * (255.0 / Float(range.count))
        return min(255, max(0, normalizedValue))
    }
    
    func start() throws {
        print("Starting audio engine...")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error)")
            throw error
        }
    }
    
    func stop() {
        engine.stop()
    }
}

// FFTProcessor.swift
import Accelerate

class FFTProcessor {
    private let bufferSize: Int
    private var fftSetup: vDSP_DFT_Setup?
    
    init(bufferSize: Int) {
        self.bufferSize = bufferSize
        self.fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            UInt(bufferSize),
            vDSP_DFT_Direction.FORWARD
        )
    }
    
    func process(data: [Float]) -> [Float] {
        var realIn = data
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
        
        // Apply Hanning window
        var window = [Float](repeating: 0, count: bufferSize)
        vDSP_hann_window(&window, UInt(bufferSize), Int32(vDSP_HANN_NORM))
        vDSP_vmul(realIn, 1, window, 1, &realIn, 1, UInt(bufferSize))
        
        // Perform FFT
        vDSP_DFT_Execute(fftSetup!, &realIn, &imagIn, &realOut, &imagOut)
        
        // Calculate magnitude spectrum
        var magnitudes = [Float](repeating: 0, count: bufferSize/2)
        
        realOut.withUnsafeMutableBufferPointer { realPtr in
            imagOut.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!,
                                                   imagp: imagPtr.baseAddress!)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, UInt(bufferSize/2))
            }
        }
        
        // Convert to dB scale with proper normalization
        var scaledMagnitudes = magnitudes
        
        // Add small value to avoid log(0)
        var small: Float = 1.0e-6
        vDSP_vsadd(magnitudes, 1, &small, &scaledMagnitudes, 1, UInt(bufferSize/2))
        
        // Convert to dB using temporary variable
        var tempMagnitudes = scaledMagnitudes
        var ones = [Float](repeating: 1.0, count: bufferSize/2)
        vDSP_vdbcon(&tempMagnitudes, 1, &ones, &scaledMagnitudes, 1, UInt(bufferSize/2), 1)
        
        // Normalize to 0-1 range
        var max: Float = 0
        vDSP_maxv(scaledMagnitudes, 1, &max, UInt(bufferSize/2))
        var min: Float = 0
        vDSP_minv(scaledMagnitudes, 1, &min, UInt(bufferSize/2))
        
        // Ensure we don't divide by zero
        let range = max - min
        if range > 0 {
            var scale = 1.0 / range
            // Manual normalization
            for i in 0..<bufferSize/2 {
                scaledMagnitudes[i] = (scaledMagnitudes[i] - min) * scale
            }
        }
        
        return scaledMagnitudes
    }
}
