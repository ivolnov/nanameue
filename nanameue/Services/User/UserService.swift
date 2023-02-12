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
    func user() -> AnyPublisher<Result<User, Error>, Never>
    func signIn()
}

final class UserServiceImpl {
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
}

// MARK: - UserService
extension UserServiceImpl: UserService {
    
    func signIn() {
        auth.signInAnonymously() { user, error in }
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
    func current() -> Result<User, Error> {
        switch auth.currentUser?.uid {
        case .some(let id):
            return .success(User(id: id))
        case .none:
            return .failure(AppError.noUser)
        }
    }
}
