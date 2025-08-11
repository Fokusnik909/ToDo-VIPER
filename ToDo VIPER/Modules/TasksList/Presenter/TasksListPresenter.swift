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
    func didToggleTaskCompletion(id: Int64)
    func didTapAddTask()
    func didSearch(query: String)
    func didRequestDelete(_ task: TaskModel)
    
    func didFailLoadingTasks(with message: String)
    func didUpdateTable(update: TaskStoreUpdate, count: Int)
    
    var numberOfTasks: Int { get }
    func task(at indexPath: IndexPath) -> TaskModel
}

final class TasksListPresenter: TasksListPresenterProtocol {
    weak var view: TasksListViewProtocol?
    private var interactor: TasksListInteractorProtocol
    private let router: TasksListRouterProtocol
    

    init(view: TasksListViewProtocol,
         router: TasksListRouterProtocol,
         interactor: TasksListInteractorProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }

    // MARK: - View Lifecycle
    func viewDidLoad() {
        interactor.fetchTasks()
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
    

    func didToggleTaskCompletion(id: Int64) {
        interactor.toggleTaskCompletion(id: id)
    }

    func didSearch(query: String) {
        interactor.searchTasks(query: query)
    }

    func didRequestDelete(_ task: TaskModel) {
        interactor.deleteTask(task)
    }

    // MARK: - Data Presentation
    var numberOfTasks: Int {
        interactor.numberOfTasks
    }
    
    func task(at indexPath: IndexPath) -> TaskModel {
        interactor.task(at: indexPath)
    }
    
    func didFailLoadingTasks(with message: String) {
        assert(Thread.isMainThread, " didFailLoadingTasks: вызывается не на главном потоке!")
        view?.showError(message)
    }

    func didUpdateTable(update: TaskStoreUpdate, count: Int) {
        assert(Thread.isMainThread, " didUpdateTable: вызывается не на главном потоке!")
        view?.updateTable(with: update, totalCount: count)
    }
    
}
