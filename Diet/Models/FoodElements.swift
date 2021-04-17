//
//  FoodGoal.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import Foundation

struct FoodElements {
    
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    
    let carbsProc: Double
    let proteinProc: Double
    let fatProc: Double
    
    let caloriesText: String
    let carbsText: String
    let proteinText: String
    let fatText: String
    
    init(calories: Int, carbs: Int, protein: Int, fat: Int) {
        
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        
        self.carbsProc = Double(carbs) * 4.0 / Double(calories)
        self.proteinProc = Double(protein) * 4.0 / Double(calories)
        self.fatProc = Double(fat) * 9.0 / Double(calories)
        
        if calories != 0 {
            self.caloriesText = "\(calories) kcal"
            self.carbsText = "\(carbs) g (\(carbs * 4) kcal)"
            self.proteinText = "\(protein) g (\(protein * 4) kcal)"
            self.fatText = "\(fat) g (\(fat * 9) kcal)"
        } else {
            self.caloriesText = "0 kcal"
            self.carbsText = "\(carbs) g (\(carbs * 4) kcal)"
            self.proteinText = "\(protein) g (\(protein * 4) kcal)"
            self.fatText = "\(fat) g (\(fat * 9) kcal)"
        }
        
    }
    
}
