//
//  MealInfo.swift
//  Diet
//
//  Created by Sergey Sokolkin on 9.04.21.
//

import Foundation

struct MealInfo {
    let meal: Meal
    let mealName: String
    let measureName: String
    
    var qty: Double?
    var titleText: String?
    var caloriesText: String?
    var carbsText: String?
    var proteinText: String?
    var fatText: String?
    
    var weight: Int32?
    var calories: Int32?
    var carbs: Double?
    var protein: Double?
    var fat: Double?
    
    init(for meal: Meal) {
        self.meal = meal
        
        mealName = meal.food!.name!
        measureName = meal.dishMeasure!.measure!.name!
        
        qty = meal.qty
        calculate()
        setTextValues()
    }
    
    mutating func calculate() {
        let food = meal.food!
        let dishMeasure = meal.dishMeasure!
        
        let weightD = qty! * Double(dishMeasure.weight)
        weight = weightD < Double(Int32.max)
            ? Int32(qty! * Double(dishMeasure.weight))
            : Int32.max
        calories = meal.weight * food.calories / 100
        carbs = Double(meal.weight) * food.carbs / 100.0
        protein = Double(meal.weight) * food.protein / 100.0
        fat = Double(meal.weight) * food.fat / 100.0
    }
    
    mutating func setTextValues() {
        let qtyText = qty!.isInteger()
            ? String(format: "%.0f", qty!)
            : String(format: "%.1f", qty!)
        
        titleText = "\(mealName)  \(qtyText) \(measureName) "
        
        caloriesText = String(calories!)
        carbsText = String(format: "%.1f", carbs!)
        proteinText = String(format: "%.1f", protein!)
        fatText = String(format: "%.1f", fat!)
    }
    
    mutating func setQty(qty: Double) {
        self.qty = qty
        
        calculate()
        setTextValues()
    }
}
