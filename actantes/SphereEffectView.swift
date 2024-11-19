//
//  File.swift
//  actantes
//
//  Created by Gabriele Fiore on 19/11/24.
//

import SwiftUI

struct EffectView: View {
    @State private var start = Date.now
    @ObservedObject var audioProcessor: AudioProcessor

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = start.distance(to: timeline.date)

            // Normalize frequency band values between 0.0 and 1.0
            let sub = Float(audioProcessor.frequencyBands["sub"] ?? 0) / 255.0
            let low = Float(audioProcessor.frequencyBands["low"] ?? 0) / 255.0
            let mid = Float(audioProcessor.frequencyBands["mid"] ?? 0) / 255.0
            let hi = Float(audioProcessor.frequencyBands["hi"] ?? 0) / 255.0
            let treble = Float(audioProcessor.frequencyBands["treble"] ?? 0) / 255.0

            Rectangle()
                .visualEffect { content, proxy in
                    content.colorEffect(
                        ShaderLibrary.liquidSphere(
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
