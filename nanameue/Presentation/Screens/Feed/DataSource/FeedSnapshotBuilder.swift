//
//  FeedSnapshotBuilder.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Combine
import UIKit

typealias FeedSnapshot = NSDiffableDataSourceSnapshot<Section, Cell>

protocol FeedSnapshotBuilder: AnyObject {
    func build(
        posts: [Post],
        with deleteSubject: PassthroughSubject<Post, Never>
    ) -> FeedSnapshot
}

final class FeedSnapshotBuilderImpl {}

// MARK: - FeedSnapshotBuilder
extension FeedSnapshotBuilderImpl: FeedSnapshotBuilder {
    
    func build(
        posts: [Post],
        with deleteSubject: PassthroughSubject<Post, Never>
    ) -> FeedSnapshot {
        
        let postCells: [Cell] = posts
            .map { post in .post(PostCellViewModel(deleteSubject: deleteSubject, post: post)) }
        
        var snapshot = FeedSnapshot()
        snapshot.appendSections([.posts])
        snapshot.appendItems(postCells, toSection: .posts)
        
        return snapshot
    }
}
