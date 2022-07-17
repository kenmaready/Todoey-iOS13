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
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Tasks.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("dataFilePath: \(dataFilePath!)")
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        // retrieve tasks from memory
        // tasks = defaults.array(forKey: "tasks") as? [Task] ?? [] // 1. userdefaults
        loadTasksFromLocalStorage() // 2. custom .plist
        
    }


    @IBAction func addTaskButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add a new task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newTaskDescription = textField.text {
                if newTaskDescription != "" {
                    print("new task is: \(newTaskDescription)")
                    
                    self.tasks.append(Task(desc:newTaskDescription))
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
}

// MARK: - I/O Methods 2. Custom .plist file with Codable

extension TodoListViewController {
    func saveTasksToLocalStorage() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(self.tasks)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("There was an error when encoding an array of Tasks: \(error)")
        }
    }
    
    func loadTasksFromLocalStorage() {
        if let data = try? Data(contentsOf: dataFilePath!) {

            let decoder = PropertyListDecoder()
            do {
                tasks = try decoder.decode([Task].self, from: data)
            } catch {
                print("There was an error decoding an array of Tasks from local storage: \(error)")
            }
        }
        
        
    }
}
