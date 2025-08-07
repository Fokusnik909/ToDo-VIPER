//
//  TaskEditorBuilder.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//

import UIKit

final class TaskEditorBuilder {
    static func build(with mode: TaskEditorMode, onSave: @escaping () -> Void) -> UIViewController {
        let view = TaskEditorView()
        let interactor = TaskEditorInteractor()
        let router = TaskEditorRouter(viewController: view)
        let presenter = TaskEditorPresenter(interactor: interactor, router: router, mode: mode)
        
        presenter.view = view
        presenter.onSave = onSave
        view.presenter = presenter
        
        return view
    }
}


