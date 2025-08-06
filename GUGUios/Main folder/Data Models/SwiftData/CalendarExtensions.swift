//
//  CalendarExtensions.swift
//  GUGUios
//
//  Extensions for Calendar to support SwiftData operations
//

import Foundation

extension Calendar {
    func swiftDataStartOfWeek(for date: Date = Date()) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfWeek(for date: Date = Date()) -> Date {
        let startOfWeek = swiftDataStartOfWeek(for: date)
        return self.date(byAdding: .day, value: 6, to: startOfWeek) ?? date
    }
    
    func isDate(_ date1: Date, inSameWeekAs date2: Date) -> Bool {
        let week1 = component(.weekOfYear, from: date1)
        let week2 = component(.weekOfYear, from: date2)
        let year1 = component(.year, from: date1)
        let year2 = component(.year, from: date2)
        return week1 == week2 && year1 == year2
    }
}