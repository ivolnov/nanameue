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
        setUpTableViewView()
        setUpActivityIndicator()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {}

// MARK: - Private
private extension FeedViewController {
    
    func setUpNavBar() {
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = add
        navigationItem.title = "Posts"
    }
    
    func setUpTableViewView() {
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
    }
    
    func setActivityIndicator(visible: Bool) {
        switch visible {
        case true:
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        case false:
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    @objc func didTapAdd() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension FeedViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let image = info[.originalImage] as? UIImage
        _ = image?.jpegData(compressionQuality: 0.8)
        picker.dismiss(animated: true)
    }
}
