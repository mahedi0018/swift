//
//  ShimmerLightModifier.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 16/8/26.
//

import SwiftUI

// MARK: - Sheen/Shimmer Light Beam
///LinearGradient-কে একটু কোনাকুনি ঘুরিয়ে xOffset অ্যানিমেট করলে আলোটি বাম থেকে ডানে পাস হওয়ার ইফেক্টটি তৈরি হয়

struct ShimmerLightModifier<S: Shape>: ViewModifier {
    let shape: S
    let duration: Double
    
    @State var xOffset: CGFloat = -150
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let width = geometry.size.width
                    
                    Rectangle()
                        .fill(
                             LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.accentPrimary.opacity(0.2),  // original shade of light
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                             
                             )
                        )
                        .frame(width: width * 0.6)    // alor bimer width
                        .rotationEffect(.degrees(1)) // samanno kath kore alo fela
                        .offset(x: xOffset)
                        .onAppear{
                            xOffset = -width
                            withAnimation(
                                .linear(duration: duration)
                                .repeatForever(autoreverses: false)
                            ){
                                xOffset = width * 1.8
                            }
                        }
                }
            )
            .clipShape(shape)  // background shape ar bhitor alo k atke rakha
    }
}
                                        

// Extension for esaier use
extension View {
    func shimmerLight<S: Shape>(shape: S = Capsule(), duration: Double = 5) -> some View {
        modifier(ShimmerLightModifier(shape: shape, duration: duration))
    }
}
