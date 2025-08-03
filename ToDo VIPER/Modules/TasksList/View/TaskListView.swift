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
}

final class TasksListView: UIViewController, TasksListViewProtocol {
    var presenter: TasksListPresenterProtocol!

    private var tasks: [TaskModel] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    private let footerView = TasksFooterView()
    private let footerInsetView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        title = "Задачи"
        view.backgroundColor = .blackTD

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseId)
        tableView.backgroundColor = .blackTD
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(footerView)
        view.addSubview(footerInsetView)

        footerInsetView.backgroundColor = .grayTD
        footerInsetView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
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


        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }



    @objc private func addTapped() {
        print("addTapped")
        presenter.didTapAddTask()
    }
    
    func showTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        tableView.reloadData()
        
        footerView.updateCount(tasks.count)
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }


}

extension TasksListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as! TaskCell
        
        cell.configure(with: task)
        cell.onToggleCompletion = { [weak self] updatedTask in
            self?.presenter.didToggleTaskCompletion(updatedTask)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectTask(tasks[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension TasksListView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter.didSearch(query: searchController.searchBar.text ?? "")
    }
}

