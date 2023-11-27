//
//  TableViewController.swift
//  Todoey
//
//  Created by Yeoh Hui Qing on 27/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [ToDoCategory]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadCategories()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        // Add a text field to the alert controller
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create category"
            textField = alertTextField // grab reference to textField
        }
        
        // Add action
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newCategory = textField.text {
                if newCategory.count > 0 {
                    let category = ToDoCategory(context: self.context)
                    category.name = newCategory
                    self.categories.append(category)
                    self.saveCategories()
                } else {
                    self.showErrorAlert(message: "Text field cannot be empty.")
                }
            }
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView Datasource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            self.showErrorAlert(message: "Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<ToDoCategory> = ToDoCategory.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            self.showErrorAlert(message: "Unable to fetch data from context: \(error)")
        }
        tableView.reloadData()
    }
}
