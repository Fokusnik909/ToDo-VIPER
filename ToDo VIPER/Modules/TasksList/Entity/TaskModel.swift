//
//  TaskModel.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//

import Foundation

struct TaskModel {
    let id: Int64
    let title: String
    let description: String?
    let dateCreated: Date
    var isCompleted: Bool
    let userId: Int64
}

extension TaskModel {
    init(from coreData: ToDoCoreData) {
        self.id = coreData.id
        self.title = coreData.title ?? ""
        self.description = coreData.descriptionText ?? ""
        self.isCompleted = coreData.isCompleted
        self.userId = coreData.userid
        self.dateCreated = coreData.dateCreated ?? Date()
    }
}
