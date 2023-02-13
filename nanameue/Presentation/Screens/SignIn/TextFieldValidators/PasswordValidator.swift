//
//  PasswordValidator.swift
//  nanameue
//
//  Created by Volnov Ivan on 13/02/2023.
//

import Foundation

final class PasswordValidator: TextFieldValidator {
    
    init() {}
    
    func isValid(text: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@ ", regex)
        let isValid = predicate.evaluate(with: text)
        return isValid
    }
}
