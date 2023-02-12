//
//  PostCellViewModel.swift
//  nanameue
//
//  Created by Volnov Ivan on 12/02/2023.
//

import Combine

struct PostCellViewModel {
    let deleteSubject: PassthroughSubject<Post, Never>
    let post: Post
}
