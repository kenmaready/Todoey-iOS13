//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var tasks = ["Wash cat", "Clean dog", "Practice coding"]
    var selectedRow: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }


    @IBAction func addTaskButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a new task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let alertTextField = alert.textFields![0]
            if let newTask = alertTextField.text {
                if newTask != "" {
                    print("new task is: \(newTask)")
                    self.tasks.append(newTask)
                    self.tableView.reloadData()
                }
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Your new task"
            
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
        cell.textLabel!.text = tasks[indexPath.row]
        
//        if let safeRow = selectedRow {
//            if indexPath.row == safeRow {
//                cell.backgroundColor = UIColor.systemOrange
//                cell.textLabel!.textColor = UIColor.white
//                print("hey?")
//            } else {
//                cell.backgroundColor = UIColor.white
//                cell.textLabel!.textColor = UIColor.black
//            }
//        }
           
       return cell
    }
}

// MARK: - TableView Delegate Methods

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let currentCell = tableView.cellForRow(at: indexPath)
        
        if currentCell?.accessoryType == .checkmark {
            currentCell?.accessoryType = .none
        } else {
            currentCell?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

//        tableView.reloadData()
    }
}
