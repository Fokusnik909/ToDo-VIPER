//
//  TasksListPresenter.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import Foundation

protocol TasksListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTask(_ task: TaskModel)
    func didToggleTaskCompletion(_ task: TaskModel)
    func didTapAddTask()
    func didSearch(query: String)
    func presentTasks(_ tasks: [TaskModel])
    func didLoadTasks(_ tasks: [TaskModel])
    func didFailLoadingTasks(with message: String)
}

final class TasksListPresenter: TasksListPresenterProtocol {
    weak var view: TasksListViewProtocol?
    var interactor: TasksListInteractorProtocol
    var router: TasksListRouterProtocol

    private var tasks: [TaskModel] = []

    init(view: TasksListViewProtocol,
         interactor: TasksListInteractorProtocol,
         router: TasksListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        interactor.fetchTasks()
    }

    func didSelectTask(_ task: TaskModel) {
        router.navigateToTaskDetails(task)
    }

    func didToggleTaskCompletion(_ task: TaskModel) {
        interactor.toggleTaskCompletion(task: task)
    }

    func didTapAddTask() {
        router.navigateToAddTask()
    }

    func didSearch(query: String) {
        interactor.searchTasks(query: query)
    }
    
    func presentTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        view?.showTasks(tasks)
    }
    
    func didLoadTasks(_ tasks: [TaskModel]) {
        presentTasks(tasks)
    }

    func didFailLoadingTasks(with message: String) {
        view?.showError(message)
    }
}
