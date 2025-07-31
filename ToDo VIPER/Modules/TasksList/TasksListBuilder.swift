//
//  TasksListModuleBuilder.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import UIKit

enum TasksListModuleBuilder {
    static func build() -> UIViewController {
        let view = TasksListView()
        let router = TasksListRouter()
        let interactor = TasksListInteractor()
        let presenter = TasksListPresenter(view: view, interactor: interactor, router: router)

        view.presenter = presenter
        interactor.presenter = presenter
        router.viewController = view

        return view
    }
}
