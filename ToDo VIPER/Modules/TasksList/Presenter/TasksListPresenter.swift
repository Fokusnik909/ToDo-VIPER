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
    
//    func didLoadTasks(_ tasks: [TaskModel])
    func didFailLoadingTasks(with message: String)
//    func updateTaskInView(_ task: TaskModel)
    
    func didUpdateTable(update: TaskStoreUpdate, count: Int)
    
    var numberOfTasks: Int { get }
    func task(at indexPath: IndexPath) -> TaskModel
}

final class TasksListPresenter: TasksListPresenterProtocol {
    weak var view: TasksListViewProtocol?
    private var interactor: TasksListInteractorProtocol?
    private let router: TasksListRouterProtocol
    
//    private var tasks: [TaskModel] = []
    private let taskStore: TaskManagerProtocol

    init(view: TasksListViewProtocol,
         router: TasksListRouterProtocol, taskStore: TaskManagerProtocol) {
        self.view = view
        self.router = router
        self.taskStore = taskStore
    }

    // MARK: - View Lifecycle
    func viewDidLoad() {
        interactor?.fetchTasks()
//        CoreDataManager.shared.deleteAllTasks()
    }

    // MARK: - UI Events
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
    

    func didToggleTaskCompletion(_ task: TaskModel) {
        interactor?.toggleTaskCompletion(task: task)
    }

    func didSearch(query: String) {
        interactor?.searchTasks(query: query)
    }

    func didRequestDelete(_ task: TaskModel) {
        interactor?.deleteTask(task)
    }
    
    func setInteractor(_ interactor: TasksListInteractorProtocol) {
        self.interactor = interactor
    }

    // MARK: - Data Presentation
    var numberOfTasks: Int {
        taskStore.numberOfTasks
    }
    
    func task(at indexPath: IndexPath) -> TaskModel {
        taskStore.task(at: indexPath)
    }
    
    func didFailLoadingTasks(with message: String) {
        view?.showError(message)
    }

    func didUpdateTable(update: TaskStoreUpdate, count: Int) {
        view?.updateTable(with: update, totalCount: count)
    }
    
}
