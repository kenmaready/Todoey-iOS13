//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let defaults =  UserDefaults.standard
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        // retrieve tasks from memory
//        tasks = defaults.array(forKey: "tasks") as? [String] ?? []
    }


    @IBAction func addTaskButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newTaskDescription = textField.text {
                if newTaskDescription != "" {
                    print("new task is: \(newTaskDescription)")
                    self.tasks.append(Task(desc:newTaskDescription))
//                    self.defaults.set(self.tasks, forKey: "tasks")
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
        if cellTask.completed {
            cell.accessoryType = .checkmark
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.white
        }
           
       return cell
    }
}

// MARK: - TableView Delegate Methods

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // toggle complete/incomplete
        if tasks[indexPath.row].completed {
            tasks[indexPath.row].completed = false
        } else {
            tasks[indexPath.row].completed = true
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}
