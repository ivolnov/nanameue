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
    
    let deletePostSubject: PassthroughSubject<Post, Never> = .init()
    let loadPostsSubject: PassthroughSubject<Void, Never> = .init()
    let signOutSubject: PassthroughSubject<Void, Never> = .init()
    
    @Published var snapshot: FeedSnapshot?
    @Published var showSignIn = false
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
        
        bindAuth()
        bindPosts()
        bindDeletePost()
    }
}

// MARK: - Binding
private extension FeedViewModel {
    
    func bindAuth() {
        signOutSubject
            .map { self.userService.signOut() }
            .map { true }
            .assign(to: &$showSignIn)
        
        loadPostsSubject
            .flatMap { self.userService.user() }
            .map { result in
                switch result {
                case .success:
                    return false
                case .failure:
                    return true
                }
            }
            .assign(to: &$showSignIn)
    }
    
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
    
    func bindDeletePost() {
        
        deletePostSubject
            .map { _ in true }
            .assign(to: &$loading)
        
        let image = deletePostSubject
            .flatMap { post in self.imageService.delete(image: post.url) }
            .onlySuccess()
        
        let user = userService
            .user()
            .onlySuccess()
        
        Publishers
            .CombineLatest3(deletePostSubject, image, user)
            .flatMap { post, image, user in self.postsService.delete(post: post, for: user) }
            .onlySuccess()
            .sink { self.loadPostsSubject.send() }
            .store(in: &bag)
    }
}
