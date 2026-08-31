//
//  TasksProgressCardView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 30/8/26.
//

import SwiftUI
import RealmSwift

struct TasksProgressCardView: View {
    @ObservedResults(Task.self) var tasks
    
    private var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var progress: Double {
        tasks.isEmpty ? 0 : Double(completedCount) / Double(tasks.count)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            CircularProgressView(progress: progress)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(completedCount) of \(tasks.count) tasks complete")
                    .font(.subheadline.bold())
                
                ProgressView(value: progress)
                    .tint(Color.accentPrimary)
            }
            
            Spacer()
            
            Text("On track")
                .font(.subheadline.bold())
                .foregroundColor(Color.success)
        }
        .glassCardStyle()
    }
}

#Preview {
    TasksProgressCardView()
}
