//
//  PostViewModel.swift
//  nanameue
//
//  Created by Volnov Ivan on 12/02/2023.
//

import Foundation
import Combine

final class PostViewModel {
    
    struct Draft {
        let text: String
        let jpeg: Data?
    }
    
    // Dependencies
    private let imageService: ImageService
    private let postsService: PostsService
    private let userService: UserService
    
    let createPostSubject: CurrentValueSubject<Draft?, Never> = .init(nil)
    
    @Published var dismiss = false
    @Published var loading = false
    
    private var bag: Set<AnyCancellable> = []
    
    init(
        imageService: ImageService = FirebaseImageService(),
        postsService: PostsService = FirebasePostsService(),
        userService: UserService = UserServiceImpl()
    ) {
        self.imageService = imageService
        self.postsService = postsService
        self.userService = userService
        
        bindCreatePost()
    }
}

// MARK: - Binding
private extension PostViewModel {
        
    func bindCreatePost() {
        
        createPostSubject
            .compactMap { post in post }
            .map { _ in true }
            .assign(to: &$loading)
        
        let user = userService
            .user()
            .onlySuccess()
        
        let post = createPostSubject
            .compactMap { post in post }
            .flatMap { post in self.imageService.upload(jpeg: post.jpeg) }
            .onlySuccess()
            .map { url in self.post(for: url) }
        
        Publishers
            .CombineLatest(post, user)
            .flatMap { post, user in self.postsService.create(post: post, for: user) }
            .onlySuccess()
            .map { true }
            .assign(to: &$dismiss)
    }
}

// MARK: - Private
private extension PostViewModel {
    func post(for url: URL?) -> Post {
        Post(
            id: UUID().uuidString,
            url: url?.absoluteString,
            text: createPostSubject.value?.text ?? "",
            created: Date()
        )
    }
}
