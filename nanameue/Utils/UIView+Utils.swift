//
//  UIView+Utils.swift
//  nanameue
//
//  Created by Volnov Ivan on 12/02/2023.
//

import UIKit

extension UIView {
    var heightConstraint: NSLayoutConstraint? {
        constraints.first { $0.firstAttribute == .height && $0.relation == .equal }
    }
}
