//
//  Mealtimes.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import Foundation

enum Mealtimes: CaseIterable {
    case breakfast, lunch, snack, dinner
    
    static func textValue(for id: Int) -> String {
        switch id {
        case 0: return "Breakfast"
        case 1: return "Lunch"
        case 2: return "Snack"
        case 3: return "Dinner"
        default: return "nothing"
        }
    }
}
