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
    
    private var bag: Set<AnyCancellable> = []
    
    init(
        snapshotBuilder: FeedSnapshotBuilder = FeedSnapshotBuilderImpl(),
        imageService: ImageService = FirebaseImageService(),
        postsService: PostsService = FirebasePostsService(),
        userService: UserService = UserServiceImpl()
    ) {
        self.snapshotBuilder = snapshotBuilder
        self.imageService = imageService
        self.postsService = postsService
        self.userService = userService
        
        signIn()
        bindPosts()
        bindCreatePost()
        bindDeletePost()
    }
}

// MARK: - Binding
private extension FeedViewModel {
    
    func bindPosts() {
        
        loadPostsSubject
            .map { true }
            .assign(to: &$loading)
        
        loadPostsSubject
            .flatMap { self.userService.user() }
            .onlySuccess()
            .flatMap { user in self.postsService.posts(for: user) }
            .onlySuccess()
            .map { posts in self.snapshotBuilder.build(posts: posts, with: self.deletePostSubject) }
            .assign(to: &$snapshot)
        
        $snapshot
            .map { $0 == nil }
            .assign(to: &$loading)
    }
    
    func bindCreatePost() {
        
        createPostSubject
            .map { _ in true }
            .assign(to: &$loading)
        
        let user = userService
            .user()
            .onlySuccess()
        
        let post = createPostSubject
            .compactMap { post in post.jpeg }
            .flatMap { jpeg in self.imageService.upload(jpeg: jpeg) }
            .onlySuccess()
            .map { url in
                Post(
                    id: UUID().uuidString,
                    url: url.absoluteString,
                    text: "This is a test for post creation",
                    created: Date()
                )
            }
        
        Publishers
            .CombineLatest(post, user)
            .flatMap { post, user in self.postsService.create(post: post, for: user) }
            .onlySuccess()
            .sink {
                self.loadPostsSubject.send()
                self.loading = false
            }
            .store(in: &bag)
    }
    
    func bindDeletePost() {
        
        deletePostSubject
            .map { _ in true }
            .assign(to: &$loading)
        
        let user = userService
            .user()
            .onlySuccess()
        
        Publishers
            .CombineLatest(deletePostSubject, user)
            .flatMap { post, user in self.postsService.delete(post: post, for: user) }
            .onlySuccess()
            .sink {
                self.loadPostsSubject.send()
                self.loading = false
            }
            .store(in: &bag)
    }
}

// MARK: - auth
private extension FeedViewModel {
    func signIn() {
        userService.signIn() // TODO: combine with posts()
    }
}
