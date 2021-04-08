//
//  ViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eatenCalories: UILabel!
    @IBOutlet weak var remainingCalories: UILabel!
    @IBOutlet weak var burnedCalories: UILabel!
    @IBOutlet weak var caloriesProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    @IBOutlet weak var fatProgress: UIProgressView!
    @IBOutlet weak var carbsValue: UILabel!
    @IBOutlet weak var proteinValue: UILabel!
    @IBOutlet weak var fatValue: UILabel!
    @IBOutlet weak var mealtimesTableView: UITableView!
    @IBOutlet weak var tableViewHeightLayout: NSLayoutConstraint!
    
    // MARK: - Params
    
    let dataManager = DataManager()
    var mealsManager: MealsManager?
    var selectedRowTableView = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
        loadData()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
    }
    
    private func setupVC() {
        mealtimesTableView.delegate = self
        mealtimesTableView.dataSource = self
        mealtimesTableView
            .register(UINib(nibName: K.viewControllerTableCellNibName,
                            bundle: nil),
                      forCellReuseIdentifier: K.viewControllerTableCell)
        
        mealsManager = MealsManager(dataManager: dataManager)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
        updateSummary()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Dosn't work!
//        tableViewHeightLayout.constant = mealtimesTableView.contentSize.height
    }
    
    // MARK: - Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.calendarSegue {
            let destinationVC = segue.destination as! CalendarViewController
            
            destinationVC.delegate = self
            destinationVC.dataManager = dataManager
        } else if segue.identifier == K.mealSegue {
            let destinationVC = segue.destination as! MealsView
            
            destinationVC.navigationItem.title = Mealtimes.textValue(for: selectedRowTableView)
            destinationVC.dataManager = dataManager
            destinationVC.mealsManager = mealsManager
        }
    }
    
    // MARK: - Load Data
    
    func loadData() {
        mealsManager?.loadData()
        mealtimesTableView.reloadData()
    }
    
    // MARK: - Funcs
    
    func updateSummary() {
        eatenCalories.text = mealsManager?.eatenCalories
        remainingCalories.text = mealsManager?.remainingCalories
        carbsValue.text = mealsManager?.carbsValue
        proteinValue.text = mealsManager?.proteinValue
        fatValue.text = mealsManager?.fatValue
        caloriesProgress.progress = mealsManager!.caloriesProgress
        carbsProgress.progress = mealsManager!.carbsProgress
        proteinProgress.progress = mealsManager!.proteinProgress
        fatProgress.progress = mealsManager!.fatProgress
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return Mealtimes.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: K.viewControllerTableCell,
            for: indexPath) as! ViewControllerTableCell
        
        let mealtime = Mealtimes.textValue(for: indexPath.row)
        
        cell.titleView.text = mealtime
        
        let foodElements = mealsManager!
            .getFoodElementsForMealtime(for: mealtime)
        
        if foodElements.calories > 0 {
            
            cell.rightView.isHidden = false
            
            cell.caloriesView.text = String(foodElements.calories)
            cell.carbsView.text = String(foodElements.carbs)
            cell.proteinView.text = String(foodElements.protein)
            cell.fatView.text = String(foodElements.fat)
        } else {
            
            cell.rightView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        selectedRowTableView = indexPath.row
        performSegue(withIdentifier: K.mealSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - CalendarViewControllerDelegate

extension ViewController: CalendarViewControllerDelegate {
    
    func dateSelected(_ calendarViewController: CalendarViewController,
                      selectedDate: Date) {
        
        dataManager.dateToView = selectedDate
        dateLabel.text = dataManager.dateToViewString

        loadData()
    }
}

// MARK: - Date, Double Extensions

extension Date {
    func isSame(with date: Date) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return
            dateFormatter.string(from: date) == dateFormatter.string(from: self)
    }
    
    func truncatedUTC() -> Date {
        var comp: DateComponents = Calendar
            .current
            .dateComponents([.year, .month, .day], from: self)
        
        comp.timeZone = TimeZone(abbreviation: "UTC")!
        
        let truncated = Calendar.current.date(from: comp)!
        return truncated
    }
}

extension Double {
    func isInteger() -> Bool {
        return floor(self) == self
    }
}
