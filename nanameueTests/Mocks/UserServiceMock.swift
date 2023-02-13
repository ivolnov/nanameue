//
//  UserServiceMock.swift
//  nanameueTests
//
//  Created by Volnov Ivan on 13/02/2023.
//

@testable import nanameue
import Foundation
import Combine

final class UserServiceMock: UserService {
    
    var signInuserStub: User!
    func signIn(email: String, password: String) -> AnyPublisher<Result<User, Error>, Never> {
        Just(.success(signInuserStub)).eraseToAnyPublisher()
    }
    
    var userUserSubject = PassthroughSubject<Result<User, Error>, Never>()
    func user() -> AnyPublisher<Result<User, Error>, Never> {
        userUserSubject.eraseToAnyPublisher()
    }
    
    var signOutCalled = false
    func signOut() {
        signOutCalled = true
    }
}
