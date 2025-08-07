//
//  TaskEditorPresenter.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//

import Foundation

protocol TaskEditorPresenterProtocol: AnyObject {
    var onSave: (() -> Void)? { get set }
    func didTapBackButton(title: String, description: String)
    func viewDidLoad()
}

final class TaskEditorPresenter: TaskEditorPresenterProtocol {
    private let interactor: TaskEditorInteractorProtocol
    private let router: TaskEditorRouterProtocol
    private let mode: TaskEditorMode
    weak var view: TaskEditorViewProtocol?
    
    var onSave: (() -> Void)?
    
    private var titleText: String = ""
    private var descriptionText: String = ""
    
    init(interactor: TaskEditorInteractorProtocol, router: TaskEditorRouterProtocol, mode: TaskEditorMode) {
        self.interactor = interactor
        self.router = router
        self.mode = mode
    }
    
    func viewDidLoad() {
        switch mode {
        case .add:
            view?.editsFields(title: "", date: Date(), description: "")
        case .edit(let task):
            view?.editsFields(title: task.title, date: task.dateCreated, description: task.description ?? "")
        }
    }
    
    func didTapBackButton(title: String, description: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty || !trimmedDescription.isEmpty else {
            router.dismiss()
            return
        }
        
        switch mode {
        case .add:
            let newTask = TaskModel(
                id: interactor.generateID(),
                title: trimmedTitle,
                description: trimmedDescription,
                dateCreated: Date(),
                isCompleted: false,
                userId: 0
            )
            interactor.saveTask(newTask)
            
        case .edit(let existingTask):
            let updated = TaskModel(
                id: existingTask.id,
                title: trimmedTitle,
                description: trimmedDescription,
                dateCreated: existingTask.dateCreated,
                isCompleted: existingTask.isCompleted,
                userId: existingTask.userId
            )
            interactor.saveTask(updated)
        }
        
        onSave?()
        router.dismiss()
    }
    
    
}

