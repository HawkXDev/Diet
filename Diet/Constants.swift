//
//  Constants.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import Foundation

struct K {
    
    struct Segues {
        static let calendarSegue = "GoToCalendar"
        static let settingsSegue = "GoToSettings"
        static let dietGoalsSegue = "GoToDietGoals"
        static let myWeightSegue = "GoToMyWeight"
        static let waterTrackerSegue = "GoToWaterTracker"
        static let mealSegue = "GoToMeal"
        static let foodsSegue = "GoToFoods"
        static let measuresSegue = "GoToMeasures"
        static let mealPopoverSegue = "GoToMealPopover"
    }
    
    struct TableViewCells {
        static let settingsMenuCellReuseIdentifier = "SettingsMenuCell"
        static let mealtimeTableCellReuseIdentifier = "MealtimeTableCell"
        static let foodTableCellReuseIdentifier = "FoodTableCell"
        static let measuresTableCellReuseIdentifier = "MeasuresTableCell"
        static let mealsTableCellReuseIdentifier = "MealsTableCell"
        static let mealsCellNibName = "MealsTableViewCell"
        static let vcTableCellReuseIdentifier = "ViewControllerTableCell"
        static let vcTableCellNibName = "ViewControllerTableCell"
    }
    
}
