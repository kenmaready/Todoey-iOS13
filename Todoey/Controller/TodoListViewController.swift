//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeableTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let defaults =  UserDefaults.standard
    let realm = try! Realm()
    var tasks: Results<Task>?
    var category: Category? {
        didSet{
            fetchTasks()
            self.navigationController?.navigationBar.barTintColor = UIColor(hexString: category?.colorCode)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let catColor = category?.colorCode {
            print("current navigation.barTintColor is: \(self.navigationController?.navigationBar.barTintColor)")
            print("Setting navigationBar.barTintColor to: \(catColor)")
            
            let color = UIColor(hexString: catColor)!

            let appearance = UINavigationBarAppearance()
            let navBar = navigationController?.navigationBar
            let navItem = navigationController?.navigationItem
            let contrastColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
            
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: contrastColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: contrastColor]
            appearance.backgroundColor = color
            
            navItem?.rightBarButtonItem?.tintColor = contrastColor
            navBar?.tintColor = contrastColor
            navBar?.standardAppearance = appearance
            navBar?.scrollEdgeAppearance = appearance
            
            self.title = "\(category?.name ?? "") Tasks"
            searchBar.barTintColor = color
            searchBar.tintColor = contrastColor
            
            self.navigationController?.navigationBar.setNeedsLayout()
            
        }
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let task = tasks?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(task)
                }
            } catch {
                print("Error deleting task from Realm db: \(error.localizedDescription)")
            }
        }
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       
       // Configure the cell’s contents.
        if let cellTask = tasks?[indexPath.row] {
            cell.textLabel!.text = cellTask.desc
            cell.accessoryType = cellTask.completed ? .checkmark : .none
            
            let baseBackgroundColor = UIColor.init(hexString: category?.colorCode ?? "ffffff").lighten(byPercentage: 0.60)
            
            let backgroundColor = baseBackgroundColor!.darken(byPercentage: 0.4 * (CGFloat(indexPath.row) + 1.0) / (CGFloat(tasks?.count ?? indexPath.row + 1)))
            cell.backgroundColor = cellTask.completed ? UIColor.lightGray : backgroundColor
            cell.textLabel?.textColor = cellTask.completed ? .darkGray : ContrastColorOf(backgroundColor: backgroundColor!, returnFlat: true)
        } else {
            cell.textLabel!.text = "No tasks added yet"
            cell.textLabel?.textColor = .darkGray
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
}

// MARK: - I/O Methods 2. Custom .plist file with Codable

extension TodoListViewController {
    
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
            let searchFilter = NSPredicate(format: "desc CONTAINS[cd] %@", searchBar.text!)
            tasks = tasks?.filter(searchFilter).sorted(byKeyPath: "createdAt", ascending: true)

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
