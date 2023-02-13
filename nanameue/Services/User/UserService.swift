//
//  UserService.swift
//  nanameue
//
//  Created by Volnov Ivan on 11/02/2023.
//

import Combine
import Foundation
import FirebaseAuth

protocol UserService {
    func signIn(email: String, password: String) -> AnyPublisher<Result<User, Error>, Never>
    func user() -> AnyPublisher<Result<User, Error>, Never>
    func signOut()
}

final class UserServiceImpl {
    
    fileprivate enum ErorrCode: Int {
        case userExists = 17007
    }
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
}

// MARK: - UserService
extension UserServiceImpl: UserService {
    
    func signOut() {
        try? auth.signOut()
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<Result<User, Error>, Never> {
        Deferred {
            Future<Result<User, Error>, Never> { [unowned self] promise in
                self.signUp(email: email, password: password) { result in promise(.success(result)) }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func user() -> AnyPublisher<Result<User, Error>, Never> {
        Deferred {
            Future<Result<User, Error>, Never> { [unowned self] promise in
                promise(.success(self.current()))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private
private extension UserServiceImpl {
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { [unowned self] user, error in
            if let error = error as? NSError {
                if error.code == ErorrCode.userExists.rawValue {
                    signIn(email: email, password: password, completion: completion)
                } else {
                    completion(.failure(error))
                }
                return
            }
            completion(self.current())
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { [unowned self] user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(self.current())
        }
    }
    
    func current() -> Result<User, Error> {
        switch auth.currentUser?.uid {
        case .some(let id):
            return .success(User(id: id))
        case .none:
            return .failure(AppError.noUser)
        }
    }
}
