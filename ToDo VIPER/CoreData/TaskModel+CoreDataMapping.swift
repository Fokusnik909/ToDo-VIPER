//
//  TaskModel+CoreDataMapping.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

import Foundation
import CoreData

extension TaskModel {
    func toCoreData(in context: NSManagedObjectContext) -> ToDoCoreData {
        let task = ToDoCoreData(context: context)
        task.id = self.id
        task.title = self.title
        task.descriptionText = self.description
        task.isCompleted = self.isCompleted
        task.userid = self.userId
        task.dateCreated = self.dateCreated
        return task
    }
}

