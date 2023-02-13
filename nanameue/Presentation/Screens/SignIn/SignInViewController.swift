//
//  SignInViewController.swift
//  nanameue
//
//  Created by Volnov Ivan on 12/02/2023.
//

import Foundation
import Combine
import UIKit

fileprivate extension CGFloat {
    static let textViewHeight: CGFloat = 200
    static let imageHeight: CGFloat = 200
}

class SignInViewController: UIViewController {
    
    // Dependecies
    private let completionSubject: PassthroughSubject<Void, Never>
    private let viewModel: SignInViewModel
    
    // UI
    private var titleLabel: UILabel!
    private var emailField: UITextField!
    private var passwordField: UITextField!
    private var actionButton: UIButton!
    private var errorLabel: UILabel!
    
    private var bag: Set<AnyCancellable> = []
    
    init(
        completionSubject: PassthroughSubject<Void, Never>,
        viewModel: SignInViewModel = SignInViewModel()
    ) {
        self.completionSubject = completionSubject
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpEmail()
        setUpPassword()
        setUpActionButton()
        setUpErrorLabel()
        view.backgroundColor = .systemBackground
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITextViewDelegate
extension SignInViewController: UITextFieldDelegate {
 
}

// MARK: - Layout
private extension SignInViewController {
 
    func setUpTitle() {
        titleLabel = UILabel()
        titleLabel.text = "Welcome 😄"
        titleLabel.textColor = .darkText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)

        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
    
    func setUpEmail() {
        emailField = UITextField()
        emailField.placeholder = "Email"
        emailField.keyboardType = .emailAddress
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.font = UIFont.preferredFont(forTextStyle: .body)
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.addTarget(self, action: #selector(emailDidChange), for: .editingChanged)
        view.addSubview(emailField)
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .margin.medium),
            emailField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .margin.extraLarge),
            emailField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -.margin.extraLarge),
        ])
        
        emailField.becomeFirstResponder()
    }
    
    func setUpPassword() {
        passwordField = UITextField()
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.font = UIFont.preferredFont(forTextStyle: .body)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        view.addSubview(passwordField)
        
        NSLayoutConstraint.activate([
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: .margin.small),
            passwordField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .margin.extraLarge),
            passwordField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -.margin.extraLarge),
        ])
    }
    
    func setUpActionButton() {
        actionButton = UIButton(configuration: .borderedProminent())
        actionButton.isEnabled = false
        actionButton.setTitle("Sign in", for: .normal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.configuration?.imagePadding = .margin.small
        actionButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        view.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            actionButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            actionButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: .margin.small),
            actionButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .margin.extraLarge),
            actionButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -.margin.extraLarge),
        ])
    }
    
    func setUpErrorLabel() {
        errorLabel = UILabel()
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .systemRed
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)

        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: .margin.small),
            errorLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .margin.extraLarge),
            errorLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -.margin.extraLarge),
        ])
    }
}

// MARK: - Binding
private extension SignInViewController {
    
    func bind() {
        viewModel
            .$loading
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: setActivityIndicator
            )
            .store(in: &bag)
        
        viewModel
            .$error
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: setError
            )
            .store(in: &bag)
        
        viewModel
            .$dismiss
            .receive(on: RunLoop.main)
            .filter { dismiss in dismiss }
            .map { _ in () }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: onDismiss
            )
            .store(in: &bag)
    }
}

// MARK: - Event handling
private extension SignInViewController {
    
    func setActivityIndicator(visible: Bool) {
        switch visible {
        case true:
            actionButton.configuration?.showsActivityIndicator = true
            view.isUserInteractionEnabled = false
        case false:
            actionButton.configuration?.showsActivityIndicator = false
            view.isUserInteractionEnabled = true
        }
    }
    
    func setError(message: String) {
        actionButton.isEnabled = message.isEmpty
        errorLabel.text = message
    }
    
    
    func onDismiss() {
        completionSubject.send(())
        dismiss(animated: true)
    }
    
    @objc func emailDidChange() {
        viewModel.emailSubject.send(emailField.text ?? "")
    }
    
    @objc func passwordDidChange() {
        viewModel.passwordSubject.send(passwordField.text ?? "")
    }
    
    @objc func didTapSignIn() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        viewModel.signInSubject.send(.init(email: email, password: password))
    }
}
