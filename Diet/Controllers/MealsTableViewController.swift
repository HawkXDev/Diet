//
//  MealsTableViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData

class MealsTableViewController: UITableViewController {
    
    var mealsArray = [Meal]()
    var mealtime: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealtime = self.navigationItem.title
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! FoodsViewController
        destinationVC.delegate = self
    }
    
    // MARK: - Funcs
    
    func loadData() {
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        let predicate = NSPredicate(format: "mealtime CONTAINS[cd] %@", mealtime!)
        request.predicate = predicate
        
        do {
            mealsArray = try context.fetch(request)
        } catch {
            print("Error fetching meals. \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Section Heading
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.mealsTableCell, for: indexPath)
        cell.textLabel?.text = mealsArray[indexPath.row].food?.name
        
        return cell
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
