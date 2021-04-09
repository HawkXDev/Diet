//
//  FoodsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData

protocol FoodsViewControllerDelegate {
    func didAddMeal(_ foodsViewController: FoodsViewController, meal: Meal)
}

class FoodsViewController: UIViewController {
    
    var foodArray = [Food]()
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    var selectedFood: Food?
    var delegate: FoodsViewControllerDelegate?
    var dishMeasuresArray = [DishMeasure]()
    var selectedDishMeasure: DishMeasure?
    var dataManager: DataManager?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addMeasureButton: UIButton!
    @IBOutlet weak var dishMeasuresPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        dishMeasuresPicker.delegate = self
        dishMeasuresPicker.dataSource = self
        
        loadData()
        updatePicker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Because first the segue goes to the NavigationController
        let destinationVC = segue.destination as! UINavigationController
        
        let tableViewVC =
            destinationVC.topViewController as! MeasuresTableViewController
        tableViewVC.foodParent = selectedFood?.name
        tableViewVC.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction func foodAddPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add food",
                                      message: "",
                                      preferredStyle: .alert)
        
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
            
            if let name = fieldName.text,
               let calories = fieldCalories.text,
               let carbs = fieldCarbs.text,
               let protein = fieldProtein.text,
               let fat = fieldFat.text {
                
                if let caloriesVal = Int32(calories),
                   let carbsVal = Double(carbs),
                   let proteinVal = Double(protein),
                   let fatVal = Double(fat) {
                    
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
    
    @IBAction func addDishPressed(_ sender: UIButton) {
        
        if let food = selectedFood {
            
            let alert = UIAlertController(title: "Add\n\(food.name!)",
                                          message: nil,
                                          preferredStyle: .alert)
            
            var textField = UITextField()
            let measureName = self.selectedDishMeasure!.measure!.name!
            alert.addTextField { (field) in
                textField = field
                textField.placeholder = "\(measureName)"
            }
            
            alert.addAction(UIAlertAction(title: "Add",
                                          style: .default,
                                          handler: { (action) in
                if let qty = Double(textField.text ?? "") {
                    
                    let meal = Meal(context: self.context)
                    meal.food = food
                    meal.weight =
                        Int32(qty * Double(self.selectedDishMeasure!.weight))
                    meal.date = self.dataManager?.dateToView
                    meal.calories = meal.weight * food.calories / 100
                    meal.carbs = Double(meal.weight) * food.carbs / 100.0
                    meal.protein = Double(meal.weight) * food.protein / 100.0
                    meal.fat = Double(meal.weight) * food.fat / 100.0
                    meal.dishMeasure = self.selectedDishMeasure
                    meal.qty = qty
                    
                    self.delegate?.didAddMeal(self, meal: meal)
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel,
                                          handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Funcs
    
    func loadData() {
        
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            foodArray = try context.fetch(request)
        } catch {
            print("Error loading data. \(error)")
        }
        
        tableView.reloadData()
    }
    
    func updatePicker() {
        dishMeasuresPicker.reloadComponent(0)
    }
    
    func setSelectedDishMeasureFirst() {
        if dishMeasuresArray.count > 0 {
            dishMeasuresPicker.selectRow(0, inComponent: 0, animated: true)
            selectedDishMeasure = dishMeasuresArray[0]
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FoodsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView
            .dequeueReusableCell(withIdentifier: K.foodTableCell,
                                 for: indexPath)
        cell.textLabel?.text = foodArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        selectedFood = foodArray[indexPath.row]
        addMeasureButton.isEnabled = true
        
        updateDishMeasures()
        updatePicker()
    }
    
    func updateDishMeasures() {
        
        dishMeasuresArray =
            selectedFood?.dishMeasures?.allObjects as! [DishMeasure]
        setSelectedDishMeasureFirst()
    }
    
}

// MARK: - MeasuresTableViewControllerDelegate

extension FoodsViewController: MeasuresTableViewControllerDelegate {
    
    func chooseMeasure(_ measuresTVC: MeasuresTableViewController,
                       dishMeasure: DishMeasure) {
        
        dishMeasure.food = selectedFood
        
        do {
            try context.save()
        } catch {
            print("Error saving dishMeasure. \(error)")
        }
        
        updateDishMeasures()
        updatePicker()
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension FoodsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return selectedFood?.dishMeasures?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        let dishMeasure = dishMeasuresArray[row]
        
        return "\(dishMeasure.measure!.name!) (\(dishMeasure.weight) g)"
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        if row < dishMeasuresArray.count {
            selectedDishMeasure = dishMeasuresArray[row]
        }
    }
}
