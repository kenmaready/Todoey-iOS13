//
//  AppDelegate.swift
//  Todoey
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//
 
import UIKit
import RealmSwift
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var window: UIWindow?
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        do {
            let realm = try Realm()
            print("Realm file: \(realm.configuration.fileURL)")
        } catch {
            print("Error initializing new Realm in AppDelegate: \(error)")
        }
        
        return true
    }
 
 
    func applicationWillTerminate(_ application: UIApplication) {
 
    }
 
}
