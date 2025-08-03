//
//  TaskCell.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    static let reuseId = "TaskCell"

    private var currentTask: TaskModel?
    var onToggleCompletion: ((TaskModel) -> Void)?

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 12)
        label.textColor = .grayTextTD
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        backgroundColor = .clear
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with task: TaskModel) {
        currentTask = task

        let image = task.isCompleted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        checkboxButton.setImage(image, for: .normal)
        checkboxButton.tintColor = task.isCompleted ? .yellow : .grayTextTD

        
        if task.isCompleted {
            let attributed = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.grayTextTD
                ]
            )
            titleLabel.attributedText = attributed
            descriptionLabel.textColor = .grayTextTD
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = task.title
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
        }

        descriptionLabel.text = task.description
        dateLabel.text = formatDate(task.dateCreated)
    }

    //MARK: - Private methods
    @objc private func checkboxTapped() {
        guard let task = currentTask else { return }
        onToggleCompletion?(task)
    }
    
    //MARK: - Layout
    private func setupLayout() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
