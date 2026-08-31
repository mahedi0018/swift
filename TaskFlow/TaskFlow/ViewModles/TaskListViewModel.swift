//
//  TaskListViewModel.swift
//  TaskFlow
//
//  Created by Md. Mahedi Hasan on 8/8/26.
//

import Foundation
import Realm
import RealmSwift
import FirebaseAuth


@Observable
class TaskListViewModel {
    var tasks: [Task] = []
    
    private let realmManager = RealmManager.shared
    private var notificationToken: NotificationToken?
    
    var taskCompletedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTaskCount: Int {
        tasks.count
    }
    
    var completionProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(taskCompletedCount) / Double(totalTaskCount)
    }
    
    init() {
        observeTasks()
    }
    
    private func observeTasks() {
        let results = realmManager.getAllTasks()
        tasks = Array(results)
        
        notificationToken = results.observe { [weak self] changes in
            switch changes {
            case .initial:
                self?.tasks = Array(results)
            case .update(let results, _, _, _):
                self?.tasks = Array(results)
            case .error(let error):
                print("Realm observe error: \(error)")
            }
        }
    }
    
    func addTask(title: String, category: String, priority: String) {
        guard let uid = AuthManager.shared.currentUser?.uid else { return }
        let newTask = Task()
        newTask.title = title
        newTask.category = category
        newTask.priority = priority
        newTask.userId = uid
        realmManager.add(newTask)
    }
    
    func toggleComplete(_ task: Task) {
        realmManager.update {
            task.isCompleted.toggle()
        }
    }
    
    func deleteTask(_ task: Task) {
        realmManager.delete(task)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}
