//
//  PostsService.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Foundation
import Combine

protocol PostsService: AnyObject {
    func create(post: Post) -> AnyPublisher<Result<Void, Error>, Never>
    func delete(post: Post) -> AnyPublisher<Result<Void, Error>, Never>
    func posts() -> AnyPublisher<Result<[Post], Error>, Never>
}

final class PostsServiceImpl {
    
    // Constants
    private let url = URL(string: "https://example.com")!
    
    // Dependencies
    private let decoder: JSONDecoder
    private let session: URLSession
    
    
    init(
        session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
}

extension PostsServiceImpl: PostsService {
  
    func posts() -> AnyPublisher<Result<[Post], Error>, Never> {
        session
            .dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      200 ..< 300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Post].self, decoder: decoder)
            .map { posts in .success(posts)}
            .catch { error in Just(.failure(error)) }
            .eraseToAnyPublisher()
    }
    
    func create(post: Post) -> AnyPublisher<Result<Void, Error>, Never> {
        Just(.success(())).eraseToAnyPublisher()
    }
    
    func delete(post: Post) -> AnyPublisher<Result<Void, Error>, Never> {
        Just(.success(())).eraseToAnyPublisher()
    }
}
