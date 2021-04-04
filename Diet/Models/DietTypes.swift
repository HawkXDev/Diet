//
//  DietTypePickerData.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import Foundation

enum DietTypes: String, CaseIterable {
    case reduceWeight = "Reduce weight"
    case maintainWeight = "Maintain weight"
    case gainWeight = "Gain weight"
    
    init?(id: Int) {
        switch id {
        case 0: self = .reduceWeight
        case 1: self = .maintainWeight
        case 2: self = .gainWeight
        default: return nil
        }
    }
    
    func getId() -> Int {
        switch self {
        case .reduceWeight: return 0
        case .maintainWeight: return 1
        case .gainWeight: return 2
        }
    }
}
