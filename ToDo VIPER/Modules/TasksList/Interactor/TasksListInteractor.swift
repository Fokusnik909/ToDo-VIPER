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
            guard let self = self else { return }
            
            if localTasks.isEmpty {
                self.networkService.fetchTasks { result in
                    switch result {
                    case .success(let dtos):
                        let models = dtos.map { TaskModel(from: $0) }
                        self.coreDataManager.addTasks(models)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self.coreDataManager.fetchTasks { updated in
                                let finalModels = updated.map { TaskModel(from: $0) }
                                self.presenter?.didLoadTasks(finalModels)
                            }
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
        var updated = task
        updated.isCompleted.toggle()
        presenter?.updateTaskInView(updated)
        self.coreDataManager.addTask(from: updated)
        self.fetchTasks()
    }
}
