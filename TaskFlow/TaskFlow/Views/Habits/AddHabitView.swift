//
//  AddHabitView.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 22/8/26.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: HabitListViewModel
    
    @State private var title: String = ""
    @State private var iconName: String = ""
    @State private var goal: Int = 21
    @State private var colorName: String = "accentPrimary"
    @State private var selectedColor: String = "accentPrimary"
    @State private var selectedIcon: HabitIcon = .meditation
    @State private var reminderTime = Date()
    
    let colorOptions = ["accentPrimary", "success", "info", "warning", "danger"]
    
    let columns = [GridItem(.adaptive(minimum: 44))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add New Habit")
                .font(.title2.bold())
                .padding(.top, 8)
            
            TextField("Title", text: $title)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(Color.bgCard.cornerRadius(12))
                    
                    
                )
                .foregroundColor(Color.textPrimary)
            Stepper("Goal: \(goal) days", value: $goal, in: 1...365, step: 1)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(Color.bgCard.cornerRadius(12))
                    
                    
                )
                .foregroundStyle(Color.textPrimary)
            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                
                HStack(spacing: 12) {
                    ForEach(colorOptions, id: \.self) { colorName in
                        Circle()
                            .fill(Color(colorName))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: selectedColor == colorName ? 2 : 0)
                            )
                            .onTapGesture { selectedColor = colorName }
                    }
                }
            }
            
            DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                .foregroundStyle(Color.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Icon")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(HabitIcon.allCases, id: \.self) { icon in
                        Image(systemName: icon.rawValue)
                            .font(.system(size: 18))
                            .foregroundStyle(selectedIcon == icon ? .white : Color.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(selectedIcon == icon ? Color(selectedColor) : Color.bgSecondary)
                            )
                            .onTapGesture {
                                selectedIcon = icon
                                let currentTitle = title.trimmingCharacters(in: .whitespaces)
                                
                                let isDefaultTitle = HabitIcon.allCases.contains { $0.defaultTitle == currentTitle }
                                
                                if currentTitle.isEmpty || isDefaultTitle {
                                    title = icon.defaultTitle
                                }
                            }
                    }
                }
            }
            
            Button {
                viewModel.addNewHabit(title: title, iconName: selectedIcon.rawValue, goal: goal, colorName: selectedColor, reminderTime: reminderTime)
                    dismiss()
            } label: {
                Text("Create Habit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(title.isEmpty)
            .opacity(title.isEmpty ? 0.5 : 1)
            
        }
        .padding(20)
        //        .presentationDetents([.height(420)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    let viewModel = HabitListViewModel()
    AddHabitView(viewModel: viewModel)
}
