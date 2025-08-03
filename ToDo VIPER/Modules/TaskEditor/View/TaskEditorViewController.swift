//
//  TaskEditorViewController.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//
import UIKit

protocol TaskEditorViewProtocol: AnyObject {
    func editsFields(title: String, description: String)
}

final class TaskEditorView: UIViewController, TaskEditorViewProtocol {
    var presenter: TaskEditorPresenterProtocol!

    private let titleField: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Введите заголовок"
            tf.font = .systemFont(ofSize: 18, weight: .medium)
            tf.borderStyle = .roundedRect
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()

        private let descriptionView: UITextView = {
            let des = UITextView()
            des.font = .systemFont(ofSize: 16)
            des.layer.borderColor = UIColor.systemGray4.cgColor
            des.layer.borderWidth = 1
            des.layer.cornerRadius = 8
            des.translatesAutoresizingMaskIntoConstraints = false
            return des
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
    
    func editsFields(title: String, description: String) {
        titleField.text = title
        descriptionView.text = description
    }
    
    private func setupUI() {
        view.backgroundColor = .blackTD
        
        view.addSubview(titleField)
        view.addSubview(descriptionView)
        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            descriptionView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            descriptionView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            descriptionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

