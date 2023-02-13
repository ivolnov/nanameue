//
//  ImageServiceMock.swift
//  nanameueTests
//
//  Created by Volnov Ivan on 13/02/2023.
//

@testable import nanameue
import Foundation
import Combine


final class ImageServiceMock: ImageService {
    
    func upload(jpeg: Data?) -> AnyPublisher<Result<URL?, Error>, Never> {
        Just(.success(nil)).eraseToAnyPublisher()
    }
    
    var deleteImageWasCalled = false
    var deleteImageSubject = PassthroughSubject<Result<Void, Error>, Never>()
    func delete(image url: String?) -> AnyPublisher<Result<Void, Error>, Never> {
        deleteImageSubject
            .handleEvents(
                receiveOutput: { _ in  self.deleteImageWasCalled = true  }
            )
            .eraseToAnyPublisher()
    }
}
