//
//  Cell.swift
//  nanameue
//
//  Created by Volnov Ivan on 06/02/2023.
//

enum Cell {
    case post(Post)
}

// MARK: - Hashable
extension Cell: Hashable {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .post(model):
            hasher.combine(model.id)
        }
    }
    
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        switch (lhs, rhs) {
        case  (let .post(lhsModel), let .post(rhsModel)):
            return lhsModel.id == rhsModel.id
        }
    }
}
