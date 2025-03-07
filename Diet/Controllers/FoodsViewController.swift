//
//  FoodsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData
import SwipeCellKit

protocol FoodsViewControllerDelegate {
    func didAddMeal(_ foodsViewController: FoodsViewController, meal: Meal)
}

class FoodsViewController: UIViewController {
    
    var foodArray = [Food]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: FoodsViewControllerDelegate?
    var dishMeasuresArray = [DishMeasure]()
    var selectedDishMeasure: DishMeasure?
    var dataManager: DataManager?
    
    var selectedFood: Food? {
        didSet {
            addMeasureButton.isEnabled = true
            updateDishMeasures()
            updatePicker()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addMeasureButton: UIButton!
    @IBOutlet weak var dishMeasuresPicker: UIPickerView!
    @IBOutlet weak var pickerZoneView: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
    
    func setupVC() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.layer.borderColor = #colorLiteral(red: 0.1592048705, green: 0.7238836884, blue: 0.4517703056, alpha: 1)
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 5
        
        pickerZoneView.layer.borderColor = #colorLiteral(red: 0.1592048705, green: 0.7238836884, blue: 0.4517703056, alpha: 1)
        pickerZoneView.layer.borderWidth = 1
        pickerZoneView.layer.cornerRadius = 5
        
        dishMeasuresPicker.delegate = self
        dishMeasuresPicker.dataSource = self
        
        searchBar.delegate = self
        
        loadData()
        updatePicker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Because first the segue goes to the NavigationController
        let destinationVC = segue.destination as! UINavigationController
        
        let tableViewVC = destinationVC.topViewController as! MeasuresTableViewController
        tableViewVC.foodParent = selectedFood?.name
        tableViewVC.delegate = self
    }
    
    // MARK: - IBActions
    
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
        if let food = selectedFood, let selectedMeasure = selectedDishMeasure {
            presentAlert(selectedFood: food, selectedMeasure: selectedMeasure)
        } else {
            if selectedDishMeasure == nil {
                pulceOrangeBorder(with: dishMeasuresPicker)
            }
            if selectedFood == nil {
                pulceOrangeBorder(with: tableView)
            }
        }
    }
    
    func presentAlert(selectedFood food: Food, selectedMeasure dishMeasure: DishMeasure) {
        let alert = UIAlertController(title: "Add\n\(food.name!)", message: nil, preferredStyle: .alert)
        
        var textField = UITextField()
        let measureName = dishMeasure.measure!.name!
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "\(measureName)"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let qty = Double(textField.text ?? "") {
                let meal = Meal(context: self.context)
                meal.food = food
                meal.weight = Int32(qty * Double(self.selectedDishMeasure!.weight))
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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func pulceOrangeBorder(with view: UIView) {
        let savedBorderWidth = view.layer.borderWidth
        let savedCornerRadius = view.layer.cornerRadius
        let savedBorderColor = view.layer.borderColor
        view.layer.borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            view.layer.borderColor = savedBorderColor
            view.layer.borderWidth = savedBorderWidth
            view.layer.cornerRadius = savedCornerRadius
        }
    }
    
    // MARK: - Funcs
    
    func loadData(with request:NSFetchRequest<Food> = Food.fetchRequest(), predicate: NSPredicate? = nil) {
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = predicate
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViewCells.foodTableCellReuseIdentifier, for: indexPath) as? SwipeTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        cell.delegate = self
        
        cell.textLabel?.text = foodArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFood = foodArray[indexPath.row]
    }
    
    func updateDishMeasures() {
        dishMeasuresArray = selectedFood?.dishMeasures?.allObjects as! [DishMeasure]
        setSelectedDishMeasureFirst()
    }
    
}

// MARK: - MeasuresTableViewControllerDelegate

extension FoodsViewController: MeasuresTableViewControllerDelegate {
    
    func chooseMeasure(_ measuresTVC: MeasuresTableViewController, dishMeasure: DishMeasure) {
        
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

// MARK: - SwipeTableViewCellDelegate

extension FoodsViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteFood(at: indexPath.row)
        }
        
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func deleteFood(at index: Int) {
        context.delete(self.foodArray[index])
        do {
            try context.save()
        } catch {
            print("Error saving context. \(error)")
        }
        foodArray.remove(at: index)
        tableView.reloadData()
        
        dishMeasuresPicker.reloadComponent(0)
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

// MARK: - Search Bar Methods

extension FoodsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Food> = Food.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        loadData(with: request, predicate: predicate)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
