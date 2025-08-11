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
    
    // MARK: - Persistent Container
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo_VIPER")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    internal func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
    
    internal func saveContext() {
        save(viewContext)
    }
    
    // MARK: - ID генератор
    func generateLocalTaskID() -> Int64 {
        let base: Int64 = 100_000
        let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.predicate = NSPredicate(format: "id >= %d", base)
        request.fetchLimit = 1
        
        do {
            if let last = try viewContext.fetch(request).first {
                return last.id + 1
            }
        } catch {
            print("Error generating ID: \(error)")
        }
        return base
    }
    
    // MARK: - CRUD
    
    func fetchTasks(completion: @escaping ([ToDoCoreData]) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            assert(!Thread.isMainThread, " fetchTasks: выполняется на главном потоке!")
            
            let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
            do {
                let tasks = try context.fetch(request)
                DispatchQueue.main.async {
                    completion(tasks)
                }
            } catch {
                print("Failed to fetch tasks: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func searchTasks(query: String, completion: @escaping ([ToDoCoreData]) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
            
            if !query.isEmpty {
                request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
            }
            
            do {
                let results = try self.viewContext.fetch(request)
                completion(results)
            } catch {
                print("Search error: \(error)")
                completion([])
            }
        }
    }
    
    func addTask(from model: TaskModel) {
        let context = newBackgroundContext()
        context.perform {
            self._addOrUpdate(model, in: context)
            self.save(context)
        }
    }
    
    func addTasks(_ models: [TaskModel]) {
        let context = newBackgroundContext()
        context.perform {
            assert(!Thread.isMainThread, "addTasks: выполняется на главном потоке!")
            models.forEach { self._addOrUpdate($0, in: context) }
            self.save(context)
        }
    }
    
    func toggleCompleted(objectID: NSManagedObjectID) {
        let context = newBackgroundContext()
        context.perform {
            do {
                if let obj = try? context.existingObject(with: objectID) as? ToDoCoreData {
                    obj.isCompleted.toggle()
                    try context.save()
                }
            } catch {
                print("toggleCompleted error: \(error)")
            }
        }
    }
    
    func deleteTask(with objectID: NSManagedObjectID) {
        let context = newBackgroundContext()
        context.perform {
            do {
                let obj = try context.existingObject(with: objectID)
                context.delete(obj)
                try context.save()
                print("Task deleted")
            } catch {
                print("Delete save error: \(error)")
            }
        }
    }
    
    
    func deleteAllTasks() {
        let context = newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoCoreData.fetchRequest()
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                    
                    let viewCtx = self.viewContext
                    viewCtx.perform {
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewCtx])
                    }
                }
                
                try context.save()
                print("Все задачи удалены ")
            } catch {
                print("Ошибка удаления: \(error)")
            }
        }
    }
    
    //MARK: - Private method
    private func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    private func _addOrUpdate(_ model: TaskModel, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<ToDoCoreData> = ToDoCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", model.id)
        
        if let existing = try? context.fetch(request).first {
            existing.title = model.title
            existing.descriptionText = model.description
            existing.isCompleted = model.isCompleted
            print("Обновляем задачу с id \(model.id)")
        } else {
            let task = ToDoCoreData(context: context)
            task.id = model.id
            task.title = model.title
            task.descriptionText = model.description
            task.isCompleted = model.isCompleted
            task.userid = model.userId
            task.dateCreated = model.dateCreated
            print("Создаём новую задачу с id \(model.id)")
        }
    }
}

