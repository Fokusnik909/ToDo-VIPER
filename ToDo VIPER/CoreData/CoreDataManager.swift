//
//  CoreDataManager.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//
import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    //MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo_VIPER")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //MARK: - Save Context
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - ID генератор для локальных задач
    func generateLocalTaskID() -> Int64 {
        let base: Int64 = 100_000
        let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.predicate = NSPredicate(format: "id >= %d", base)
        request.fetchLimit = 1
        
        if let last = try? viewContext.fetch(request).first {
            return last.id + 1
        } else {
            return base
        }
    }
    
    //MARK: - CRUD
    
    func fetchTasks(completion: @escaping ([ToDoCoreData]) -> Void) {
        let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        do {
            let tasks = try viewContext.fetch(request)
            completion(tasks)
        } catch {
            print("Failed to fetch entities: \(error)")
        }
    }
    
    func addTask(from model: TaskModel) {
        let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", model.id)
        
        if let existing = try? viewContext.fetch(request).first {
            updateTask(existing, with: model)
        } else {
            let task = ToDoCoreData(context: viewContext)
            task.id = model.id
            task.title = model.title
            task.descriptionText = model.description
            task.isCompleted = model.isCompleted
            task.userid = model.userId
            task.dateCreated = model.dateCreated
        }
        
        saveContext()
    }
    
    func deleteTask(_ task: ToDoCoreData) {
        viewContext.delete(task)
        saveContext()
    }
    
    func updateTask(_ task: ToDoCoreData, with model: TaskModel) {
        task.title = model.title
        task.descriptionText = model.description
        task.isCompleted = model.isCompleted
        task.userid = model.userId
        saveContext()
    }
    
    func addTasks(_ models: [TaskModel]) {
        models.forEach { addTask(from: $0) }
    }

    
    func searchTasks(query: String, completion: @escaping ([ToDoCoreData]) -> Void) {
            let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            do {
                let results = try viewContext.fetch(request)
                completion(results)
            } catch {
                print("Search error: \(error)")
                completion([])
            }
        }
    
    func deleteAllTasks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoCoreData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(deleteRequest)
            saveContext()
            print(" Все задачи успешно удалены из Core Data")
        } catch {
            print(" Ошибка при удалении всех задач: \(error.localizedDescription)")
        }
    }

    
}
