//
//  FeedViewModel.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Foundation
import Combine

final class FeedViewModel {
    
    // Dependencies
    private let snapshotBuilder: FeedSnapshotBuilder
    private let imageService: ImageService
    private let postsService: PostsService
    private let userService: UserService
    
    let createPostSubject: PassthroughSubject<PostDraft, Never> = .init()
    let deletePostSubject: PassthroughSubject<Post, Never> = .init()
    let loadPostsSubject: PassthroughSubject<Void, Never> = .init()
    
    @Published var snapshot: FeedSnapshot?
    @Published var loading = true
    
    init(
        snapshotBuilder: FeedSnapshotBuilder = FeedSnapshotBuilderImpl(),
        imageService: ImageService = ImageServiceImpl(),
        postsService: PostsService = PostsServiceMock(),
        userService: UserService = UserServiceImpl()
    ) {
        self.snapshotBuilder = snapshotBuilder
        self.imageService = imageService
        self.postsService = postsService
        self.userService = userService
        
        signIn()
        bindPosts()
        bindCreatePost()
    }
}

// MARK: - Binding
private extension FeedViewModel {
    
    func bindPosts() {
        loadPostsSubject
            .flatMap { self.postsService.posts() }
            .compactMap { result in
                switch result {
                case .success(let posts):
                    return posts
                case .failure:
                    return nil
                }
            }
            .map { posts in self.snapshotBuilder.build(posts: posts) }
            .assign(to: &$snapshot)
        
        $snapshot
            .map { $0 == nil }
            .assign(to: &$loading)
    }
    
    func bindCreatePost() {
        createPostSubject
            .compactMap { post in post.jpeg }
            .flatMap { jpeg in self.imageService.upload(jpeg: jpeg) }
            .map { result in
                switch result {
                case .success(let url):
                    print(url)
                case .failure(let error):
                    print(error)
                }
                return false
            }
            .assign(to: &$loading)
    }
}

// MARK: - auth
private extension FeedViewModel {
    func signIn() {
        userService.signIn()
    }
}
