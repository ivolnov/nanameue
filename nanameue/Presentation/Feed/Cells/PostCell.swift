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
}

final class PostCell: UITableViewCell {
    
    static let reuseIdentifier = "PostCell"
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }

    func configure(with model: Post) {
        text.text = model.text
        image.kf.setImage(with: URL(string: model.url))
    }
    
    private func setUp() {

        addSubview(image)
        addSubview(text)
        
        NSLayoutConstraint.activate([
            
            image.heightAnchor.constraint(equalToConstant: .imageHeight),
            image.topAnchor.constraint(equalTo: self.topAnchor, constant: .margin.small),
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: .margin.medium),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -.margin.medium),
                        
            text.topAnchor.constraint(equalTo: image.bottomAnchor, constant: .margin.medium),
            text.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: .margin.medium),
            text.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -.margin.small),
            text.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -.margin.small),
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
