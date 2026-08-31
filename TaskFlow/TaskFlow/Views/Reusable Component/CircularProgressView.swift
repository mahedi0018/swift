//
//  CircularProgressView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 10/8/26.
//

import SwiftUI

struct CircularProgressView: View {
    
    var progress : Double // 0.0 to 1.0
    var lineWidth : CGFloat? = nil
    var size : CGFloat = 90
    var iconName : String? = nil
    var colors: [Color] = [.purple, .indigo]
    
    var body: some View {
        GeometryReader { geometry in
            
            // it will take min w/h from parent view
            let size = min(geometry.size.width, geometry.size.height)
            
            let dynamicLineWidth = lineWidth ?? size / 10
            
            let dynamicFontSize = size * 0.22
            
            let dynamicIconSize: CGFloat = 0.35 * size
            
            
            
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: dynamicLineWidth)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: dynamicLineWidth, lineCap: .round)
                    )
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut(duration: 0.6), value: progress)
                if let iconName = iconName {
                    Image(systemName: iconName)
                            .font(.system(size: dynamicIconSize, weight: .medium))
                            .foregroundStyle(colors[0])
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: dynamicFontSize, weight: .bold))
                }
                
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        
    }
}

#Preview {
    CircularProgressView(progress: 0.3)
}
