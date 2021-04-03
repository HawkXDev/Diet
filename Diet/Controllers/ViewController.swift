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
        
        if segue.identifier == "goToCalendar" {
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
