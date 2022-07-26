//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let defaults =  UserDefaults.standard
    let realm = try! Realm()
    var tasks: Results<Task>?
    var category: Category? {
        didSet{
            fetchTasks()
        }
    }
    
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
        self.title = "\(category?.name ?? "") Tasks"
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }


    @IBAction func addTaskButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newTaskDescription = textField.text {
                if newTaskDescription != "" {
                
                    if let unwrappedCategory = self.category {
                        
                        do {
                            try self.realm.write() {
                                let newTask = Task()
                                newTask.desc = newTaskDescription
                                unwrappedCategory.tasks.append(newTask)
                            }
                        } catch {
                            print("Error saving new Task: \(error.localizedDescription)")
                        }
                        
                        self.refresh()
                    }
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
        return tasks?.count ?? 1
    }

    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
       let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
       
       // Configure the cell’s contents.
        if let cellTask = tasks?[indexPath.row] {
            cell.textLabel!.text = cellTask.desc
            cell.accessoryType = cellTask.completed ? .checkmark : .none
            cell.textLabel?.textColor = cellTask.completed ? .darkGray : .black
            cell.backgroundColor = cellTask.completed ? UIColor.lightGray : UIColor.white
        } else {
            cell.textLabel!.text = "No tasks added yet"
        }
           
       return cell
    }
    
    func refresh() {
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate Methods

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let task = tasks?[indexPath.row] {
            do {
                try realm.write{
                    task.completed = !task.completed
                }
            } catch {
                print("Error changing completed status of task in Realm: \(error)")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if (editingStyle == .delete) {
//            // handle delete (by removing the data from your array and updating the tableview)
//            print("deleting cell no. \(indexPath.row)")
//
//            context.delete(tasks[indexPath.row])
//            tasks.remove(at: indexPath.row)
//
//            saveTasks()
//
//            refresh()
//        }
//    }
}

// MARK: - I/O Methods 2. Custom .plist file with Codable

extension TodoListViewController {
    func saveTasks() {
        
        do {
            try context.save()
        } catch {
            print("Error when trying to save CoreData: \(error)")
        }
    }
    
    func fetchTasks(_ with: NSPredicate? = nil) {
        tasks = category?.tasks.sorted(byKeyPath: "desc", ascending: true)
    }
}

// MARK: - SearchBarDelegate methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // if search is blank, reload full list of tasks:
        if searchBar.text == "" {
            fetchTasks()

        } else {
            
            // create the predicate (search filter)
            let predicate = NSPredicate(format: "desc CONTAINS[cd] %@", searchBar.text!)
            
            fetchTasks(predicate)
        }
        
        refresh()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchTasks()
            refresh()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
