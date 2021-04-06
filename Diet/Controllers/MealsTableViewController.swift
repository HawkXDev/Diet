//
//  MealsTableViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData
import SwipeCellKit

class MealsTableViewController: UITableViewController {
    
    var mealsArray = [Meal]()
    var mealtime: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var dataManager: DataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealtime = self.navigationItem.title
        
        tableView.register(UINib(nibName: K.mealsCellNibName, bundle: nil), forCellReuseIdentifier: K.mealsTableCell)
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! FoodsViewController
        destinationVC.delegate = self
    }
    
    // MARK: - Funcs
    
    func loadData() {
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        let predicate = NSPredicate(format: "mealtime CONTAINS[cd] %@ && date = %@", mealtime!, dataManager!.dateToView as NSDate)
        request.predicate = predicate
        
        do {
            mealsArray = try context.fetch(request)
        } catch {
            print("Error fetching meals. \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - TableViewMethods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsArray.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let meal = mealsArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.mealsTableCell, for: indexPath) as! MealsTableViewCell
        
        
        cell.titleView.text = "\(meal.food!.name!)  \(meal.qty.isInteger() ? String(format: "%.0f", meal.qty) : String(format: "%.1f", meal.qty)) \(meal.dishMeasure!.measure!.name!) "
        
        cell.caloriesView.text = String(meal.calories)
        cell.carbsView.text = String(format: "%.1f", meal.carbs)
        cell.proteinView.text = String(format: "%.1f", meal.protein)
        cell.fatView.text = String(format: "%.1f", meal.fat)
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - FoodsViewControllerDelegate

extension MealsTableViewController: FoodsViewControllerDelegate {
    
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

extension MealsTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            let itemToDelete = self.mealsArray[indexPath.row]
            self.context.delete(itemToDelete)
            self.mealsArray.remove(at: indexPath.row)
            tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")

        return [deleteAction]
    }
    
}
