//
//  FeedDataSourceBuilder.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import UIKit

protocol FeedDataSourceBuilder: AnyObject {
    func build(with tableView: UITableView) -> UITableViewDiffableDataSource<Section, Cell>
}

final class FeedDataSourceBuilderImpl {}

// MARK: - FeedDataSourceBuilder
extension FeedDataSourceBuilderImpl: FeedDataSourceBuilder {
    
    func build(with tableView: UITableView) -> UITableViewDiffableDataSource<Section, Cell> {
        FeedDataSource(tableView: tableView)
    }
}
