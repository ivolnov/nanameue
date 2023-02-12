//
//  FirebaseImageService.swift
//  nanameue
//
//  Created by Volnov Ivan on 11/02/2023.
//

import FirebaseStorage
import Foundation
import Combine

final class FirebaseImageService {
    
    private let storage: Storage
    
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }
}

// MARK: - ImageService
extension FirebaseImageService: ImageService {
    
    func upload(jpeg: Data) -> AnyPublisher<Result<URL, Error>, Never> {
        Deferred {
            Future<Result<URL, Error>, Never> { [unowned self] promise in
                upload(jpeg: jpeg) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private
private extension FirebaseImageService {
    
    func upload(jpeg: Data, completion: @escaping (Result<URL, Error>) -> Void) {
 
        let image = storage.reference().child("images").child(UUID().uuidString)
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpeg"
                
        image.putData(jpeg, metadata: metadata) { metadata, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            image.downloadURL { (url, error) in
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
