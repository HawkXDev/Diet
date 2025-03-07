//
//  MealsManager.swift
//  Diet
//
//  Created by Sergey Sokolkin on 8.04.21.
//

import UIKit
import CoreData

struct MealsManager {
    let dataManager: DataManager
    var arrayMeals = [Meal]()
    var arrayForMeal = [Meal]()
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    var summaryElements: FoodElements?
    var foodGoal: FoodElements?
    
    mutating func loadData(mealtime: String? = nil) {
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        let predicate = NSPredicate(format: "date = %@",
                                    dataManager.dateToView as NSDate)
        request.predicate = predicate
        do {
            arrayMeals = try context.fetch(request)
        } catch {
            print("Error fetching meals. \(error)")
        }
        
        updateSummary()
        
        if mealtime != nil {
            let request2: NSFetchRequest<Meal> = Meal.fetchRequest()
            let predicate2 = NSPredicate(format: "mealtime = %@ && date = %@",
                                         mealtime!,
                                         dataManager.dateToView as NSDate)
            request2.predicate = predicate2
            do {
                arrayForMeal = try context.fetch(request2)
            } catch {
                print("Error fetching meals. \(error)")
            }
        }
    }
    
    private mutating func updateSummary() {
        summaryElements = getSummaryElements()
        var dietManager = DietManager()
        foodGoal = dietManager.calculateDiet()
    }
    
    private func getSummaryElements() -> FoodElements {
        var calories = 0
        var carbs = 0
        var protein = 0
        var fat = 0
        
        for meal in arrayMeals {
            calories += Int(meal.calories)
            carbs += Int(meal.carbs)
            protein += Int(meal.protein)
            fat += Int(meal.fat)
        }
        
        return FoodElements(calories: calories,
                            carbs: carbs,
                            protein: protein,
                            fat: fat)
    }
    
    var eatenCalories: String {
        return String(summaryElements!.calories)
    }
    var remainingCalories: String {
        return String(foodGoal!.calories - summaryElements!.calories)
    }
    var carbsValue: String {
        return "\(summaryElements!.carbs) / \(foodGoal!.carbs) g"
    }
    var proteinValue: String {
        return "\(summaryElements!.protein) / \(foodGoal!.protein) g"
    }
    var fatValue: String {
        return "\(summaryElements!.fat) / \(foodGoal!.fat) g"
    }
    var caloriesProgress: Float {
        return Float(summaryElements!.calories) / Float(foodGoal!.calories)
    }
    var carbsProgress: Float {
        return Float(summaryElements!.carbs) / Float(foodGoal!.carbs)
    }
    var proteinProgress: Float {
        return Float(summaryElements!.protein) / Float(foodGoal!.carbs)
    }
    var fatProgress: Float {
        return Float(summaryElements!.fat) / Float(foodGoal!.fat)
    }
    
    func getFoodElementsForMealtime(for mealtime: String) -> FoodElements {
        var calories = 0
        var carbs = 0
        var protein = 0
        var fat = 0
        
        for meal in arrayMeals {
            if meal.mealtime == mealtime {
                calories += Int(meal.calories)
                carbs += Int(meal.carbs)
                protein += Int(meal.protein)
                fat += Int(meal.fat)
            }
        }
        
        return FoodElements(calories: calories,
                            carbs: carbs,
                            protein: protein,
                            fat: fat)
    }
    
    mutating func deleteMeal(index: Int) {
        let itemToDelete = arrayForMeal[index]
        context.delete(itemToDelete)
        do {
            try context.save()
        } catch {
            print("Error saving context. \(error)")
        }
        arrayForMeal.remove(at: index)
    }
    
    var mealsCount: Int {
        return arrayForMeal.count
    }

    func getMeal(index: Int) -> Meal {
        return arrayForMeal[index]
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving meal. \(error)")
        }
    }
    
}
