//
//  FeedViewModel.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Combine

final class FeedViewModel {
    
    // Dependencies
    private let snapshotBuilder: FeedSnapshotBuilder
    private let postsService: PostsService
    
    @Published var snapshot: FeedSnapshot?
    @Published var loading = true
    
    init(snapshotBuilder: FeedSnapshotBuilder = FeedSnapshotBuilderImpl(),
         postsService: PostsService = PostsServiceMock()) {
        
        self.snapshotBuilder = snapshotBuilder
        self.postsService = postsService
        
        postsService
            .posts()
            .map { posts in self.snapshotBuilder.build(posts: posts) }
            .replaceError(with: nil)
            .assign(to: &$snapshot)
        
        $snapshot
            .map { $0 == nil }
            .assign(to: &$loading)
    }
}
