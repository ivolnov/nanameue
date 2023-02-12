//
//  PostsService.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Foundation
import Combine

protocol PostsService: AnyObject {
    func create(post: Post, for user: User) -> AnyPublisher<Result<Void, Error>, Never>
    func delete(post: Post, for user: User) -> AnyPublisher<Result<Void, Error>, Never>
    func posts(for user: User) -> AnyPublisher<Result<[Post], Error>, Never>
}
