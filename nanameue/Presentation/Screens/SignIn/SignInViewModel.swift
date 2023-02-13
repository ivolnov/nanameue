//
//  SignInViewModel.swift
//  nanameue
//
//  Created by Volnov Ivan on 12/02/2023.
//

import Foundation
import Combine

final class SignInViewModel {
    
    struct Credentials {
        let email: String
        let password: String
    }
    
    // Dependencies
    private let passwordValidator: TextFieldValidator
    private let emailValidator: TextFieldValidator
    private let userService: UserService
    
    let signInSubject: CurrentValueSubject<Credentials?, Never> = .init(nil)
    let passwordSubject: CurrentValueSubject<String, Never> = .init("")
    let emailSubject: CurrentValueSubject<String, Never> = .init("")
    
    @Published var dismiss = false
    @Published var loading = false
    @Published var error = " "
    
    private var bag: Set<AnyCancellable> = []
    
    init(
        passwordValidator: TextFieldValidator = PasswordValidator(),
        emailValidator: TextFieldValidator = EmailValidator(),
        userService: UserService = UserServiceImpl()
    ) {
        self.passwordValidator = passwordValidator
        self.emailValidator = emailValidator
        self.userService = userService
        bindEmail()
        bindPassword()
        bindSignIn()
    }
}

// MARK: - Binding
private extension SignInViewModel {
    
    func bindEmail() {
        emailSubject
            .dropFirst(1)
            .map { email in self.emailValidator.isValid(text: email) }
            .map { valid in valid ? "" : "email format is incorrect" }
            .assign(to: &$error)
    }
    
    func bindPassword() {
        passwordSubject
            .dropFirst(1)
            .map { email in self.passwordValidator.isValid(text: email) }
            .map { valid in valid ? "" : "password must contain a number, an upper case letter and be longer than 7 letters" }
            .assign(to: &$error)
    }
        
    func bindSignIn() {
        
        let signIn = signInSubject
            .compactMap { credentials in credentials }
            .flatMap { credentials in self.userService.signIn(email: credentials.email, password: credentials.password)}
            .share()
        
        signInSubject
            .compactMap { credentials in credentials }
            .map { _ in true }
            .assign(to: &$loading)
        
        signIn
            .onlySuccess()
            .map { _ in true }
            .assign(to: &$dismiss)
        
        signIn
            .onlyFailure()
            .map { error in error.localizedDescription }
            .assign(to: &$error)
        
        signIn
            .map { _ in false }
            .assign(to: &$loading)
    }
}
