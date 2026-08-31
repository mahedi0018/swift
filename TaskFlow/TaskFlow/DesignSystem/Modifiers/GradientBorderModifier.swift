//
//  RotatingGradientBorder.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 16/8/26.
//

import SwiftUI

// Custom ViewModifier ja jekono Shapes (Capsule, RoundedRectangle) support korbe

struct GradientBorderModifier<S: Shape, M: ViewModifier>: ViewModifier {
    let shape: S
    let colors: [Color]
    let lineWidth: CGFloat
    let duration: Double
    let gradientModifierAnimation: M
    
    @State private var rotationAngle: Double = 0   //এই স্টেট ভ্যারিয়েবলটি গ্র্যাডিয়েন্ট এঙ্গেল ধরে রাখে (শুরুতে 0°), যা পরিবর্তন করে বর্ডারটি ঘুরানো হয়।
    
    
    
    func body(content: Content) -> some View {
        content
            .clipShape(shape)
            .overlay(
                GeometryReader { proxy in
                    // 💡 ১. ডায়াগোনাল কভার করার জন্য ক্যাপসুলের চেয়ে বড় স্কয়ার ফ্রেম হিসেব
                    let maxSide = max(proxy.size.width, proxy.size.height) * 1.8
                    
                    AngularGradient(
                        colors: colors,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    )
                    .frame(width: maxSide, height: maxSide) // 💡 বর্গাকার ফ্রেম
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2) // 💡 সেন্টারে পজিশন
                    .modifier(gradientModifierAnimation) // Spin or other animations
                }
            
                
                .mask(shape.stroke(style: StrokeStyle(lineWidth: lineWidth)))
            )
    }
}


extension View {
    func gradientBorder<S: Shape, M: ViewModifier>(
        shape: S = Capsule(),
        colors: [Color] = [
            Color.accentSecondary,
            Color.accentPrimary.opacity(0.15),
            Color.white.opacity(0.85),
            Color.accentSecondary
        ],
        lineWidth: CGFloat = 2,
        duration: Double = 4.0,
        gradientModifier: M = EmptyModifier() // By default no Animation
    ) -> some View {
        self.modifier(
            GradientBorderModifier(
                shape: shape,
                colors: colors,
                lineWidth: lineWidth,
                duration: duration,
                gradientModifierAnimation: gradientModifier
            )
        )
    }
}
