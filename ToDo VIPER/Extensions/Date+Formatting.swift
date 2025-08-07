//
//  Date+Formatting.swift
//  ToDo VIPER
//
//  Created by Артур  Арсланов on 03.08.2025.
//

import Foundation

extension Date {
    func formattedShort() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
