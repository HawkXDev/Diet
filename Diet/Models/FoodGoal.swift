//
//  FoodGoal.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import Foundation

struct FoodGoal {
    
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    
    let caloriesText: String
    let carbsText: String
    let proteinText: String
    let fatText: String
    
    init(calories: Int, carbs: Int, protein: Int, fat: Int) {
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        
        self.caloriesText = "\(calories) kcal"
        self.carbsText = "\(carbs) g (\(carbs * 4) kcal) \(carbs * 4 * 100 / calories)%"
        self.proteinText = "\(protein) g (\(protein * 4) kcal) \(protein * 4 * 100 / calories)%"
        self.fatText = "\(fat) g (\(fat * 9) kcal) \(fat * 9 * 100 / calories)%"
    }
    
}
