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
    func didRequestDelete(_ task: TaskModel)
    
    func didLoadTasks(_ tasks: [TaskModel])
    func didFailLoadingTasks(with message: String)
    func updateTaskInView(_ task: TaskModel)
}

final class TasksListPresenter: TasksListPresenterProtocol {
    
    weak var view: TasksListViewProtocol?
    private let interactor: TasksListInteractorProtocol
    private let router: TasksListRouterProtocol
    
    private var tasks: [TaskModel] = []
    
    init(view: TasksListViewProtocol,
         interactor: TasksListInteractorProtocol,
         router: TasksListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    //MARK: - View Lifecycle
    func viewDidLoad() {
        interactor.fetchTasks()
//        CoreDataManager.shared.deleteAllTasks()
    }
    
    //MARK: - Navigation
    func didTapAddTask() {
        let editorVC = TaskEditorBuilder.build(with: .add) { [weak self] in
            self?.viewDidLoad()
        }
        router.openEditor(viewController: editorVC)
    }
    
    func didSelectTask(_ task: TaskModel) {
        let editorVC = TaskEditorBuilder.build(with: .edit(task)) { [weak self] in
            self?.viewDidLoad()
        }
        router.openEditor(viewController: editorVC)
    }
    
    //MARK: - Task Interactions
    func didToggleTaskCompletion(_ task: TaskModel) {
        interactor.toggleTaskCompletion(task: task)
    }
    
    func didSearch(query: String) {
        interactor.searchTasks(query: query)
    }
    
    func didRequestDelete(_ task: TaskModel) {
        interactor.deleteTask(task)
    }
    
    //MARK: - Data Presentation
    func didLoadTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        view?.showTasks(tasks)
    }
    
    func didFailLoadingTasks(with message: String) {
        view?.showError(message)
    }
    
    func updateTaskInView(_ task: TaskModel) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        view?.showTasks(tasks)
    }
}
