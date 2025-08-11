//
//  TaskModel+Mapping.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 11.08.2025.
//
import CoreData

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
