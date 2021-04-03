//
//  ViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import UIKit

class ViewController: UIViewController {
    
    let dataManager = DataManager()

    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.calendarSeque {
            let destinationVC = segue.destination as! CalendarViewController
            destinationVC.delegate = self
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
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

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
    
}
