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
    private var isPreviewMode = false
    
    private var titleLeadingWithCheckbox: NSLayoutConstraint!
    private var titleLeadingWithoutCheckbox: NSLayoutConstraint!
    
    var onToggleCompletion: ((TaskModel) -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .whiteTD
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .opacityWhiteTD
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        backgroundColor = .blackTD
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Methods
    func configure(with task: TaskModel, forPreview: Bool = false) {
        currentTask = task
        isPreviewMode = forPreview
        
        checkboxButton.isHidden = forPreview
        titleLeadingWithCheckbox.isActive = !forPreview
        titleLeadingWithoutCheckbox.isActive = forPreview
        
        containerView.backgroundColor = forPreview ? .grayTD : .blackTD
        titleLabel.textColor = .whiteTD
        descriptionLabel.textColor = .whiteTD
        dateLabel.textColor = .opacityWhiteTD
        
        if task.isCompleted {
            let attributed = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: forPreview ? UIColor.whiteTD : UIColor.opacityWhiteTD
                ]
            )
            titleLabel.attributedText = attributed
            descriptionLabel.textColor = forPreview ? .whiteTD : .opacityWhiteTD
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = task.title
            descriptionLabel.textColor = .whiteTD
        }
        
        descriptionLabel.text = task.description
        dateLabel.text = task.dateCreated.formattedShort()
        
        if !forPreview {
            let image = task.isCompleted ? UIImage(named: "Check") : UIImage(named: "circle")
            checkboxButton.setImage(image, for: .normal)
            checkboxButton.tintColor = task.isCompleted ? UIColor.yellowTD : .grayCircle
        }
    }
    
    
    func getContainerViewBounds() -> CGRect {
        return containerView.bounds
    }
    
    //MARK: - Private Methods
    @objc private func checkboxTapped() {
        guard let task = currentTask else { return }
        onToggleCompletion?(task)
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        
        titleLeadingWithCheckbox = titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8)
        titleLeadingWithoutCheckbox = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
