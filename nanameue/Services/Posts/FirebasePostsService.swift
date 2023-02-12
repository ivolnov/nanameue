//
//  FirebasePostsService.swift
//  nanameue
//
//  Created by Volnov Ivan on 11/02/2023.
//

import Combine
import FirebaseFirestore

final class FirebasePostsService {
    
    private let mapper: CodableMapper
    private let store: Firestore
    
    init(
        store: Firestore = Firestore.firestore(),
        mapper: CodableMapper = CodableMapperImpl()
    ) {
        self.mapper = mapper
        self.store = store
    }
}

// MARK: - PostsService
extension FirebasePostsService: PostsService {
    
    func create(post: Post, for user: User) -> AnyPublisher<Result<Void, Error>, Never> {
        
        let data = try! mapper.dictionary(from: post)
        
        let document = store
            .collection("users")
            .document(user.id)
            .collection("posts")
            .document(post.id)
        
        document.setData(data) { error in }
        
        return Just(.success(())).eraseToAnyPublisher()
    }
    
    func delete(post: Post, for user: User) -> AnyPublisher<Result<Void, Error>, Never> {
        Deferred {
            Future<Result<Void, Error>, Never> { [unowned self] promise in
                delete(post: post, for: user) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func posts(for user: User) -> AnyPublisher<Result<[Post], Error>, Never> {
        Deferred {
            Future<Result<[Post], Error>, Never> { [unowned self] promise in
                posts(for: user) { result in
                    promise(.success(result))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private
private extension FirebasePostsService {
    
    func create(post: Post, for user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            
            let data = try mapper.dictionary(from: post)
            
            let document = store
                .collection("users")
                .document(user.id)
                .collection("posts")
                .document(post.id)
            
            document.setData(data) { error in
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
            
        } catch {
            completion(.failure(error))
        }
    }
    
    func posts(for user: User, completion: @escaping (Result<[Post], Error>) -> Void) {
        
        let query = store
            .collection("users")
            .document(user.id)
            .collection("posts")
            .order(by: "created", descending: true)
        
        query.getDocuments() { [unowned self] snapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(result(from: snapshot))
            }
            
        }
    }
    
    func delete(post: Post, for user: User, completion: @escaping (Result<Void, Error>) -> Void) {
      
        let document = store
            .collection("users")
            .document(user.id)
            .collection("posts")
            .document(post.id)
        
        document.delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func result(from snapshot: QuerySnapshot?) -> Result<[Post], Error> {
        do {
            let documents = snapshot?.documents ?? []
            let posts: [Post] = try documents
                .map { document in document.data() }
                .compactMap { document in try self.mapper.decodable(from: document) }
            return .success(posts)
        } catch {
            return .failure(error)
        }
    }
}
