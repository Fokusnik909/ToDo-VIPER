//
//  TasksListInteractor.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import Foundation

protocol TasksListInteractorProtocol: AnyObject {
    var numberOfTasks: Int { get }
    func task(at indexPath: IndexPath) -> TaskModel
    func fetchTasks()
    func searchTasks(query: String)
    func toggleTaskCompletion(id: Int64)
    func deleteTask(_ task: TaskModel)
}

final class TasksListInteractor: TasksListInteractorProtocol {
    weak var presenter: TasksListPresenterProtocol?
    
    private let networkService: NetworkServiceProtocol
    private let taskStore: TaskManagerProtocol

    
    init(networkService: NetworkServiceProtocol, taskStore: TaskManagerProtocol) {
        self.networkService = networkService
        self.taskStore = taskStore
    }
    
    var numberOfTasks: Int {
        taskStore.numberOfTasks
    }
    
    func fetchTasks() {
        CoreDataManager.shared.fetchTasks { [weak self] localTasks in
            guard let self = self else { return }
            if localTasks.isEmpty {
                self.networkService.fetchTasks { result in
                    switch result {
                    case .success(let dtos):
                        let models = dtos.map { TaskModel(from: $0) }
                        CoreDataManager.shared.addTasks(models)
                    case .failure(let error):
                        self.presenter?.didFailLoadingTasks(with: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func searchTasks(query: String) {
        taskStore.searchTasks(with: query)
    }
    
    func deleteTask(_ task: TaskModel) {
        taskStore.deleteTask(id: task.id)
    }
    
    func task(at indexPath: IndexPath) -> TaskModel {
        taskStore.task(at: indexPath)
    }
    
    func toggleTaskCompletion(id: Int64) {
        taskStore.toggleCompleted(id: id)
    }
    
    private func findIndexPath(for task: TaskModel) -> IndexPath? {
        for row in 0..<taskStore.numberOfTasks {
            let indexPath = IndexPath(row: row, section: 0)
            if taskStore.task(at: indexPath).id == task.id {
                return indexPath
            }
        }
        return nil
    }
}

extension TasksListInteractor: TaskStoreDelegate {
    func didUpdate(_ update: TaskStoreUpdate) {
        presenter?.didUpdateTable(update: update, count: taskStore.numberOfTasks)
    }
}

