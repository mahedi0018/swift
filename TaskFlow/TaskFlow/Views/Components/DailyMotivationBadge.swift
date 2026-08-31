//
//  DailyMotivationBadge.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 16/8/26.
//

import SwiftUI

struct DailyMotivationBadge: View {
    @State private var rotationAngle: Double = 0
    @State private var isPulsing: Bool = false
    
    var body: some View {
        HStack(spacing: 6) {
            // 💡 ১. Micro Sparkle Icon Animation
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#A78BFA"))
                .scaleEffect(isPulsing ? 1.25 : 0.85)
                .opacity(isPulsing ? 1.0 : 0.6)
            
            Text("DAILY MOTIVATION")
                .font(.caption2.bold())
                .tracking(1.2)
                .foregroundColor(Color(hex: "#A78BFA"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            ZStack {
                // 💡 ২. Semi-transparent Background Pill
                Capsule()
                    .fill(Color(hex: "#7C3AED").opacity(isPulsing ? 0.20 : 0.10))
                
                // 💡 ৩. Rotating Border Stroke Animation
                Capsule()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(hex: "#A78BFA"),
                                Color(hex: "#7C3AED").opacity(0.1),
                                Color.white.opacity(0.8), // বর্ডারের হাইলাইট স্পট
                                Color(hex: "#A78BFA")
                            ],
                            center: .center,
                            startAngle: .degrees(rotationAngle),
                            endAngle: .degrees(rotationAngle + 360)
                        ),
                        lineWidth: 1.2
                    )
            }
        )
        // 💡 ৪. Ambient Soft Glow Shadow
        .shadow(
            color: Color(hex: "#A78BFA").opacity(isPulsing ? 0.45 : 0.15),
            radius: isPulsing ? 10 : 4,
            x: 0,
            y: 0
        )
        .onAppear {
            // 🔄 বর্ডার লাইটের অনবরত ঘূর্ণন
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            // 💓 সফট ব্রীদিং পালস
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                print("", isPulsing)
                isPulsing = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DailyMotivationBadge()
    }
}
