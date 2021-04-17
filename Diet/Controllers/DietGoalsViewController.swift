//
//  DietGoalsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit

class DietGoalsViewController: UIViewController {
    
    var dietManager = DietManager()
    var nutritionLabels = [UILabel]()
    
    private let nutritionProcLabelWidth: CGFloat = 65.0
    private let nutritionProcLabelHeight: CGFloat = 35.0
    private let diagramRadius: CGFloat = 100.0

    @IBOutlet weak var dietTypePicker: UIPickerView!
    @IBOutlet weak var caloriesValue: UILabel!
    @IBOutlet weak var carbsValue: UILabel!
    @IBOutlet weak var proteinValue: UILabel!
    @IBOutlet weak var fatValue: UILabel!
    @IBOutlet weak var diagramView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dietTypePicker.delegate = self
        dietTypePicker.dataSource = self
        
        let row = dietManager.getId()
        dietTypePicker.selectRow(row, inComponent: 0, animated: true)
        calculateFoodGoalAndShowData(for: row)
    }
    
    func calculateFoodGoalAndShowData(for id: Int) {
        let foodGoal = dietManager.calculateDiet(for: id)
        fillLabels(with: foodGoal)
        deleteNutritionLabels()
        drawDiagram(with: foodGoal)
    }
    
    func deleteNutritionLabels() {
        for l in nutritionLabels {
            l.removeFromSuperview()
        }
        nutritionLabels = [UILabel]()
    }
    
    func fillLabels(with foodGoal: FoodElements) {
        caloriesValue.text = foodGoal.caloriesText
        carbsValue.text = foodGoal.carbsText
        proteinValue.text = foodGoal.proteinText
        fatValue.text = foodGoal.fatText
    }
    
    func drawDiagram(with foodGoal: FoodElements) {
        let carbsStrokeEnd = CGFloat(foodGoal.carbsProc)
        let carbsLayer = createNutritionDiagramLayer(strokeColor: #colorLiteral(red: 0.3254901961, green: 0.05882352941, blue: 0.6784313725, alpha: 1),
                                                     strokeStart: 0,
                                                     strokeEnd: carbsStrokeEnd)
        diagramView.layer.addSublayer(carbsLayer)
        
        let proteinStrokeEnd = carbsStrokeEnd + CGFloat(foodGoal.proteinProc)
        let proteinLayer = createNutritionDiagramLayer(strokeColor: #colorLiteral(red: 0.5176470588, green: 0.9137254902, blue: 0, alpha: 1),
                                                       strokeStart: carbsStrokeEnd,
                                                       strokeEnd: proteinStrokeEnd)
        diagramView.layer.addSublayer(proteinLayer)
        
        let fatLayer = createNutritionDiagramLayer(strokeColor: #colorLiteral(red: 1, green: 0.6196078431, blue: 0, alpha: 1),
                                                   strokeStart: proteinStrokeEnd,
                                                   strokeEnd: 1.0)
        diagramView.layer.addSublayer(fatLayer)
        
        let carbsX = calcXY(with: foodGoal.carbsProc / 2.0).x
        let carbsY = calcXY(with: foodGoal.carbsProc / 2.0).y
        let proteinX = calcXY(with: foodGoal.proteinProc / 2.0 + foodGoal.carbsProc).x
        let proteinY = calcXY(with: foodGoal.proteinProc / 2.0 + foodGoal.carbsProc).y
        let fatX = calcXY(with: 1.0 - foodGoal.fatProc / 2.0).x
        let fatY = calcXY(with: 1.0 - foodGoal.fatProc / 2.0).y
        
        nutritionLabels.append(createNutrProcLabel(x: carbsX, y: carbsY, procValue: foodGoal.carbsProc,
                                                   textColor: #colorLiteral(red: 0.3254901961, green: 0.05882352941, blue: 0.6784313725, alpha: 1)))
        nutritionLabels.append(createNutrProcLabel(x: proteinX, y: proteinY, procValue: foodGoal.proteinProc,
                                                   textColor: #colorLiteral(red: 0.5176470588, green: 0.9137254902, blue: 0, alpha: 1)))
        nutritionLabels.append(createNutrProcLabel(x: fatX, y: fatY, procValue: foodGoal.fatProc,
                                                   textColor: #colorLiteral(red: 1, green: 0.6196078431, blue: 0, alpha: 1)))
        for l in nutritionLabels {
            diagramView.addSubview(l)
        }
    }
    
    func calcXY(with proc: Double) -> (x: CGFloat, y: CGFloat) {
        let radius = diagramRadius * 1.5
        let xCenter = diagramView.frame.width / 2
        let yCenter = diagramView.frame.height / 2
        var x = xCenter + CGFloat(radius * cos(CGFloat(-0.5 * .pi + 2 * .pi * proc)))
        var y = yCenter + CGFloat(radius * sin(CGFloat(-0.5 * .pi + 2 * .pi * proc)))
        x -= nutritionProcLabelWidth / 2
        if proc > 0.4 && proc < 0.6 {
            y -= nutritionProcLabelHeight / 1.4 // Correction coefficient
        } else {
            y -= nutritionProcLabelHeight / 2
        }
        return (x, y)
    }
    
    func createNutrProcLabel(x: CGFloat, y: CGFloat, procValue: Double, textColor: UIColor) -> UILabel {
        let proteinProcLabel = UILabel(frame: CGRect(x: x, y: y,
                                                     width: nutritionProcLabelWidth,
                                                     height: nutritionProcLabelHeight))
        proteinProcLabel.textAlignment = .center
        proteinProcLabel.text = "\(Int(procValue * 100))%"
        proteinProcLabel.font = UIFont.boldSystemFont(ofSize: 24)
        proteinProcLabel.textColor = textColor
        return proteinProcLabel
    }
    
    func createNutritionDiagramLayer(strokeColor: CGColor, strokeStart: CGFloat, strokeEnd: CGFloat) -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: diagramView.frame.width/2, y: diagramView.frame.height/2),
                                      radius: diagramRadius, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)
        
        let nutritionLayer = CAShapeLayer()
        nutritionLayer.path = circlePath.cgPath
        nutritionLayer.fillColor = UIColor.clear.cgColor
        nutritionLayer.strokeColor = strokeColor
        nutritionLayer.lineWidth = 35.0
        nutritionLayer.strokeStart = strokeStart
        nutritionLayer.strokeEnd = strokeEnd
        
        return nutritionLayer
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
        calculateFoodGoalAndShowData(for: row)
        dietManager.saveDietType()
    }
    
}
