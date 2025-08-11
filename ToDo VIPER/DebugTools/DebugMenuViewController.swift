//
//  DebugMenuViewController.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 11.08.2025.
//

#if DEBUG
import UIKit

final class DebugMenuViewController: UIViewController {

    private let core = CoreDataManager.shared

    private let countField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Count (e.g. 1000)"
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.text = "1000"
        return tf
    }()

    private let seedButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Fill (N)", for: .normal)
        return b
    }()

    private let wipeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Wipe", for: .normal)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Debug Menu"

        let stack = UIStackView(arrangedSubviews: [countField, seedButton, wipeButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        seedButton.addTarget(self, action: #selector(seed), for: .touchUpInside)
        wipeButton.addTarget(self, action: #selector(wipe), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func seed() {
        view.endEditing(true)
        let n = Int(countField.text ?? "") ?? 1000
        DebugTasksSeeder.seed(count: n, core: core)
        closeSelf()
    }

    @objc private func wipe() {
        view.endEditing(true)
        DebugTasksSeeder.wipe(core: core)
        closeSelf()
    }

    // MARK: - Helpers
    private func closeSelf() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else if navigationController != nil {
            navigationController?.popViewController(animated: true)
        }
    }
}
#endif
