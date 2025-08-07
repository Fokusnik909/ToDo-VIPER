//
//  DataProvider.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 07.08.2025.
//
import Foundation
import CoreData

struct TaskStoreUpdate {
    let insertedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TaskStoreUpdate)
}

protocol TaskManagerProtocol {
    var numberOfTasks: Int { get }
    func task(at indexPath: IndexPath) -> TaskModel
    func searchTasks(with query: String)
    func deleteTask(at indexPath: IndexPath)
}

final class DataProvider: NSObject {
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: CoreDataManager
    
    private var insertedIndexes: IndexSet = []
    private var updatedIndexes: IndexSet = []
    private var deletedIndexes: IndexSet = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ToDoCoreData> = {
        let fetchRequest = NSFetchRequest<ToDoCoreData>(entityName: "ToDoCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print("Initial fetch successful, count:", fetchedResultsController.fetchedObjects?.count ?? 0)
        } catch {
            print("Ошибка при загрузке задач: \(error)")
        }
        
        
        return fetchedResultsController
    }()
    
    init(dataStore: CoreDataManager = .shared, delegate: DataProviderDelegate? = nil) {
        self.dataStore = dataStore
        self.context = dataStore.viewContext
        self.delegate = delegate
        super.init()
        
        print("DataProvider инициализирован на главном потоке: \(Thread.isMainThread)")
        print("Тип контекста: \(context.concurrencyType == .mainQueueConcurrencyType ? "mainQueue" : "privateQueue")")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func contextDidSave(_ notification: Notification) {
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
}

extension DataProvider: TaskManagerProtocol {
    var numberOfTasks: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func task(at indexPath: IndexPath) -> TaskModel {
        let cdTask = fetchedResultsController.object(at: indexPath)
        return TaskModel(from: cdTask)
    }
    
    func searchTasks(with query: String) {
        let fetchRequest = NSFetchRequest<ToDoCoreData>(entityName: "ToDoCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: true)]

        if !query.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        }

        fetchedResultsController.delegate = nil
        let newFRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: context,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
        newFRC.delegate = self
        fetchedResultsController = newFRC

        do {
            try fetchedResultsController.performFetch()
            delegate?.didUpdate(TaskStoreUpdate(insertedIndexes: [], updatedIndexes: [], deletedIndexes: []))
        } catch {
            print("Search fetch failed: \(error)")
        }
    }
    
    func deleteTask(at indexPath: IndexPath) {
        context.perform {
            let task = self.fetchedResultsController.object(at: indexPath)
            self.context.delete(task)
            
            do {
                try self.context.save()
            } catch {
                print("Delete save error: \(error)")
            }
        }
    }

    
}


extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        updatedIndexes = []
        deletedIndexes = []
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TaskStoreUpdate(
            insertedIndexes: insertedIndexes,
            updatedIndexes: updatedIndexes,
            deletedIndexes: deletedIndexes
        )

        let isFullReload = deletedIndexes.isEmpty && updatedIndexes.isEmpty && !insertedIndexes.isEmpty
        
        DispatchQueue.main.async {
            assert(Thread.isMainThread, "controllerDidChangeContent: обновление UI не на главном потоке!")
            self.delegate?.didUpdate(
                isFullReload
                ? TaskStoreUpdate(insertedIndexes: [], updatedIndexes: [], deletedIndexes: [])
                : update
            )
        }
    }

    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath.item)
            }
        case .move:
            if let from = indexPath, let to = newIndexPath {
                deletedIndexes.insert(from.item)
                insertedIndexes.insert(to.item)
            }
        case.update:
            if let indexPath = indexPath {
                updatedIndexes.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
