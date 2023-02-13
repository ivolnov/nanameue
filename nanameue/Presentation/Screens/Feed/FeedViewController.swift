//
//  FeedViewController.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Foundation
import Combine
import UIKit

class FeedViewController: UIViewController {
    
    // Dependecies
    private let dataSourceBuilder: FeedDataSourceBuilder
    private let viewModel: FeedViewModel
    
    // UI
    private lazy var dataSource = { dataSourceBuilder.build(with: tableView) } ()
    private var activityIndicator: UIActivityIndicatorView!
    private var tableView: UITableView!
    
    private var bag: Set<AnyCancellable> = []
    
    init(dataSourceBuilder: FeedDataSourceBuilder = FeedDataSourceBuilderImpl(),
         viewModel: FeedViewModel = FeedViewModel()) {
        self.dataSourceBuilder = dataSourceBuilder
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpTableView()
        setUpActivityIndicator()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadPostsSubject.send(())
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {}

// MARK: - Layout
private extension FeedViewController {
    
    func setUpNavBar() {
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "person.fill.xmark", withConfiguration: config)
        let signOut = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTapSignOut))
        navigationItem.leftBarButtonItem = signOut
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = add
        
        navigationItem.title = "Posts"
    }
    
    func setUpTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView?.backgroundColor = .red
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
private extension FeedViewController {
    
    func bind() {
        viewModel
            .$snapshot
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { snapshot in self.dataSource.apply(snapshot, animatingDifferences: true) }
            )
            .store(in: &bag)
        
        viewModel
            .$loading
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: setActivityIndicator
            )
            .store(in: &bag)
        
        viewModel
            .$showSignIn
            .filter { signIn in signIn }
            .map { _ in () }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: showSignIn
            )
            .store(in: &bag)
    }
}

// MARK: - Event handling
private extension FeedViewController {
    
    func showSignIn() {
        let controller = SignInViewController(completionSubject: viewModel.loadPostsSubject)
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false)
    }
    
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
    
    @objc func didTapAdd() {
        let controller = PostViewController(completionSubject: viewModel.loadPostsSubject)
        let stack = UINavigationController(rootViewController: controller)
        present(stack, animated: true)
    }
    
    @objc func didTapSignOut() {
        viewModel.signOutSubject.send(())
    }
}
