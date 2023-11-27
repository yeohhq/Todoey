//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var items = [Item]()
    var selectedCategory: ToDoCategory? {
        didSet {
            loadItems() // Call once selectedCategory did get set
        }
    }
    
    // Get CoreData context from AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        searchBar.delegate = self
        self.title = selectedCategory?.name
    }

    // MARK: - TableView Datasource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Toggle checkmark
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].done = !items[indexPath.row].done
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true) // deselect item after being selected
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
                    let item = Item(context: self.context)
                    item.title = newItem
                    item.parentCategory = self.selectedCategory
                    self.items.append(item)
                    self.saveItems()
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
    
    // MARK: - Model Manipulation Methods
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            self.showErrorAlert(message: "Error saving context: \(error)")
        }
        self.tableView.reloadData() // needed to update tableView with newly added items
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) { // provide a default value
        // Only get items for selectedCategory
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            items = try context.fetch(request)
        } catch {
            self.showErrorAlert(message: "Unable to fetch data from context: \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            searchItems(with: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems() // reset UI to show all items
            
            // Hide keyboard, go to inactivated state again
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchItems(with: searchText)
        }
    }
    
    func searchItems(with searchText: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest() // Have to specify data type (i.e. Entity)
        
        // Query data with predicate
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        // Sort data with descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
    }
    
}

// MARK: - Error Handling

extension UIViewController {
    
    func showErrorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okAction)
        present(errorAlert, animated: true, completion: nil)
    }
    
}
