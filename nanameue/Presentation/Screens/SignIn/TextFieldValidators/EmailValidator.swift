//
//  EmailValidator.swift
//  nanameue
//
//  Created by Volnov Ivan on 13/02/2023.
//

import Foundation

final class EmailValidator: TextFieldValidator {
    
    init() {}
    
    func isValid(text: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@ ", regex)
        let isValid = predicate.evaluate(with: text)
        return isValid
    }
}
