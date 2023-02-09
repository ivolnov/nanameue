//
//  FeedDataSource.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import UIKit

final class FeedDataSource: UITableViewDiffableDataSource<Section, Cell> {
    
    init(tableView: UITableView) {
        
        super.init(tableView: tableView) { tableView, indexPath, cell in
            
            switch cell {
                
            case let .post(model):
                
                guard let cellView = tableView.dequeueReusableCell(
                    withIdentifier: PostCell.reuseIdentifier,
                    for: indexPath) as? PostCell
                else {
                    return nil
                }
                
                cellView.selectionStyle = .none
                cellView.configure(with: model)
                
                return cellView
            }
        }
    }
}
