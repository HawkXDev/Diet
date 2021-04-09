//
//  MealInfo.swift
//  Diet
//
//  Created by Sergey Sokolkin on 9.04.21.
//

import Foundation

struct MealInfo {
    
    init(for meal: Meal) {
        self.meal = meal
        mealName = meal.food!.name!
        dishMeasure = meal.dishMeasure!
        measureName = dishMeasure.measure!.name!
        setQty(meal.qty)
    }
    
    private let meal: Meal
    private let dishMeasure: DishMeasure
    private let mealName: String
    private let measureName: String
    
    var titleText: String?
    var caloriesText: String?
    var carbsText: String?
    var proteinText: String?
    var fatText: String?
    
    var qty: Double? {
        didSet {
            meal.qty = qty!
            
            let qtyText = qty!.isInteger()
                ? String(format: "%.0f", qty!)
                : String(format: "%.1f", qty!)
            
            titleText = "\(mealName)  \(qtyText) \(measureName) "
            
            calculate()
        }
    }
    
    private var weightD: Double? {
        didSet {
            weight = weightD! < Double(Int32.max)
                ? Int32(qty! * Double(dishMeasure.weight))
                : Int32.max
        }
    }
    var weight: Int32? {
        didSet {
            meal.weight = weight!
        }
    }
    var calories: Int32? {
        didSet {
            meal.calories = calories!
            caloriesText = String(calories!)
        }
    }
    var carbs: Double? {
        didSet {
            meal.carbs = carbs!
            carbsText = String(format: "%.1f", carbs!)
        }
    }
    var protein: Double? {
        didSet {
            meal.protein = protein!
            proteinText = String(format: "%.1f", protein!)
        }
    }
    var fat: Double? {
        didSet {
            meal.fat = fat!
            fatText = String(format: "%.1f", fat!)
        }
    }
    
    private mutating func setQty(_ value: Double) {
        qty = value
    }
    
    private mutating func calculate() {
        let food = meal.food!
        
        weightD = qty! * Double(dishMeasure.weight)
        calories = meal.weight * food.calories / 100
        carbs = Double(meal.weight) * food.carbs / 100.0
        protein = Double(meal.weight) * food.protein / 100.0
        fat = Double(meal.weight) * food.fat / 100.0
    }
}
