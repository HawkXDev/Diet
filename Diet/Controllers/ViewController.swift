//
//  ViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let dataManager = DataManager()
    
    var selectedRowTableView = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var arrayMeals = [Meal]()

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eatenCalories: UILabel!
    @IBOutlet weak var remainingCalories: UILabel!
    @IBOutlet weak var burnedCalories: UILabel!
    @IBOutlet weak var caloriesProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    @IBOutlet weak var fatProgress: UIProgressView!
    @IBOutlet weak var carbsValue: UILabel!
    @IBOutlet weak var proteinValue: UILabel!
    @IBOutlet weak var fatValue: UILabel!
    @IBOutlet weak var mealtimesTableView: UITableView!
    @IBOutlet weak var tableViewHeightLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealtimesTableView.delegate = self
        mealtimesTableView.dataSource = self
        
        mealtimesTableView.register(UINib(nibName: K.viewControllerTableCellNibName, bundle: nil), forCellReuseIdentifier: K.viewControllerTableCell)
        
        loadData()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Dosn't work!
//        tableViewHeightLayout.constant = mealtimesTableView.contentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.calendarSegue {
            
            let destinationVC = segue.destination as! CalendarViewController
            destinationVC.delegate = self
            
        } else if segue.identifier == K.mealSegue {
            
            let destinationVC = segue.destination as! MealsTableViewController
            
            destinationVC.navigationItem.title = Mealtimes.textValue(for: selectedRowTableView)
            destinationVC.dataManager = dataManager
        }
    }
    
    // MARK: - Load Data
    
    func loadData() {
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        let predicate = NSPredicate(format: "date = %@", dataManager.dateToView as NSDate)
        request.predicate = predicate
        
        do {
            arrayMeals = try context.fetch(request)
        } catch {
            print("Error fetching meals. \(error)")
        }
        
        updateSummary()
        
        mealtimesTableView.reloadData()
    }
    
    // MARK: - Funcs
    
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
        
        return FoodElements(calories: calories, carbs: carbs, protein: protein, fat: fat)
    }
    
    func updateSummary() {
        
        let summaryElements = getSummaryElements()
        
        var dietManager = DietManager()
        let foodGoal = dietManager.calculateDiet()
        
        eatenCalories.text = String(summaryElements.calories)
        
        remainingCalories.text = String(foodGoal.calories - summaryElements.calories)
        carbsValue.text = "\(summaryElements.carbs) / \(foodGoal.carbs) g"
        proteinValue.text = "\(summaryElements.protein) / \(foodGoal.protein) g"
        fatValue.text = "\(summaryElements.fat) / \(foodGoal.fat) g"
        
        caloriesProgress.progress = Float(summaryElements.calories) / Float(foodGoal.calories)
        carbsProgress.progress = Float(summaryElements.carbs) / Float(foodGoal.carbs)
        proteinProgress.progress = Float(summaryElements.protein) / Float(foodGoal.carbs)
        fatProgress.progress = Float(summaryElements.fat) / Float(foodGoal.carbs)
    }
    
    func getSummaryElements() -> FoodElements {
        
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
        
        return FoodElements(calories: calories, carbs: carbs, protein: protein, fat: fat)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Mealtimes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.viewControllerTableCell, for: indexPath) as! ViewControllerTableCell
        
        let mealtime = Mealtimes.textValue(for: indexPath.row)
        
        cell.titleView.text = mealtime
        
        let foodElements = getFoodElementsForMealtime(for: mealtime)
        
        if foodElements.calories > 0 {
            
            cell.rightView.isHidden = false
            
            cell.caloriesView.text = String(foodElements.calories)
            cell.carbsView.text = String(foodElements.carbs)
            cell.proteinView.text = String(foodElements.protein)
            cell.fatView.text = String(foodElements.fat)
        } else {
            
            cell.rightView.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRowTableView = indexPath.row
        
        performSegue(withIdentifier: K.mealSegue, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - CalendarViewControllerDelegate

extension ViewController: CalendarViewControllerDelegate {
    
    func dateSelected(_ calendarViewController: CalendarViewController, selectedDate: Date) {
        
        dataManager.dateToView = selectedDate
        dateLabel.text = dataManager.dateToViewString
        
        loadData()
    }
    
}

// MARK: - Type Extensions

extension Date {

    func isSame(with date: Date) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter.string(from: date) == dateFormatter.string(from: self)
    }
    
    func truncatedUTC() -> Date {
        
        var comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        comp.timeZone = TimeZone(abbreviation: "UTC")!
        let truncated = Calendar.current.date(from: comp)!
        
        return truncated
    }
    
}

extension Double {
    
    func isInteger() -> Bool {
        return floor(self) == self
    }
    
}
