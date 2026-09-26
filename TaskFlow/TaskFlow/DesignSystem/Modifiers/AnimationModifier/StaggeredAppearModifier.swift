//
//  StaggeredAppearModifier.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 7/9/26.
//

import SwiftUI

enum MotionTokens {
    static let staggerBaseDelay: Double = 0.1
    static let staggerMaxIndex: Int = 10
    static let entranceAnimation: Animation = .spring(response: 0.75, dampingFraction: 0.82)
}


struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private var delay: Double {
        Double(min(index, MotionTokens.staggerMaxIndex)) * MotionTokens.staggerBaseDelay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.96)
            .offset(y: hasAppeared ? 0 : 16)
            .onAppear {
                guard !hasAppeared else { return }   // 💡 re-trigger থেকে সুরক্ষা
                
                if reduceMotion {
                    hasAppeared = true   // ইনস্ট্যান্ট, কোনো motion ছাড়াই
                } else {
                    withAnimation(MotionTokens.entranceAnimation.delay(delay)) {
                        hasAppeared = true
                    }
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppearModifier(index: index))
    }
}
