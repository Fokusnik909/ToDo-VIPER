//
//  ToDo_VIPERTests.swift
//  ToDo VIPERTests
//
//  Created by Артур  Арсланов on 07.08.2025.
//

import XCTest
@testable import ToDo_VIPER

final class TasksListPresenterTests: XCTestCase {
    
    private var view: MockView!
    private var interactor: MockInteractor!
    private var router: MockRouter!
    private var presenter: TasksListPresenter!
    
    override func setUp() {
        super.setUp()
        view = MockView()
        interactor = MockInteractor()
        router = MockRouter()
        presenter = TasksListPresenter(view: view, router: router, interactor: interactor)
    }
    
    
    // MARK: - Test Doubles
    final class MockView: TasksListViewProtocol {
        var didShowError = false
        var errorMessage: String?
        var didUpdateTable = false
        var updatedCount: Int?
        
        func showTasks(_ tasks: [TaskModel]) {}
        
        func showError(_ message: String) {
            didShowError = true
            errorMessage = message
        }
        
        func updateTable(with update: TaskStoreUpdate, totalCount: Int) {
            didUpdateTable = true
            updatedCount = totalCount
        }
    }
    
    final class MockInteractor: TasksListInteractorProtocol {
        var numberOfTasks: Int = 0
        
        func task(at indexPath: IndexPath) -> ToDo_VIPER.TaskModel {
            TaskModel(id: 1, title: "test", description: "text", dateCreated: Date(), isCompleted: true, userId: 1)
        }
        
        var didFetchTasks = false
        var didSearchQuery: String?
        var toggledTask: TaskModel?
        var deletedTask: TaskModel?
        
        func fetchTasks() {
            didFetchTasks = true
        }
        
        func searchTasks(query: String) {
            didSearchQuery = query
        }
        
        func toggleTaskCompletion(task: TaskModel) {
            toggledTask = task
        }
        
        func deleteTask(_ task: TaskModel) {
            deletedTask = task
        }
    }
    
    final class MockRouter: TasksListRouterProtocol {
        var didOpenEditor = false
        func openEditor(viewController: UIViewController) {
            didOpenEditor = true
        }
    }
    
    // MARK: - Tests
    
    func test_viewDidLoad_ShouldCallFetchTasks() {
        // Given
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(interactor.didFetchTasks, "viewDidLoad должен вызвать fetchTasks у интерактора")
    }
    
    func test_didTapAddTask_shouldOpenEditor() {
        // Given
        
        // When
        presenter.didTapAddTask()
        
        // Then
        XCTAssertTrue(router.didOpenEditor, "didTapAddTask должен вызвать openEditor у роутера")
    }
    
    func test_didSearch_shouldPassQueryToInteractor() {
        // Given
        let query = "тестовая задача"
        
        // When
        presenter.didSearch(query: query)
        
        // Then
        XCTAssertEqual(interactor.didSearchQuery, query, "didSearch должен передать правильный запрос в интерактор")
    }
    
    func test_didRequestDelete_shouldDeleteTask() {
        // Given
        let task = TaskModel(id: 1, title: "test", description: "text", dateCreated: Date(), isCompleted: true, userId: 1)
        
        // When
        presenter.didRequestDelete(task)
        
        // Then
        XCTAssertEqual(interactor.deletedTask?.id, task.id, "didRequestDelete должен вызвать deleteTask у интерактора")
    }
    
    func test_didFailLoadingTasks_shouldShowError() {
        // Given
        let errorMessage = "Ошибка загрузки"
        
        // When
        presenter.didFailLoadingTasks(with: errorMessage)
        
        // Then
        XCTAssertTrue(view.didShowError, "Ошибка должна быть показана во View")
        XCTAssertEqual(view.errorMessage, errorMessage)
    }
    
    func test_didSelectTask_shouldOpenEditor() {
        // Given
        let task = TaskModel(id: 1, title: "test", description: "desc", dateCreated: Date(), isCompleted: false, userId: 1)
        
        // When
        presenter.didSelectTask(task)
        
        // Then
        XCTAssertTrue(router.didOpenEditor, "didSelectTask должен открыть редактор задачи")
    }
}
