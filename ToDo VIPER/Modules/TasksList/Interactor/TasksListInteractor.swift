//
//  TasksListInteractor.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import Foundation

protocol TasksListInteractorProtocol: AnyObject {
    func fetchTasks()
    func searchTasks(query: String)
    func toggleTaskCompletion(task: TaskModel)
}

final class TasksListInteractor: TasksListInteractorProtocol {
    weak var presenter: TasksListPresenterProtocol?
    private let coreData = CoreDataManager.shared
    
    
    func fetchTasks() {
        DispatchQueue.global(qos: .background).async {
            self.coreData.fetchTasks { tasks in
                let models = tasks.map { coreData in
                    TaskModel(id: coreData.id,
                              title: coreData.title ?? "",
                              description: coreData.description,
                              dateCreated: coreData.dateCreated ?? Date(),
                              isCompleted: coreData.isCompleted,
                              userId: coreData.userid)
                }
                
                DispatchQueue.main.async {
                    self.presenter?.presentTasks(models)
                }
            }
        }
    }
    
    
    func searchTasks(query: String) {
        DispatchQueue.global(qos: .background).async {
            self.coreData.searchTasks(query: query) { tasks in
                let models = tasks.map { coreData in
                    TaskModel(
                        id: coreData.id,
                        title: coreData.title ?? "",
                        description: coreData.descriptionText,
                        dateCreated: coreData.dateCreated ?? Date(),
                        isCompleted: coreData.isCompleted,
                        userId: coreData.userid
                    )
                }
                
                DispatchQueue.main.async {
                    self.presenter?.presentTasks(models)
                }
            }
        }
    }
    
    
    func toggleTaskCompletion(task: TaskModel) {
        DispatchQueue.global(qos: .background).async {
            self.coreData.fetchTasks { all in
                if let stored = all.first(where: { $0.id == task.id }) {
                    let updated = TaskModel(
                        id: stored.id,
                        title: stored.title ?? "",
                        description: stored.descriptionText,
                        dateCreated: stored.dateCreated ?? Date(),
                        isCompleted: !stored.isCompleted,
                        userId: stored.userid
                    )
                    self.coreData.updateTask(stored, with: updated)
                    
                    self.fetchTasks()
                }
            }
        }
    }
}
