//
//  SettingsViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let menuItems = ["Diet Goals", "My Weight", "Water Tracker"]

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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.settingsMenuCell, for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: K.dietGoalsSegue, sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: K.myWeightSegue, sender: self)
        } else {
            performSegue(withIdentifier: K.waterTrackerSegue, sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
