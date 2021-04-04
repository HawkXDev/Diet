//
//  DietGoalsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit

class DietGoalsViewController: UIViewController {
    
    var dietManager = DietManager()

    @IBOutlet weak var dietTypePicker: UIPickerView!
    @IBOutlet weak var caloriesValue: UILabel!
    @IBOutlet weak var carbsValue: UILabel!
    @IBOutlet weak var proteinValue: UILabel!
    @IBOutlet weak var fatValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dietTypePicker.delegate = self
        dietTypePicker.dataSource = self
        
        let row = dietManager.getId()
        dietTypePicker.selectRow(row, inComponent: 0, animated: true)
        fillLabels(foosGoal: dietManager.calculateDiet(for: row))
    }
    
    func fillLabels(foosGoal: FoodGoal) {
        
        caloriesValue.text = foosGoal.caloriesText
        carbsValue.text = foosGoal.carbsText
        proteinValue.text = foosGoal.proteinText
        fatValue.text = foosGoal.fatText
    }

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension DietGoalsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dietManager.dietTypesCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dietManager.dietTypeTitle(for: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        fillLabels(foosGoal: dietManager.calculateDiet(for: row))
        dietManager.saveDietType()
    }
    
}
