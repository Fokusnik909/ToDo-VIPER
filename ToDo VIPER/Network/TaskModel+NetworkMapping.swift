//
//  TaskModel+NetworkMapping.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

import Foundation


extension TaskModel {
    init(from dto: NetworkTaskDTO) {
        self.init(
            id: dto.id,
            title: "Task \(dto.id)",
            description: dto.todo,
            dateCreated: Date(),
            isCompleted: dto.completed,
            userId: dto.userId
        )
    }
}
