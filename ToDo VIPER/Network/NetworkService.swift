//
//  NetworkService.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchTasks(completion: @escaping (Result<[NetworkTaskDTO], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchTasks(completion: @escaping (Result<[NetworkTaskDTO], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            }
            return
        }

        let request = URLRequest(url: url)

        session.dataTask(with: request) { data, response, error in
            assert(!Thread.isMainThread, " Загрузка и парсинг не должны быть на главном потоке!")
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
