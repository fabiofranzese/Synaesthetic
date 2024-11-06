import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    @State private var touchDuration: Float = 0.0
    private var pressStartTime: CFTimeInterval?
    private var isTouching: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        
        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.delegate = context.coordinator
        mtkView.device = device
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        
        // Add gesture recognizer for touch start and end
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0 // Immediate response
        mtkView.addGestureRecognizer(longPressGesture)
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.touchDuration = self.touchDuration
        context.coordinator.isTouching = self.isTouching
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var startTime: Float = Float(CACurrentMediaTime())
        var touchDuration: Float = 0.0
        var isTouching: Bool = false
        var lastHue: Float = 0.0  // Store the last hue when touch ends
        var lastTouchDuration: Float = 0.0 // Store the last touch duration to continue smoothly
        
        init(_ parent: MetalView) {
            self.parent = parent
            super.init()
            
            guard let device = MTLCreateSystemDefaultDevice() else { return }
            commandQueue = device.makeCommandQueue()
            
            // Load the shader from Shader.metal
            let library = device.makeDefaultLibrary()
            let vertexFunction = library?.makeFunction(name: "vertex_main")
            let fragmentFunction = library?.makeFunction(name: "fragment_main")
            
            // Set up the pipeline descriptor
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let pipelineState = pipelineState,
                  let commandBuffer = commandQueue?.makeCommandBuffer(),
                  let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            encoder.setRenderPipelineState(pipelineState)
            
            // Calculate touch duration or keep last hue when not touching
            var resolution = SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
            var time = Float(CACurrentMediaTime()) - startTime
            
            if isTouching {
                // Continue touchDuration from lastTouchDuration for smooth transition
                touchDuration = lastTouchDuration + Float(CACurrentMediaTime()) - Float(parent.pressStartTime ?? CACurrentMediaTime())
                lastHue = fmodf(touchDuration * 0.1, 1.0) // Update hue only when touching
            }
            encoder.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.size, index: 0)
            encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 1)
            encoder.setFragmentBytes(&lastHue, length: MemoryLayout<Float>.size, index: 2) // Send hue

            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            encoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
            if sender.state == .began {
                // Start the press using the last touch duration for continuity
                parent.pressStartTime = CACurrentMediaTime()
                isTouching = true
            } else if sender.state == .ended || sender.state == .cancelled {
                // Store the current touch duration and hue when touch ends
                lastTouchDuration = touchDuration
                isTouching = false
            }
        }
    }
}

