//
//  TaskEditorRouter.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//

import UIKit

protocol TaskEditorRouterProtocol: AnyObject {
    func dismiss()
}

final class TaskEditorRouter: TaskEditorRouterProtocol {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
