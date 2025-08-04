//
//  Untitled.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

import Foundation
//"https://dummyjson.com/todos"
protocol NetworkServiceProtocol {
    func fetchTasks(completion: @escaping (Result<[NetworkTaskDTO], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    func fetchTasks(completion: @escaping (Result<[NetworkTaskDTO], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos222") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }

        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(TasksResponseDTO.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded.todos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}
