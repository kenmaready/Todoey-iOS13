//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ken Maready on 7/23/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeableTableViewController {

    let realm = try! Realm()
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        fetchCategories()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newCategoryName = textField.text {
                if newCategoryName != "" {
                    
                    let newCategory = Category()
                    newCategory.name = newCategoryName
                    
                    self.saveCategory(newCategory)
                    self.refreshTable()
                }
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Your new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(category.tasks)
                    self.realm.delete(category)
                }
            } catch {
                print("Error deleting category from Realm db: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - TableViewDataSource methods
extension CategoryViewController{
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get swipeable configured cell from Swipeable (parent) class
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Configure the cell’s contents.
        if let cellCategory = categories?[indexPath.row] {
            cell.textLabel!.text = cellCategory.name
        } else {
            cell.textLabel!.text = "No categories added yet"
        }
           
       return cell
    }
    
    func refreshTable() {
        print("refreshing table...")
        tableView.reloadData()
    }
}


// MARK: - TableViewDelegate methods
extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // action for selection of row
        performSegue(withIdentifier: "goToTasks", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        refreshTable()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.category = categories?[indexPath.row]
        }
        
    }
}

// MARK: - I/O methods
extension CategoryViewController {
    
    func fetchCategories() {
        categories = realm.objects(Category.self)
    }

    func saveCategory(_ category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error when trying to save CoreData: \(error)")
        }
    }
    
}
