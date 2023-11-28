//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems() // Call once selectedCategory did get set
        }
    }
    
    // Search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Hide button
    var hideDone: Bool = false
    @IBOutlet weak var hideButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.title = selectedCategory?.name
    }

    // MARK: - TableView Datasource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! TableViewCell
        if let item = items?[indexPath.row] {
            cell.configure(title: item.title)
            cell.accessoryType = item.done ? .checkmark : .none // Toggle checked
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                self.showErrorAlert(message: "Error saving done status: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true) // deselect item after being selected
    }
    
    @IBAction func hideButtonPressed(_ sender: UIBarButtonItem) {
        hideDone = !hideDone
        if hideDone { // Hide done items
            items = items?.filter("done == false")
            tableView.reloadData()
            hideButton.image = UIImage(systemName: "eye")
        } else {
            loadItems()
            hideButton.image = UIImage(systemName: "eye.slash")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        
        // Add a text field to the alert controller
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create todo item"
            textField = alertTextField // grab reference to textField
        }
        
        // Add action
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newItem = textField.text {
                if newItem.count > 0 {
                    if let currentCategory = self.selectedCategory {
                        do {
                            try self.realm.write {
                                let item = Item()
                                item.title = newItem
                                item.dateCreated = Date()
                                currentCategory.items.append(item) // Reverse relationship link
                            }
                        } catch {
                            self.showErrorAlert(message: error.localizedDescription)
                        }
                    }
                    self.tableView.reloadData()
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
    
    // MARK: - Data Manipulation Methods
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                self.showErrorAlert(message: "Error deleting item: \(error)")
            }
        }
    }
    
    // MARK: - Search Bar Methods
    
    override func search(_ searchText: String? = "") {
        if searchText == "" {
            loadItems()
        } else {
            items = items?
                .filter("title CONTAINS[dc] %@", searchText)
                .sorted(byKeyPath: "dateCreated", ascending: true)
        }
        self.tableView.reloadData()
    }
}
