//
//  MealsTableViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData
import SwipeCellKit

class MealsView: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSecondView: UIView!
    @IBOutlet weak var caloriesProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    @IBOutlet weak var fatProgress: UIProgressView!
    @IBOutlet weak var mealTotalInfo: UILabel!
    
    var mealtime: String?
    var dataManager: DataManager?
    var mealsManager: MealsManager?
    var selectedMeal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
    }
    
    private func setupVC() {
        mealtime = self.navigationItem.title
        
        tableView.register(UINib(nibName: K.mealsCellNibName, bundle: nil),
                           forCellReuseIdentifier: K.mealsTableCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        topView.layer.cornerRadius = 10
        topSecondView.layer.cornerRadius = 10
    }
    
    // MARK: - Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FoodsViewController
        destinationVC.delegate = self
        destinationVC.dataManager = dataManager
    }
    
    // MARK: - Load Data
    
    func loadData() {
        mealsManager?.loadData(mealtime: mealtime)
        tableView.reloadData()
        updateSummary()
    }
    
    // MARK: - Update Summary
    
    func updateSummary() {
        mealsManager?.loadData(mealtime: mealtime)
        caloriesProgress.progress = mealsManager!.caloriesProgress
        carbsProgress.progress = mealsManager!.carbsProgress
        proteinProgress.progress = mealsManager!.proteinProgress
        fatProgress.progress = mealsManager!.fatProgress
        
        let mealElements = mealsManager!
            .getFoodElementsForMealtime(for: mealtime!)
        mealTotalInfo.text = "\(mealElements.calories) kcal  (" +
            "c: \(mealElements.carbs) " +
            "p: \(mealElements.protein) " +
            "f: \(mealElements.fat))"
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MealsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return mealsManager!.mealsCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let meal = mealsManager!.getMeal(index: indexPath.row)
        
        let cell = tableView
            .dequeueReusableCell(withIdentifier: K.mealsTableCell,
                                 for: indexPath) as! MealsTableViewCell
        
        let mealName = meal.food!.name!
        let qty = meal.qty.isInteger()
            ? String(format: "%.0f", meal.qty)
            : String(format: "%.1f", meal.qty)
        let measureName = meal.dishMeasure!.measure!.name!
        cell.titleView.text = "\(mealName)  \(qty) \(measureName) "
        
        cell.caloriesView.text = String(meal.calories)
        cell.carbsView.text = String(format: "%.1f", meal.carbs)
        cell.proteinView.text = String(format: "%.1f", meal.protein)
        cell.fatView.text = String(format: "%.1f", meal.fat)
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedMeal = mealsManager!.getMeal(index: indexPath.row)
        let food = selectedMeal!.food!
        let dishMeasure = selectedMeal!.dishMeasure!
        
        let alert = UIAlertController(title: "Change\n\(food.name!)",
                                      message: nil,
                                      preferredStyle: .alert)
        
        var textField = UITextField()
        
        let measureName = dishMeasure.measure!.name!
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "\(measureName)"
            textField.addTarget(self,
                                action: #selector(self.textFieldChanged),
                                for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Change",
                                      style: .default,
                                      handler: { (action) in
                                        
            if let qty = Double(textField.text ?? "") {
                self.updateMeal(qty: qty)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func textFieldChanged(textField: UITextField) {
        if let qty = Double(textField.text ?? "") {
            self.updateMeal(qty: qty)
        }
    }
    
    func updateMeal(qty: Double) {
        if let meal = selectedMeal {
            let food = meal.food!
            let dishMeasure = meal.dishMeasure!
            
            meal.weight = Int32(qty * Double(dishMeasure.weight))
            meal.calories = meal.weight * food.calories / 100
            meal.carbs = Double(meal.weight) * food.carbs / 100.0
            meal.protein = Double(meal.weight) * food.protein / 100.0
            meal.fat = Double(meal.weight) * food.fat / 100.0
            meal.qty = qty
            
            mealsManager!.saveContext()
            
            self.loadData()
        }
    }
    
}

// MARK: - FoodsViewControllerDelegate

extension MealsView: FoodsViewControllerDelegate {
    
    func didAddMeal(_ foodsViewController: FoodsViewController, meal: Meal) {
        meal.mealtime = mealtime
        
        mealsManager!.saveContext()
        
        loadData()
    }
}

// MARK: - SwipeTableViewCellDelegate

extension MealsView: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {
            action, indexPath in
            // handle action by updating model with deletion
            self.mealsManager!.deleteMeal(index: indexPath.row)
            tableView.reloadData()
            self.updateSummary()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
}
