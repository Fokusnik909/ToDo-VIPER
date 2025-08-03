//
//  TaskEditorViewController.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//
import UIKit

protocol TaskEditorViewProtocol: AnyObject {
    func editsFields(title: String, date: Date, description: String)
}

final class TaskEditorView: UIViewController, TaskEditorViewProtocol {
    var presenter: TaskEditorPresenterProtocol!
    
    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите заголовок"
        tf.font = .systemFont(ofSize: 34, weight: .bold)
        tf.textColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .blackTD
        return tf
    }()
    
    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .grayTextTD
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let descriptionView: UITextView = {
        let des = UITextView()
        des.font = .systemFont(ofSize: 16)
        des.textColor = .white
        des.backgroundColor = .blackTD
        des.translatesAutoresizingMaskIntoConstraints = false
        return des
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            presenter.didTapBackButton(
                title: titleField.text ?? "",
                description: descriptionView.text ?? ""
            )
        }
    }
    
    func editsFields(title: String, date: Date, description: String) {
        titleField.text = title
        dateLabel.text = date.formattedShort()
        descriptionView.text = description
    }
    
    private func setupUI() {
        view.backgroundColor = .blackTD
        
        view.addSubview(titleField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionView)
        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleField.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            
            descriptionView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            descriptionView.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            descriptionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

