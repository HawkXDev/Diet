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
    
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    var mealsArray = [Meal]()
    var mealtime: String?
    var dataManager: DataManager?
    var mealsManager: MealsManager?
    
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
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        let predicate =
            NSPredicate(format: "mealtime CONTAINS[cd] %@ && date = %@",
                        mealtime!,
                        dataManager!.dateToView as NSDate)
        request.predicate = predicate
        
        do {
            mealsArray = try context.fetch(request)
        } catch {
            print("Error fetching meals. \(error)")
        }
        
        tableView.reloadData()
        updateSummary()
    }
    
    // MARK: - Update Summary
    
    func updateSummary() {
        mealsManager?.loadData()
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
        return mealsArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let meal = mealsArray[indexPath.row]
        
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
    }
    
}

// MARK: - FoodsViewControllerDelegate

extension MealsView: FoodsViewControllerDelegate {
    
    func didAddMeal(_ foodsViewController: FoodsViewController, meal: Meal) {
        meal.mealtime = mealtime
        
        do {
            try context.save()
        } catch {
            print("Error saving meal. \(error)")
        }
        
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
            let itemToDelete = self.mealsArray[indexPath.row]
            self.context.delete(itemToDelete)
            self.mealsArray.remove(at: indexPath.row)
            
            tableView.reloadData()
            self.updateSummary()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
}
