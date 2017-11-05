//
//  ViewController.swift
//  Database
//
//  Created by Joo Hee Kim on 2015. 11. 12..
//  Copyright © 2015년 jhk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var status: UILabel!
    var databasePath = NSString()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        
        databasePath = dirPaths[0].appendingPathComponent("contacts1.db").path as NSString
        //databasePath = dirPaths[0].URLByAppendingPathComponent("contacts1.db").path!
        
        
        if !filemgr.fileExists(atPath: databasePath as String) {
            
            let contactDB = FMDatabase(path: databasePath as String)
            
            if contactDB == nil {
                print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            }
            
            if (contactDB?.open())! {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT, EMAIL TEXT)"
                if !(contactDB?.executeStatements(sql_stmt))! {
                    print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
                }
                contactDB?.close()
            } else {
                print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveData(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if (contactDB?.open())! {
            
            let insertSQL = "INSERT INTO CONTACTS (name, address, phone, email) VALUES ('\(name.text!)', '\(address.text!)', '\(phone.text!)', '\(email.text!)')"
            
            let result = contactDB?.executeUpdate(insertSQL,
                                                  withArgumentsIn: nil)
            
            if !result! {
                status.text = "Failed to add contact"
                print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            } else {
                status.text = "Contact Added"
                name.text = ""
                address.text = ""
                phone.text = ""
                email.text = ""
            }
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()))")
            
        }

    }

    @IBAction func findContact(sender: AnyObject) {
        let contactDB = FMDatabase(path: databasePath as String)
        
        if (contactDB?.open())! {
            let querySQL = "SELECT address, phone, email FROM CONTACTS WHERE name = '\(name.text!)'"
            
            let results:FMResultSet? = contactDB?.executeQuery(querySQL,
                                                               withArgumentsIn: nil)
            
            if results?.next() == true {
                address.text = results?.string(forColumn: "address")
                phone.text = results?.string(forColumn: "phone")
                email.text = results?.string(forColumn: "email")
                status.text = "Record Found"
            } else {
                status.text = "Record not found"
                address.text = ""
                phone.text = ""
                email.text = ""
            }
            contactDB?.close()
        } else {
            print("Error: \(String(describing: contactDB?.lastErrorMessage()) )")
        }

    }
}

