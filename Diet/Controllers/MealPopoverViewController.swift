//
//  MealPopoverViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 9.04.21.
//

import UIKit

protocol MealPopoverDelegate {
    func sliderChanged(_ popoverVC: MealPopoverViewController,
                       value: Float)
}

class MealPopoverViewController: UIViewController {
    
    var delegate: MealPopoverDelegate?
    var mealInfo: MealInfo?

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var caloriesView: UILabel!
    @IBOutlet weak var carbsView: UILabel!
    @IBOutlet weak var proteinView: UILabel!
    @IBOutlet weak var fatView: UILabel!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.cornerRadius = 5
        
        slider.maximumValue = Float(mealInfo!.qty! * 2.0)
        slider.value = Float(mealInfo!.qty!)
        
        setViews()
    }
    
    func setViews() {
        titleView.text = mealInfo!.titleText
        caloriesView.text = mealInfo!.caloriesText
        carbsView.text = mealInfo!.carbsText
        proteinView.text = mealInfo!.proteinText
        fatView.text = mealInfo!.fatText
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        mealInfo!.setQty(qty: Double(slider.value))
        setViews()
        
        delegate?.sliderChanged(self, value: slider.value)
    }
    
}
