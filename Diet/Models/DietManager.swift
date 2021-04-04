//
//  DietManager.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import Foundation

struct DietManager {
    
    var dietType: DietTypes?
    
    let dietTypesCount = DietTypes.allCases.count
    
    let defaults = UserDefaults.standard
    
    init() {
        if let dietTypeRowValue = defaults.string(forKey: "DietType") {
            
            dietType = DietTypes(rawValue: dietTypeRowValue)
        }
    }
    
    func dietTypeTitle(for id: Int) -> String {
        
        return DietTypes(id: id)?.rawValue ?? ""
    }
    
    mutating func calculateDiet(for id: Int) -> FoodGoal {
        
        dietType = DietTypes(id: id)!
        
        var calories = 0
        var carbs = 0.0
        var protein = 0.0
        let fat = 75
        
        switch dietType {
        case .reduceWeight:
            calories = 1900
            protein = BodyParams.weight * 1.5
        case .maintainWeight:
            calories = 2400
            protein = BodyParams.weight * 1.6
        case .gainWeight:
            calories = 2900
            protein = BodyParams.weight * 1.7
        case .none:
            break
        }
        
        carbs = (Double(calories) - protein * 4 - Double(fat) * 9) / 4.0
        
        return FoodGoal(calories: calories, carbs: Int(carbs), protein: Int(protein), fat: fat)
    }
    
    func saveDietType() {

        defaults.setValue(dietType?.rawValue, forKey: "DietType")
    }
    
    func getId() -> Int {
        
        if let diet = dietType {
            return diet.getId()
        } else {
            return 0
        }
    }
    
}
