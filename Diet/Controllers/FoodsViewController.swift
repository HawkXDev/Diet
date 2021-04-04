//
//  FoodsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData

class FoodsViewController: UIViewController {
    
    var foodArray = [Food]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
    }
    
    @IBAction func foodAddPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add food", message: "", preferredStyle: .alert)
        
        var fieldName = UITextField()
        var fieldCalories = UITextField()
        var fieldCarbs = UITextField()
        var fieldProtein = UITextField()
        var fieldFat = UITextField()
        
        alert.addTextField { (field) in
            fieldName = field
            fieldName.placeholder = "Name"
        }
        alert.addTextField { (field) in
            fieldCalories = field
            fieldCalories.placeholder = "Calories"
        }
        alert.addTextField { (field) in
            fieldCarbs = field
            fieldCarbs.placeholder = "Carbs"
        }
        alert.addTextField { (field) in
            fieldProtein = field
            fieldProtein.placeholder = "Protein"
        }
        alert.addTextField { (field) in
            fieldFat = field
            fieldFat.placeholder = "Fat"
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let name = fieldName.text, let calories = fieldCalories.text, let carbs = fieldCarbs.text, let protein = fieldProtein.text, let fat = fieldFat.text {
                
                if let caloriesVal = Int32(calories), let carbsVal = Int32(carbs), let proteinVal = Int32(protein), let fatVal = Int32(fat) {
                    
                    let newFood = Food(context: self.context)
                    newFood.name = name
                    newFood.calories = caloriesVal
                    newFood.carbs = carbsVal
                    newFood.protein = proteinVal
                    newFood.fat = fatVal
                    
                    do {
                        try self.context.save()
                    } catch {
                        print("Error saving new Food. \(error)")
                    }
                    
                    self.loadData()
                }
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadData() {
        
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            foodArray = try context.fetch(request)
        } catch {
            print("Error loading data. \(error)")
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FoodsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.foodTableCell, for: indexPath)
        cell.textLabel?.text = foodArray[indexPath.row].name
        
        return cell
    }
    
}
