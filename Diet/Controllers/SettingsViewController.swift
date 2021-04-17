//
//  SettingsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let menuItems = ["Nutrient Goals", "My Weight", "Water Tracker"]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViewCells.settingsMenuCellReuseIdentifier,
                                                 for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: K.Segues.dietGoalsSegue, sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: K.Segues.myWeightSegue, sender: self)
        } else {
            performSegue(withIdentifier: K.Segues.waterTrackerSegue, sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
