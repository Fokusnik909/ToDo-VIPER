//
//  TaskEditorInteractor.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//

import Foundation

protocol TaskEditorInteractorProtocol: AnyObject {
    func saveTask(_ task: TaskModel)
    func generateID() -> Int64
}

final class TaskEditorInteractor: TaskEditorInteractorProtocol {
    private let coreDataManager = CoreDataManager.shared

    func saveTask(_ task: TaskModel) {
        coreDataManager.addTask(from: task)
    }
    
    func generateID() -> Int64 {
        coreDataManager.generateLocalTaskID()
    }
}

