//
//  TaskRow.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 25/8/26.
//

import SwiftUI
import RealmSwift

struct TaskRow: View {
    @ObservedRealmObject var task: Task
    var onToggle: () -> Void
    var onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    private var dragProgress: Double {
        let maxThreshold: CGFloat = 70.0
        let currentOffset = min(max(-offset, 0), maxThreshold)
        return Double(currentOffset / maxThreshold)
    }
    
    var body: some View {
        if task.isInvalidated {
            EmptyView()
        }else{
            ZStack(alignment: .trailing) {
                // Red Delete Button on back
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 60)
                        .frame(maxHeight: .infinity)
                        .background(Color.red)
                        .cornerRadius(16)
                        .scaleEffect(0.2 + (dragProgress * 0.8))
                        .opacity(dragProgress)
                }
                .buttonStyle(.plain)
                HStack(spacing: 14) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(task.isCompleted ? Color.accentPrimary : .secondary)
                        .onTapGesture {
                            onToggle()
                        }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                            .font(.subheadline.bold())
                        
                        HStack(spacing: 8) {
                            Text(task.category)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(task.categoryEnum.color.opacity(0.15)))
                                .foregroundColor(task.categoryEnum.color)
                            
                            Text(task.priority)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(task.priorityEnum.color.opacity(0.15)))
                                .foregroundColor(task.priorityEnum.color)
                            
                            Text("9:00 AM")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .glassCardStyle()
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged{ value in
                            if value.translation.width < 0 {
                                offset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if value.translation.width < -80 {
                                    offset = -70
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
            }
            .transition(.move(edge: .leading).combined(with: .opacity))
        }
        
    }
}

//#Preview {
//    TaskRow(task: <#Task#>, onToggle: <#() -> Void#>)
//}
