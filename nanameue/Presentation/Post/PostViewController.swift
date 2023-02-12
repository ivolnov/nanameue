//
//  PostViewController.swift
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

class PostViewController: UIViewController {
    
    // Dependecies
    private let completionSubject: PassthroughSubject<Void, Never>
    private let viewModel: PostViewModel
    
    // UI
    private var activityIndicator: UIActivityIndicatorView!
    private var textView: UITextView!
    private var image: UIImageView!
    
    private var bag: Set<AnyCancellable> = []
    
    init(
        completionSubject: PassthroughSubject<Void, Never>,
        viewModel: PostViewModel = PostViewModel()
    ) {
        self.completionSubject = completionSubject
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpImageView()
        setUpTextView()
        setUpActivityIndicator()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PostViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        
        let image = info[.originalImage] as? UIImage
        
        picker.dismiss(animated: true) {
            self.image.heightConstraint?.constant = .imageHeight
            
            UIView.animate(withDuration: 0.6) {
                self.view.layoutIfNeeded()
            }
            
            UIView.transition(
                with: self.image,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: { self.image.image = image },
                completion: nil
            )
        }
    }
}

// MARK: - UITextViewDelegate
extension PostViewController: UITextViewDelegate {
 
    func textViewDidChange(_ textView: UITextView) {
        let postLength = textView.text.count
        let canPost = 3...280 ~= postLength
        navigationItem.leftBarButtonItem?.isEnabled = canPost
    }
}

// MARK: - Layout
private extension PostViewController {
    
    func setUpNavBar() {
        let add = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapAddImage))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = add
        navigationItem.leftBarButtonItem = done
        navigationItem.title = "Create post"
        done.isEnabled = false
    }
    
    func setUpImageView() {
        image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = .radius.small
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        view.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 0),
            image.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: .margin.small),
            image.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .margin.medium),
            image.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -.margin.medium),
        ])
    }
    
    func setUpTextView() {
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .footnote)
        textView.textColor = .secondaryLabel
        textView.delegate = self
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: .textViewHeight),
            textView.topAnchor.constraint(equalTo: image.bottomAnchor, constant: .margin.medium),
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .margin.medium),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -.margin.small),
        ])
        
        textView.becomeFirstResponder()
    }
    
    func setUpActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// MARK: - Binding
private extension PostViewController {
    
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
private extension PostViewController {
    
    func setActivityIndicator(visible: Bool) {
        switch visible {
        case true:
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            view.isUserInteractionEnabled = false
        case false:
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            view.isUserInteractionEnabled = true
        }
    }
    
    func onDismiss() {
        completionSubject.send(())
        dismiss(animated: true)
    }
    
    @objc func didTapDone() {
        let text = textView.text ?? ""
        let jpeg = image.image?.jpegData(compressionQuality: 0.8)
        viewModel.createPostSubject.send(.init(text: text, jpeg: jpeg))
    }
    
    @objc func didTapAddImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
}

