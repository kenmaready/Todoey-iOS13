//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ken Maready on 7/23/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories: [Category] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
                    
                    let newCategory = Category(context: self.context)
                    newCategory.name = newCategoryName
                    
                    self.categories.append(newCategory)
                    self.saveCategories()
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
}

// MARK: - TableViewDataSource methods
extension CategoryViewController{
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
       let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
       
       // Configure the cell’s contents.
        let cellCategory = categories[indexPath.row]
        cell.textLabel!.text = cellCategory.name
           
       return cell
    }
    
    func refreshTable() {
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
            destinationVC.category = categories[indexPath.row]
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if (editingStyle == .delete) {
                // handle delete (by removing the data from your array and updating the tableview)

                context.delete(categories[indexPath.row])
                categories.remove(at: indexPath.row)
                
                saveCategories()

                refreshTable()
            }
        }
}

// MARK: - I/O methods
extension CategoryViewController {
    
    func fetchCategories(_ request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error when trying to save CoreData: \(error)")
        }
    }
    
}
