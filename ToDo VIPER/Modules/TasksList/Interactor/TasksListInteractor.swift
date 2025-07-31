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

    private let networkService: NetworkServiceProtocol
    private let coreDataManager = CoreDataManager.shared

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchTasks() {
        coreDataManager.fetchTasks { [weak self] localTasks in
            guard let self else { return }

            if localTasks.isEmpty {
                self.networkService.fetchTasks { result in
                    switch result {
                    case .success(let dtos):
                        let models = dtos.map { TaskModel(from: $0) }
                        self.coreDataManager.addTasks(models)
                        self.coreDataManager.saveContext()

                        self.coreDataManager.fetchTasks { updated in
                            let finalModels = updated.map { TaskModel(from: $0) }
                            self.presenter?.didLoadTasks(finalModels)
                        }

                    case .failure(let error):
                        self.presenter?.didFailLoadingTasks(with: error.localizedDescription)
                    }
                }

            } else {
                let models = localTasks.map { TaskModel(from: $0) }
                self.presenter?.didLoadTasks(models)
            }
        }
    }

    func searchTasks(query: String) {
        coreDataManager.searchTasks(query: query) { [weak self] results in
            let models = results.map { TaskModel(from: $0) }
            self?.presenter?.didLoadTasks(models)
        }
    }

    func toggleTaskCompletion(task: TaskModel) {
        coreDataManager.fetchTasks { tasks in
            if let target = tasks.first(where: { $0.id == task.id }) {
                var updated = task
                updated.isCompleted.toggle()
                self.coreDataManager.updateTask(target, with: updated)
                self.fetchTasks()
            }
        }
    }
    
}
