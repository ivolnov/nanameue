//
//  UserService.swift
//  nanameue
//
//  Created by Volnov Ivan on 11/02/2023.
//

import Foundation
import FirebaseAuth

protocol UserService {
    func signIn()
}

final class UserServiceImpl {
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
}

extension UserServiceImpl: UserService {
    func signIn() {
        auth.signInAnonymously() { user, error in }
    }
}
