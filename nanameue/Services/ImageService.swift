//
//  ImageService.swift
//  nanameue
//
//  Created by Volnov Ivan on 09/02/2023.
//

import Combine
import Foundation
import FirebaseStorage

protocol ImageService {
    func upload(jpeg: Data) -> AnyPublisher<Result<URL, Error>, Never>
}

final class ImageServiceImpl {
    
    static let directory = "images"
    
    private let storage = Storage.storage()
    
    init() {}
}

// MARK: - ImageService
extension ImageServiceImpl: ImageService {
    
    func upload(jpeg: Data) -> AnyPublisher<Result<URL, Error>, Never> {
        Deferred {
            Future<Result<URL, Error>, Never> { promise in
                self.upload(jpeg: jpeg) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func upload(jpeg: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileName = UUID().uuidString
        
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(Self.directory)
        let fileRef = imagesRef.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
                
        fileRef.putData(jpeg, metadata: metadata) { metadata, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            fileRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let url = url {
                    completion(.success(url))
                }
            }
        }
    }
}
