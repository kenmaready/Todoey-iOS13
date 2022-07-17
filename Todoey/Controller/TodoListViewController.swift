//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let defaults =  UserDefaults.standard
    var tasks: [Task] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        // retrieve tasks from memory
        // tasks = defaults.array(forKey: "tasks") as? [Task] ?? [] // 1. userdefaults
        loadTasksFromLocalStorage() // 2. custom .plist
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }


    @IBAction func addTaskButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newTaskDescription = textField.text {
                if newTaskDescription != "" {
                    
                    let newTask = Task(context: self.context)
                    newTask.desc = newTaskDescription
                    
                    self.tasks.append(newTask)
                    self.saveTasksToLocalStorage()
                    self.tableView.reloadData()
                }
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Your new task"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource Methods

extension TodoListViewController {
    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
       let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
       
       // Configure the cell’s contents.
        let cellTask = tasks[indexPath.row]
        cell.textLabel!.text = cellTask.desc

        cell.accessoryType = cellTask.completed ? .checkmark : .none
        cell.textLabel?.textColor = cellTask.completed ? .darkGray : .black
        cell.backgroundColor = cellTask.completed ? UIColor.lightGray : UIColor.white
           
       return cell
    }
}

// MARK: - TableView Delegate Methods

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // toggle complete/incomplete
        tasks[indexPath.row].completed = !tasks[indexPath.row].completed
        saveTasksToLocalStorage()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            print("deleting cell no. \(indexPath.row)")

            context.delete(tasks[indexPath.row])
            tasks.remove(at: indexPath.row)
            
            saveTasksToLocalStorage()

            tableView.reloadData()
        }
    }
}

// MARK: - I/O Methods 2. Custom .plist file with Codable

extension TodoListViewController {
    func saveTasksToLocalStorage() {
        
        do {
            try context.save()
        } catch {
            print("Error when trying to save CoreData: \(error)")
        }
    }
    
    func loadTasksFromLocalStorage() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        
    }
}

// MARK: - SearchBarDelegate methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // if search is blank, reload full list of tasks:
        if searchBar.text! == "" {
            loadTasksFromLocalStorage()
            tableView.reloadData()
            return
        }
        
        // otherwise set up a search request:
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        // add predicate (search filter)
        let predicate = NSPredicate(format: "desc CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        
        // add sorting rules
        let sortDescriptor = NSSortDescriptor(key: "desc", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
        
        tableView.reloadData()
    }
}
