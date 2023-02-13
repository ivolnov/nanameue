//
//  PostsServiceMock.swift
//  nanameue
//
//  Created by Volnov Ivan on 09/02/2023.
//

@testable import nanameue
import Foundation
import Combine


final class PostsServiceMock: PostsService {
    func posts(for user: User) -> AnyPublisher<Result<[Post], Error>, Never> {
        let postsMock = [
            Post(
                id: "0",
                url: "https://picsum.photos/id/228/500/300",
                text: "",
                created: Date()
            ),
            Post(
                id: "1",
                url: nil,
                text: "Lorem ipsum dolor sit amet, amet liber in pro. Errem doctus iuvaret sit ei, lorem percipitur dissentias id ius. Ius laudem lobortis in. Pro at tale indoctum voluptatibus, eos et debet nonumes dissentias. Partem legendos perpetua sit te.",
                created: Date()
            ),
            Post(
                id: "2",
                url: "https://picsum.photos/id/143/500/500",
                text: "Lorem ipsum dolor sit amet, amet liber in pro.",
                created: Date()
            ),
            Post(
                id: "3",
                url: "https://picsum.photos/id/341/500/300",
                text: "",
                created: Date()
            ),
            Post(
                id: "4",
                url: "https://picsum.photos/id/824/300/500",
                text: "Lorem ipsum dolor sit amet, amet liber in pro. Errem doctus iuvaret sit ei, lorem percipitur dissentias id ius. Ius laudem lobortis in. Pro at tale indoctum voluptatibus, eos et debet nonumes dissentias. Partem legendos perpetua sit te.",
                created: Date()
            ),
            Post(
                id: "5",
                url: "https://picsum.photos/id/234/500/500",
                text: "Lorem ipsum dolor sit amet, amet liber in pro.",
                created: Date()
            )
        ]
        return Just(.success(postsMock)).eraseToAnyPublisher()
    }
    
    func create(post: Post, for user: User) -> AnyPublisher<Result<Void, Error>, Never> {
        Just(.success(())).eraseToAnyPublisher()
    }
    
    var deletePostWasCalled = false
    func delete(post: Post, for user: User) -> AnyPublisher<Result<Void, Error>, Never> {
        Just(.success(()))
            .handleEvents(
                receiveOutput: { _ in  self.deletePostWasCalled = true  }
            )
            .eraseToAnyPublisher()
    }
}
