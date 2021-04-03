//
//  CalendarViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 3.04.21.
//

import UIKit

protocol CalendarViewControllerDelegate {
    func dateSelected(_ calendarViewController: CalendarViewController, selectedDate: Date)
}

class CalendarViewController: UIViewController {
    
    var delegate: CalendarViewControllerDelegate?

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func todayPressed(_ sender: UIBarButtonItem) {
        datePicker.setDate(Date(), animated: true)
        handleDateChange()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        handleDateChange()
    }
    
    func handleDateChange() {
        delegate?.dateSelected(self, selectedDate: datePicker.date)
    }

}
