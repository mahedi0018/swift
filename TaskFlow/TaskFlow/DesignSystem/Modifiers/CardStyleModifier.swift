//
//  CardStyleModifier.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 10/8/26.
//

import Foundation
import SwiftUI

struct CardStyleModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var backgroundColor: Color = Color.bgCard
    var borderColor: Color = .white.opacity(0.08)
    var borderWidth: CGFloat = 1
    var paddingAmount: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(paddingAmount)
            .background(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
}

// MARK: - View Extension for easy access

extension View {
    func cardStyle(
        cornerRadius: CGFloat = 20,
        backgroundColor: Color = Color.bgCard,
        borderColor: Color = .white.opacity(0.08),
        borderWidth: CGFloat = 1,
        paddingAmount: CGFloat = 16
    ) -> some View {
        modifier(CardStyleModifier(
            cornerRadius: cornerRadius,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            paddingAmount: paddingAmount
        ))
    }
}
