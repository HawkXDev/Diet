//
//  ViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import UIKit

class ViewController: UIViewController {
    
    let dataManager = DataManager()
    
    var selectedRowTableView = 0

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eatenCalories: UILabel!
    @IBOutlet weak var remainingCalories: UILabel!
    @IBOutlet weak var burnedCalories: UILabel!
    @IBOutlet weak var carbsProgress: UIView!
    @IBOutlet weak var proteinProgress: UIView!
    @IBOutlet weak var fatProgress: UIProgressView!
    @IBOutlet weak var carbsValue: UILabel!
    @IBOutlet weak var proteinValue: UILabel!
    @IBOutlet weak var fatValue: UILabel!
    @IBOutlet weak var mealtimesTableView: UITableView!
    @IBOutlet weak var tableViewHeightLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealtimesTableView.delegate = self
        mealtimesTableView.dataSource = self
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var dietManager = DietManager()
        fillLabels(with: dietManager.calculateDiet())
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    func fillLabels(with foodGoal: FoodGoal) {
        remainingCalories.text = "\(foodGoal.calories)"
        carbsValue.text = "0 / \(foodGoal.carbs) g"
        proteinValue.text = "0 / \(foodGoal.protein) g"
        fatValue.text = "0 / \(foodGoal.fat) g"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewHeightLayout.constant = mealtimesTableView.contentSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.calendarSegue {
            
            let destinationVC = segue.destination as! CalendarViewController
            destinationVC.delegate = self
            
        } else if segue.identifier == K.mealSegue {
            
            let destinationVC = segue.destination as! MealsTableViewController
            
            destinationVC.navigationItem.title = Mealtimes.textValue(for: selectedRowTableView)
        }
        
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Mealtimes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.mealtimeTableCell, for: indexPath)
        cell.textLabel?.text = Mealtimes.textValue(for: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRowTableView = indexPath.row
        
        performSegue(withIdentifier: K.mealSegue, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - CalendarViewControllerDelegate

extension ViewController: CalendarViewControllerDelegate {
    
    func dateSelected(_ calendarViewController: CalendarViewController, selectedDate: Date) {
        
        dataManager.dateToView = selectedDate
        
        dateLabel.text = dataManager.dateToViewString
    }
    
}

// MARK: - Extension Date

extension Date {

    func isSame(with date: Date) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter.string(from: date) == dateFormatter.string(from: self)
    }
    
    func truncatedUTC() -> Date {
        
        var comp: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comp.timeZone = TimeZone(abbreviation: "UTC")!
        let truncated = Calendar.current.date(from: comp)!
        
        return truncated
    }
    
}
