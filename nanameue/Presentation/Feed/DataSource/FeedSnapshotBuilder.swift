//
//  FeedSnapshotBuilder.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import UIKit

typealias FeedSnapshot = NSDiffableDataSourceSnapshot<Section, Cell>

protocol FeedSnapshotBuilder: AnyObject {
    func build(posts: [Post]) -> FeedSnapshot
}

final class FeedSnapshotBuilderImpl {}

// MARK: - FeedSnapshotBuilder
extension FeedSnapshotBuilderImpl: FeedSnapshotBuilder {
    
    func build(posts: [Post]) -> FeedSnapshot {
        let postCells = posts.map { post in Cell.post(post) }
        
        var snapshot = FeedSnapshot()
        snapshot.appendSections([.posts])
        snapshot.appendItems(postCells, toSection: .posts)
        
        return snapshot
    }
}
