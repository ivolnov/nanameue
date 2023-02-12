//
//  PostCell.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import UIKit
import Kingfisher

fileprivate extension CGFloat {
    static let imageHeight: CGFloat = 200
    static let buttonHeight: CGFloat = 16
    static let buttonWidth: CGFloat = 14
}

final class PostCell: UITableViewCell {
    
    static let reuseIdentifier = "PostCell"
    
    private lazy var date: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let image = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .tertiaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        return button
    }()
    
    private lazy var text: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = .radius.small
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private var viewModel: PostCellViewModel?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
    }
   
    func set(viewModel: PostCellViewModel) {
        self.viewModel = viewModel
        updateData()
    }
}

// MARK: - Private
private extension PostCell {
    
    private func updateData() {
        if let url = viewModel?.post.url { image.kf.setImage(with: URL(string: url)) }
        date.text = viewModel?.post.created.timeAgoDisplay()
        text.text = viewModel?.post.text
    }
    
    private func setUp() {

        contentView.addSubview(deleteButton)
        contentView.addSubview(image)
        contentView.addSubview(date)
        contentView.addSubview(text)
        
        NSLayoutConstraint.activate([
            
            date.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .margin.small),
            date.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .margin.medium),
            
            deleteButton.centerYAnchor.constraint(equalTo: date.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.margin.medium),
            deleteButton.heightAnchor.constraint(equalToConstant: .buttonHeight),
            deleteButton.widthAnchor.constraint(equalToConstant: .buttonWidth),
            
            image.heightAnchor.constraint(equalToConstant: .imageHeight),
            image.topAnchor.constraint(equalTo: date.bottomAnchor, constant: .margin.small),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .margin.medium),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.margin.medium),
                        
            text.topAnchor.constraint(equalTo: image.bottomAnchor, constant: .margin.medium),
            text.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .margin.medium),
            text.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.margin.small),
            text.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.margin.small),
            
        ])
    }
    
    @objc func didTapDelete() {
        guard let viewModel = viewModel else { return }
        viewModel.deleteSubject.send(viewModel.post)
    }
}
