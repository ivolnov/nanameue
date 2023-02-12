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
    
    func upload(jpeg: Data?) -> AnyPublisher<Result<URL?, Error>, Never> {
        Deferred {
            Future<Result<URL?, Error>, Never> { [unowned self] promise in
                upload(jpeg: jpeg) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(image url: String?) -> AnyPublisher<Result<Void, Error>, Never> {
        Deferred {
            Future<Result<Void, Error>, Never> { [unowned self] promise in
                delete(image: url) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private
private extension FirebaseImageService {
    
    func upload(jpeg: Data?, completion: @escaping (Result<URL?, Error>) -> Void) {
        
        guard let jpeg = jpeg else {
            completion(.success(nil))
            return
        }
 
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
    
    func delete(image url: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = url else {
            completion(.success(()))
            return
        }
        
        let id = URL(string: url)?.pathComponents.last
        let image = storage.reference().child("images").child(id ?? "")
        
        image.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
}
