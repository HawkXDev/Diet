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
    var mealInfo: MealInfo?
    
    var selectedMeal: Meal? {
        didSet {
            mealInfo = MealInfo(for: selectedMeal!)
            performSegue(withIdentifier: K.mealPopover, sender: self)
        }
    }
    
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
        
        if segue.identifier == K.foodsSegue {
            
            let destinationVC = segue.destination as! FoodsViewController
            destinationVC.delegate = self
            destinationVC.dataManager = dataManager
            
        } else if segue.identifier == K.mealPopover {
            
            let popoverViewController =
                segue.destination as! MealPopoverViewController
            popoverViewController.modalPresentationStyle = .popover
            
            let popover = popoverViewController.popoverPresentationController!
            popover.delegate = self
            
            popover.permittedArrowDirections = .up
            popover.sourceView = topSecondView
            popover.sourceRect = topSecondView.bounds
            
            popoverViewController.delegate = self
            
            guard let safeMealInfo = mealInfo else { fatalError() }
            popoverViewController.mealInfo = safeMealInfo
        }
        
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
        caloriesProgress.setProgressTintColor()
        carbsProgress.progress = mealsManager!.carbsProgress
        carbsProgress.setProgressTintColor()
        proteinProgress.progress = mealsManager!.proteinProgress
        proteinProgress.setProgressTintColor()
        fatProgress.progress = mealsManager!.fatProgress
        fatProgress.setProgressTintColor()
        
        let mealElements = mealsManager!
            .getFoodElementsForMealtime(for: mealtime!)
        mealTotalInfo.text = "\(mealElements.calories) kcal  (" +
            "c: \(mealElements.carbs) " +
            "p: \(mealElements.protein) " +
            "f: \(mealElements.fat))"
    }
    
    // MARK: - Show Alert For Update Meal
    
//    func showAlertForUpdateMeal() {
//        let savedQty = selectedMeal!.qty
//        let food = selectedMeal!.food!
//        let dishMeasure = selectedMeal!.dishMeasure!
//
//        let alert = UIAlertController(title: "Change\n\(food.name!)",
//                                      message: nil,
//                                      preferredStyle: .alert)
//
//        var textField = UITextField()
//
//        let measureName = dishMeasure.measure!.name!
//        alert.addTextField { (field) in
//            textField = field
//            textField.placeholder = "\(measureName)"
//            textField.addTarget(self,
//                                action: #selector(self.textFieldChanged),
//                                for: .editingChanged)
//        }
//
//        alert.addAction(UIAlertAction(title: "Change",
//                                      style: .default,
//                                      handler: { (action) in
//
//            if let qty = Double(textField.text ?? "") {
//                self.updateMeal(qty: qty)
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel",
//                                      style: .cancel,
//                                      handler: { (action) in
//            self.updateMeal(qty: savedQty)
//        }))
//
//        present(alert, animated: true, completion: nil)
//    }
    
}

//@objc func textFieldChanged(textField: UITextField) {
//    if let qty = Double(textField.text ?? "") {
//        self.updateMeal(qty: qty)
//    }
//}

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
        
        let mealInfo = MealInfo(for: meal)
        cell.titleView.text = mealInfo.titleText
        cell.caloriesView.text = mealInfo.caloriesText
        cell.carbsView.text = mealInfo.carbsText
        cell.proteinView.text = mealInfo.proteinText
        cell.fatView.text = mealInfo.fatText
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedMeal = mealsManager!.getMeal(index: indexPath.row)
    }
    
    func updateMeal(qty: Double) {
        if selectedMeal != nil {
            mealInfo!.qty = qty
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

// MARK: - Section Heading

extension UIProgressView {
    func setProgressTintColor() {
        if self.progress < 0.25 {
            self.progressTintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else if self.progress < 0.5 {
            self.progressTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        } else if self.progress < 0.75 {
            self.progressTintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        } else {
            self.progressTintColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
    }
}

// MARK: - MealPopoverDelegate

extension MealsView: MealPopoverDelegate,
                     UIPopoverPresentationControllerDelegate {
    func sliderChanged(_ popoverVC: MealPopoverViewController, value: Float) {
        updateMeal(qty: Double(value))
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController)
    -> UIModalPresentationStyle {
        return .none
    }
    
}
