//
//  TaskListView.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 31.07.2025.
//
import UIKit

protocol TasksListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TaskModel])
    func showError(_ message: String)
//    func removeTask(at indexPath: IndexPath)
}

final class TasksListView: UIViewController, TasksListViewProtocol {
    var presenter: TasksListPresenterProtocol!

    private var taskStore: TaskManagerProtocol!

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let footerView = TasksFooterView()
    private let footerInsetView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        taskStore = DataProvider(context: CoreDataManager.shared.viewContext, delegate: self)
        setupUI()
        presenter.viewDidLoad()
    }
    
    
    func showTasks(_ tasks: [TaskModel]) {
        footerView.updateCount(tasks.count)
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    //MARK: - Private Methods
    
    @objc private func addTapped() {
        print("addTapped")
        presenter.didTapAddTask()
    }
    
    private func setupUI() {
        view.backgroundColor = .blackTD
        setupNavigationController()
        customizeSearchBar()
        setupTableView()
        
        view.addSubview(tableView)
        view.addSubview(footerView)
        view.addSubview(footerInsetView)

        footerInsetView.backgroundColor = .grayTD
        footerInsetView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.updateCount(taskStore.numberOfTasks)
        footerView.addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        // Layout
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: footerInsetView.topAnchor),

            //TO DO: fix footer
            footerInsetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerInsetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerInsetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerInsetView.heightAnchor.constraint(equalToConstant: view.safeAreaInsets.bottom > 0 ? view.safeAreaInsets.bottom : 34)
        ])
    }

    private func setupNavigationController() {
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .inline
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.backButtonTitle = "Назад"
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseId)
        tableView.backgroundColor = .blackTD
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func customizeSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        let searchField = searchController.searchBar.searchTextField
        searchField.backgroundColor = .grayTD
        searchField.textColor = .whiteTD
        searchField.tintColor = .yellowTD
        searchField.leftView?.tintColor = .opacityWhiteTD
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.opacityWhiteTD]
        )
    }
    
}

//MARK: - UITableViewDataSource
extension TasksListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskStore.numberOfTasks
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let task = taskStore?.task(at: indexPath) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as! TaskCell
        cell.configure(with: task)
        cell.onToggleCompletion = { [weak self] updatedTask in
            self?.presenter.didToggleTaskCompletion(updatedTask)
        }
        return cell 
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            taskStore.deleteTask(at: indexPath)
        }
    }
    
}


//MARK: - UITableViewDelegate
extension TasksListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskStore.task(at: indexPath)
        presenter.didSelectTask(task)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
        
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = taskStore.task(at: indexPath)

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil, actionProvider: { _ in
            return self.makeContextMenu(for: task, indexPath: indexPath)
        })
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = tableView.cellForRow(at: indexPath) as? TaskCell else {
            return nil
        }
        
        let task = taskStore.task(at: indexPath)
        cell.configure(with: task, forPreview: true)

        let param = UIPreviewParameters()
        param.visiblePath = UIBezierPath(roundedRect: cell.getContainerViewBounds(), cornerRadius: 16)

        return UITargetedPreview(view: cell, parameters: param)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = tableView.cellForRow(at: indexPath) as? TaskCell else {
            return nil
        }
        
        let task = taskStore.task(at: indexPath)
        cell.configure(with: task, forPreview: false)
        

        return UITargetedPreview(view: cell)
    }
    
    private func makeContextMenu(for task: TaskModel, indexPath: IndexPath) -> UIMenu {
        let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
            self.presenter.didSelectTask(task)
        }
        
        let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
            let vc = UIActivityViewController(
                activityItems: [task.title,
                                task.description ?? "" ], applicationActivities: nil)
            self?.present(vc, animated: true)
        }
        
        let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            taskStore.deleteTask(at: indexPath)
        }
        
        return UIMenu(title: "", children: [edit, share, delete])
    }
    
}

extension TasksListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        taskStore.searchTasks(with: searchController.searchBar.text ?? "")
    }
}

extension TasksListView: DataProviderDelegate {
    func didUpdate(_ update: TaskStoreUpdate) {
        let section = 0
        
        if update.insertedIndexes.isEmpty &&
            update.updatedIndexes.isEmpty &&
            update.deletedIndexes.isEmpty {
            tableView.reloadData()
        } else {
            let safeUpdatedIndexes = update.updatedIndexes.subtracting(update.deletedIndexes)
            
            tableView.performBatchUpdates {
                tableView.deleteRows(at: update.deletedIndexes.map { IndexPath(row: $0, section: section) }, with: .fade)
                tableView.insertRows(at: update.insertedIndexes.map { IndexPath(row: $0, section: section) }, with: .fade)
                tableView.reloadRows(at: safeUpdatedIndexes.map { IndexPath(row: $0, section: section) }, with: .fade)
            }
        }
        footerView.updateCount(taskStore.numberOfTasks)
    }
    
}
