//
//  Date+Utils.swift
//  nanameue
//
//  Created by Volnov Ivan on 12/02/2023.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
