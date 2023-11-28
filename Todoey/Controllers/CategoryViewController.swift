//
//  TableViewController.swift
//  Todoey
//
//  Created by Yeoh Hui Qing on 27/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var categories: Results<Category>? // no need to append new categories to it anymore, will auto retrieve from Realm db

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCategories()
        searchBar.delegate = self
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
                    let category = Category()
                    category.name = newCategory
                    self.save(category: category)
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
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! TableViewCell
        if let category = categories?[indexPath.row] {
            cell.configure(title: category.name, itemsCount: category.items.count)
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            self.showErrorAlert(message: error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        self.tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                self.showErrorAlert(message: "Error deleting category: \(error)")
            }
        }
    }
    
    // MARK: - Search Bar Methods
    
    override func search(_ searchText: String? = "") {
        if searchText == "" {
            loadCategories()
        } else {
            self.categories = self.categories?
                .filter("name CONTAINS[dc] %@", searchText)
                .sorted(byKeyPath: "name", ascending: true)
        }
        self.tableView.reloadData()
    }
}
