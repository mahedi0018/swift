//
//  GlassCardModifier.swift
//  TaskFlow
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    var cornerRadius: CGFloat = 22
    var paddingAmount: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(paddingAmount)
            .background(
                ZStack {
                    // ১. নেটিভ ফ্রস্টেড গ্লাস ব্লার লেয়ার (Base Layer)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // ২. ট্রান্সলুসেন্ট কালার টিন্ট (Middle Layer)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            colorScheme == .dark
                                ? Color(red: 0.10, green: 0.11, blue: 0.15).opacity(0.65) // #1A1B26 translucency
                                : Color.white.opacity(0.75)
                        )
                }
            )
            // ৩. ফিগমা স্টাইল গ্লাস এজ বর্ডার (Top Overlay)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        colorScheme == .dark
                            ? LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.28), // কার্ডের ওপরের ধার চকচক করবে
                                    Color.purple.opacity(0.20)  // নিচের ধারের দিকে মিলিয়ে যাবে
                                ],
                                startPoint: .leading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [
                                    Color(red: 0.80, green: 0.84, blue: 0.88),
                                    Color(red: 0.80, green: 0.84, blue: 0.88).opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              ),
                        lineWidth: 1.2
                    )
            )
    }
}

extension View {
    func glassCardStyle(
        cornerRadius: CGFloat = 22,
        paddingAmount: CGFloat = 16
    ) -> some View {
        self.modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            paddingAmount: paddingAmount
        ))
    }
}
