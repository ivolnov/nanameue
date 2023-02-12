//
//  Post.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

import Foundation

struct Post: Codable {
    let id: String
    let url: String?
    let text: String
    let created: Date
}
