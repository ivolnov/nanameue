//
//  Post.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Foundation

struct Post: Decodable {
    let id: String
    let url: String?
    let text: String
}
