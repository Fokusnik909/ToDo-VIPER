//
//  NetworkTaskDTO.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

struct TasksResponseDTO: Decodable {
    let todos: [NetworkTaskDTO]
}

struct NetworkTaskDTO: Decodable {
    let id: Int64
    let todo: String
    let completed: Bool
    let userId: Int64
}
