//
//  AccentColorPickerView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 26/8/26.
//

import SwiftUI


struct AccentColorPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: String
    let colorOptions: [String]

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Accent Color")
                .font(.title3.bold())
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: 16) {
                ForEach(colorOptions, id: \.self) { colorName in
                    Circle()
                        .fill(Color(colorName))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: selectedColor == colorName ? 2 : 0)
                        )
                        .onTapGesture {
                            selectedColor = colorName
                            dismiss()
                        }
                }
            }
        }
        .padding(24)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
    }
}


