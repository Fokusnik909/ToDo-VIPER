//
//  TasksListRouter.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import UIKit

protocol TasksListRouterProtocol: AnyObject {
    func openEditor(viewController: UIViewController)
}

import UIKit

final class TasksListRouter: TasksListRouterProtocol {
    weak var viewController: UIViewController?
    
    func openEditor(viewController: UIViewController) {
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

