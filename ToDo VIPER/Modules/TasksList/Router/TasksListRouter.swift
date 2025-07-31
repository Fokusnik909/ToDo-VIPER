//
//  TasksListRouter.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import UIKit

protocol TasksListRouterProtocol: AnyObject {
    func navigateToAddTask()
    func navigateToTaskDetails(_ task: TaskModel)
}

import UIKit

final class TasksListRouter: TasksListRouterProtocol {
    weak var viewController: UIViewController?

    func navigateToAddTask() {

    }

    func navigateToTaskDetails(_ task: TaskModel) {

    }
}

