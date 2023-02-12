//
//  ImageService.swift
//  nanameue
//
//  Created by Volnov Ivan on 09/02/2023.
//

import Combine
import Foundation

protocol ImageService {
    func upload(jpeg: Data) -> AnyPublisher<Result<URL, Error>, Never>
}
