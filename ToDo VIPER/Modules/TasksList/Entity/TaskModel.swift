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
    let isCompleted: Bool
    let userId: Int64
}
