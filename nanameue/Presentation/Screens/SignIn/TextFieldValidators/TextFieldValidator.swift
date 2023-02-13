//
//  TextFieldValidator.swift
//  nanameue
//
//  Created by Volnov Ivan on 13/02/2023.
//

import Foundation

protocol TextFieldValidator {
    func isValid(text: String) -> Bool
}
