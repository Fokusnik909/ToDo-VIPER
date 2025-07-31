//
//  TaskCell.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 01.08.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    static let reuseId = "TaskCell"

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()

    private let container = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with task: TaskModel) {
        descriptionLabel.text = task.description
        dateLabel.text = formatDate(task.dateCreated)

        let titleText = task.title

        if task.isCompleted {
            titleLabel.attributedText = NSAttributedString(
                string: titleText,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = titleText
            titleLabel.textColor = .label
        }
    }


    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        descriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textColor = .tertiaryLabel

        let vStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(vStack)
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
        ])
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
}
