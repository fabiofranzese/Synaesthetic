//
//  ContentView.swift
//  wave
//
//  Created by Gabriele Fiore on 08/11/24.
//

import SwiftUI

struct ContentView: View {
    // Capture the start time when the view is created
    let start = Date()

    var body: some View {
        TimelineView(.animation) { tl in
            // Calculate elapsed time since the start
            let time = start.distance(to: tl.date)
            
            // Apply the sinebow shader effect to a fullscreen Rectangle
            Rectangle()
                .visualEffect { content, proxy in
                    content.colorEffect(
                        ShaderLibrary.sinebow( // Reference to the Metal shader
                            .float2(proxy.size), // Pass the size of the view
                            .float(time)         // Pass the elapsed time
                        )
                    )
                }
                .ignoresSafeArea() // Make the Rectangle fill the entire screen
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
