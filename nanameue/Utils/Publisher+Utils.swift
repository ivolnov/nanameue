//
//  Publisher+Utils.swift
//  nanameue
//
//  Created by Volnov Ivan on 11/02/2023.
//

import Combine

extension Publisher  {
    func onlySuccess<Type>() -> AnyPublisher<Type, Never> where Output == Result<Type, Error>, Failure == Never {
        flatMap { result in
            switch result {
            case .success(let type):
                return Just(type).eraseToAnyPublisher()
            case .failure:
                return Empty().eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    func onlyFailure<Type>() -> AnyPublisher<Error, Never> where Output == Result<Type, Error>, Failure == Never {
        flatMap { result in
            switch result {
            case .success:
                return Empty<Error, Never>().eraseToAnyPublisher()
            case .failure(let error):
                return Just(error).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
