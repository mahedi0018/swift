//
//  SpinModifier.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 17/8/26.
//

import SwiftUI

struct SpinModifier: ViewModifier {
    let duration: Double
    @State private var isRotating: Bool = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    isRotating = true
                }
            }
    }
}



func spinCustomAnimation(duration: Double = 4.0) -> SpinModifier {
    SpinModifier(duration: duration)
}

