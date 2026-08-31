//
//  AddTaskView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: TaskListViewModel
    
    @State private var title: String = ""
    @State private var category: String = "Work"
    @State private var priority: String = "Medium"
    
    let categories = TaskCategory.allCases
    let priorities = TaskPriority.allCases
    

    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick Add Task")
                .font(.title2.bold())
                .padding(.top, 8)
            
            TextField("What needs to be done?", text: $title)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(Color.bgCard.cornerRadius(12))
                        
                        
                )
                .foregroundColor(Color.textPrimary)
            
            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { item in
                        chipButton(
                            title: item.rawValue,
                            isSelected: category == item.rawValue,
                            selectedColor: item.color,
                            deselectedColor: Color.bgCard,
                            action: {
                                category = item.rawValue
                            }
                        )
                    }
                }
            }
            
            
            // Priority chips
            HStack(spacing: 12) {
                ForEach(priorities, id: \.self) { item in
                    chipButton(
                        title: item.rawValue,
                        isSelected: priority == item.rawValue,
                        selectedColor: item.color,
                        deselectedColor: Color.bgCard.opacity(0.1),
                    ) {
                        priority = item.rawValue
                    }
                }
            }
            
            Button{
                viewModel.addTask(title: title, category: category, priority: priority)
                dismiss()
            } label: {
                Text("Add Task")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.purple, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(title.isEmpty)
            .opacity(title.isEmpty ? 0.5 : 1.0)
        }
        .padding(20)
        .presentationDetents([.height(420)])
        .presentationDragIndicator(.visible)
    }
}


@ViewBuilder
func chipButton(title: String, isSelected: Bool, selectedColor: Color, deselectedColor: Color, action: @escaping () -> Void) -> some View {
    Button(action: action) {
    
        Text(title)
            .font(.system(size: 14, weight: .medium, design: .default))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundColor(isSelected ? selectedColor : .gray)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? selectedColor.opacity(0.15) : deselectedColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? selectedColor : .gray.opacity(0.2), lineWidth: 1)
            )
        
    }
    .buttonStyle(.plain)
}





#Preview {
    let viewModel = TaskListViewModel()
    AddTaskView(viewModel: viewModel)
}
