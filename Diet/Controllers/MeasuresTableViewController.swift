//
//  MeasuresTableViewController.swift
//  Diet
//
//  Created by Sergey Sokolkin on 4.04.21.
//

import UIKit
import CoreData

protocol MeasuresTableViewControllerDelegate {
    func chooseMeasure(_ measuresTableViewController: MeasuresTableViewController, dishMeasure: DishMeasure)
}

class MeasuresTableViewController: UITableViewController {
    
    var measuresArray = [Measure]()
    var foodParent: String?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegate: MeasuresTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    @IBAction func addMeasurePressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Measure", message: nil, preferredStyle: .alert)
        
        var textField = UITextField()
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Measure"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let text = textField.text {
                let newMeasure = Measure(context: self.context)
                newMeasure.name = text
                self.measuresArray.append(newMeasure)
                
                do {
                    try self.context.save()
                } catch {
                    print("Error saving measure. \(error)")
                }
                
                self.loadData()
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadData() {
        let request: NSFetchRequest<Measure> = Measure.fetchRequest()
        
        do {
            measuresArray = try context.fetch(request)
        } catch {
            print("Error fetching Measures. \(error)")
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measuresArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViewCells.measuresTableCellReuseIdentifier,
                                                 for: indexPath)
        cell.textLabel?.text = measuresArray[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMeasure = measuresArray[indexPath.row]
        let alert = UIAlertController(title: "Add \(selectedMeasure.name!) \nto \(foodParent!) ?", message: "", preferredStyle: .alert)
        
        var weightTextField = UITextField()
        alert.addTextField { (field) in
            weightTextField = field
            weightTextField.placeholder = "weight"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            
            if let weight = Int32(weightTextField.text ?? "") {
                
                let dishMeasure = DishMeasure(context: self.context)
                dishMeasure.measure = selectedMeasure
                dishMeasure.weight = weight
                
                self.delegate?.chooseMeasure(self, dishMeasure: dishMeasure)
                
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}
